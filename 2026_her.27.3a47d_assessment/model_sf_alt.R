## Run analysis, write model results

## Before: data_sf.RData and data_mf.RData (data)
## After:  config_sf.RData, results_sf.RData, 
##         config_mf.RData and results_mf.RData (model)

rm(list=ls())

library(icesTAF)

library(FLCore)
library(stockassessment)
library(FLSAM)

# taf.session()

library(methods)


mkdir("model")

data.save               <- file.path(".", "data")
model.save              <- file.path(".",'model')

SMSkeyRuns  <- 2023
retroFlag   <- TRUE

runName <- 'NSAS_HAWG2026_sf_Q1alt'

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

load(file.path(data.save,paste0("data_sms",SMSkeyRuns,"_sf_Q1alt.RData")))  # NSH, NSH.tun

NSH@m   <- NSH@m + addM

pg <- range(NSH)[2]

NSH.ctrl <- config_sf_IBPNSherring2021(NSH,NSH.tun,pg)
NSH.ctrl@residuals <- TRUE

### ============================================================================
### Run single fleet model
### ============================================================================

# Run model
NSH.sam     <- FLSAM(NSH, NSH.tun, NSH.ctrl)
# NSH.sim         <- simulate(NSH,NSH.tun,NSH.ctrl,n=10)
# temp <- monteCarloStock(NSH,NSH.tun,NSH.sam,10)
# 
# NSH.sim         <- simulate(NSH,NSH.tun,NSH.ctrl,n=nits)

NSH@stock.n <- NSH.sam@stock.n[,ac(range(NSH)["minyear"]:range(NSH)["maxyear"])]
NSH@harvest <- NSH.sam@harvest[,ac(range(NSH)["minyear"]:range(NSH)["maxyear"])]

save(NSH, NSH.tun, NSH.ctrl, NSH.sam, 
     file=file.path(model.save,paste0(runName,'.RData')))

### ============================================================================
### compare with base run
### ============================================================================

NSHs <- new('FLSAMs')

NSHs[['Q1_DATRAS']] <- NSH.sam

load(file.path(model.save,paste0('NSAS_HAWG2026_sf','.RData')))  # NSH, NSH.tun, NSH.ctrl, NSH.sam

NSHs[['baseline']] <- NSH.sam

df.ssb <- ssb(NSHs)
df.ssb$quant <- 'ssb'
df.rec <- rec(NSHs)
df.rec$quant <- 'rec'
df.fbar <- fbar(NSHs)
df.fbar$quant <- 'fbar'

df.plot <- rbind(df.ssb,df.rec,df.fbar)

prefix <- 'sf'
setwd(file.path("report",prefix))

taf.png(paste0(prefix,"_runs Q1 DATRAS"))

print(ggplot(subset(df.plot,year >= 2002 & year <= 2025),aes(x=year,y=value,col=name))+
  theme_bw()+
  geom_line()+
  ylim(0,NA)+
  facet_wrap(~quant,scales='free',ncol=1))

dev.off()

setwd('../..')
