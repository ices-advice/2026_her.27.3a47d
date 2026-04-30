## Run analysis, write model results

## Before: data_sf.RData and data_mf.RData (data)
## After:  config_sf.RData, results_sf.RData, 
##         config_mf.RData and results_mf.RData (model)

rm(list=ls())

library(icesTAF)

library(FLCore)
library(stockassessment)
library(FLSAM)
library(tidyverse)

# taf.session()

library(methods)


mkdir("model")

data.source             <- file.path(".", "bootstrap",'data')
data.save               <- file.path(".", "data")
model.save              <- file.path(".",'model')
model.config.save       <- file.path(".",'model',"config")
model.packages.save     <- file.path(".",'model',"packages")
model.assessment.save   <- file.path(".",'model',"assessment")

runName <- 'NSAS_HAWG2026_mf'

SMSkeyRuns      <- 2023
retroFlag       <- TRUE

source('utilities_model_config.R')

### ============================================================================
### Construct packages object
### ============================================================================

packages <- as.data.frame(taf.session()$packages)

save(packages, 
     file=file.path(model.save,paste0("packages_",runName,".RData")))

### ============================================================================
### Construct single fleet control object
### ============================================================================

addM    <- 0.02

load(file.path(data.save,paste0("data_sms",SMSkeyRuns,"_mf.RData")))  # NSH, NSH.tun

NSH3f@m <- NSH3f@m+addM

pg <- range(NSH3f)[2]

NSH3.ctrl <- config_mf_IBPNSherring2021_alt(NSH3f,NSH.tun,pg)
NSH3.ctrl@residuals <- TRUE

#NSHs3$residual@catch.n[ac(0),ac(2022),,,'A'] <- 0

### ============================================================================
### Run multi fleet model
### ============================================================================

# Run model
NSH3f.sam   <- FLSAM(NSH3f,
                     NSH.tun,
                     NSH3.ctrl)

# sam.fit <- FLSAM(NSHs3,
#                  NSH.tun,
#                  NSH3.ctrl,
#                  starting.values = NSH3f.sam.stk0,return.fit=TRUE)

save(NSH3f,
     NSH.tun,
     NSH3.ctrl,
     NSH3f.sam,
     file=file.path(model.save,
                    paste0(runName,".RData")))

### ============================================================================
### run multi fleet retro
### ============================================================================

if(retroFlag){
  # retro
  n.retro.years <- 10  # Number of years for which to run the retrospective
  NSH3.ctrl@residuals <- FALSE
  NSH3f.retro <- retro(NSH3f, NSH.tun, NSH3.ctrl, retro=n.retro.years)
  
  save(NSH3f.retro,
       file=file.path(model.save,paste0(runName,'_retro.RData')))
}
