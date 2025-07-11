# Main analysis steps; assumes data pre-processed into 'data/processed_asthma_data.csv'

# 1. Load required libraries ------------------------------------------------
library(dplyr)
library(glmmTMB)
library(lme4)
library(ggplot2)

# 2. Read in pre-processed dataset -----------------------------------------
df <- read.csv("data/processed_asthma_data.csv", stringsAsFactors = FALSE)

df <- df %>%
  mutate(
    ExacerbationIncidence = NumberofExacerbations / (Interval / 365.25),
    GAGroup = factor(GAGroup, levels = c("FT","LPT","E/VPT")),
    HighPRS = factor(HighPRS, levels = c("No","Yes")),
    pat_ethnicity = factor(pat_ethnicity),
    Race = factor(Race)
  )

# 3. Negative binomial regression for exacerbation counts ------------------
binomial_model <- glmmTMB(
  NumberofExacerbations ~ AvgAge_scaled + epic_gender +
    GAGroup * HighPRS * Fraction_above_8_scaled +
    pat_ethnicity + Race + MeanHouseholdIncome_scaled +
    offset(log(Interval)) +
    (1 | epic_birth_year) + (1 | Zip),
  family = nbinom2,
  data = df
)
print(summary(binomial_model))

# 4. Linear mixed-effects model for age at first exacerbation ---------------
# Subset to patients with >=1 exacerbation and compute first age
first_ex <- df %>%
  filter(NumberofExacerbations > 0) %>%
  group_by(Patient) %>%
  slice_min(order_by = FirstExacerbationAge) %>%
  ungroup()

lme_first <- lmer(
  FirstExacerbationAge ~ epic_gender +
    GAGroup * HighPRS * Fraction_above_8_scaled +
    pat_ethnicity + Race + MeanHouseholdIncome_scaled +
    (1 | epic_birth_year),
  data = first_ex
)
print(summary(lme_first))

# 5. Mixed-effects logistic regression for late exacerbations (>6 y/o) -------
df <- df %>% mutate(LateExacerbation = as.integer(LateExacerbation))
logit_late <- glmer(
  LateExacerbation ~ AvgAge_scaled + epic_gender +
    GAGroup * HighPRS * Fraction_above_8_scaled +
    pat_ethnicity + Race + MeanHouseholdIncome_scaled +
    (1 | epic_birth_year) + (1 | Zip),
  family = binomial(link = "logit"),
  data = df
)
print(summary(logit_late))

# 6. Generate figures -------------------------------------------------------
# Figure 1: Exacerbation incidence by GA group
p1 <- ggplot(df, aes(x = GAGroup, y = ExacerbationIncidence, fill = GAGroup)) +
  geom_boxplot() + theme_minimal() +
  labs(title = "Asthma Exacerbation Incidence by Gestational Age",
       x = "Gestational Age Group", y = "Exacerbations per Year")
ggsave("output/Figure1_exacerbation_by_GA.png", p1, width = 6, height = 4)

# Figure 2: Exacerbation incidence by PRS and GA
p2 <- ggplot(df, aes(x = HighPRS, y = ExacerbationIncidence, fill = HighPRS)) +
  geom_boxplot() + facet_wrap(~ GAGroup) + theme_minimal() +
  labs(title = "Exacerbation Incidence by PRS, Stratified by GA",
       x = "High sPRS", y = "Exacerbations per Year")
ggsave("output/Figure2_exacerbation_by_PRS_GA.png", p2, width = 8, height = 5)

# Figure 3: Age at first exacerbation by GA group
p3 <- ggplot(first_ex, aes(x = GAGroup, y = FirstExacerbationAge, fill = GAGroup)) +
  geom_boxplot() + theme_minimal() +
  labs(title = "Age at First Asthma Exacerbation by GA Group",
       x = "Gestational Age Group", y = "Age at First Exacerbation (days)")
ggsave("output/Figure3_age_first_exacerbation.png", p3, width = 6, height = 4)

# Figure 4: Proportion with late exacerbation by GA group
late_prop <- df %>%
  group_by(GAGroup) %>%
  summarize(PropLate = mean(LateExacerbation))
p4 <- ggplot(late_prop, aes(x = GAGroup, y = PropLate, fill = GAGroup)) +
  geom_col() + theme_minimal() +
  labs(title = "Proportion Experiencing Exacerbation >6 Years",
       x = "GA Group", y = "Proportion")
ggsave("output/Figure4_late_exacerbation_prop.png", p4, width = 6, height = 4)