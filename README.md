
## latent factor mixed models: lfmm

Genome and epigenome-wide association studies are plagued with
the problems of confounding and causality. The R package **lfmm** implements new
 algorithms for parameter estimation in latent factor mixed models (LFMM). The algorithms are designed for the correction of unobserved confounders. The new methods are computationally efficient, and provide statistically optimal corrections resulting in improved power and control for false discoveries. The package **lfmm** provides two main functions for estimating latent confounders (or factors): `lfmm_ridge` and `lfmm_lasso`. Those functions are based on optimal solutions of regularized least-squares problems. A short tutorial provides brief examples on how the R packages **lfmm** can be used for fitting latent factor mixed models and evaluating association between a response matrix (SNP genotype or methylation levels) and a variable of interest (phenotype or exposure levels) in genome-wide (GW), genome-environment (GE), epigenome-wide (EW) association studies. 
 
 
 Corresponding software is available at the following url <https://bcm-uga.github.io/lfmm/>.

The R package **lfmm** implements latent factor mixed models providing confounder 
adjusment for large-scale association studies. The model considers n samples of p response 
variables, stored in an n x p matrix, and one or several variables of interest (e.g., 
phenotypes, ecological variables). The package enables testing which response variables 
are associated with the variables of interest while removing confounding variation due to sample stratification or batch effects. The lfmm algorithms are fast and efficient and are supported by statistical
theory (oracle efficiency, identifiability, optimality of solutions).



## Installation

Installing the latest version from github requires [devtools](https://github.com/hadley/devtools):
```R
# install.packages("devtools")
devtools::install_github("bcm-uga/lfmm")
```

