Prematurity-Asthma-PM25-PRS

This repository contains the main analysis pipeline for Jelte Kelchtermans et al., "The impact of prematurity on pediatric asthma morbidity and indices with environmental pollution and genetic susceptibility." 
It implements the primary statistical models and generates key figures for the study.

Prerequisites
R (>= 4.4.1)

The following R packages:
install.packages(c(
  "dplyr", "glmmTMB", "lme4", "ggplot2"
))

Installation

Clone this repository to your local machine:
git clone https://github.com/yourusername/prematurity-asthma-pm25-prs.git
cd prematurity-asthma-pm25-prs

Usage
Place your pre-processed data in data/processed_asthma_data.csv.
Run the analysis script:
Rscript main_analysis_pipeline.R
Figures will be saved in the output/ directory.

Outputs
output/Figure1_exacerbation_by_GA.png
output/Figure2_exacerbation_by_PRS_GA.png
output/Figure3_age_first_exacerbation.png
output/Figure4_late_exacerbation_prop.png

License
This code is released under the MIT License.

For questions, please contact:
Jelte Kelchtermans
Email: kelchtermj@chop.edu
