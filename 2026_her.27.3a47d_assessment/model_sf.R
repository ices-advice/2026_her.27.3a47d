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

runName <- 'NSAS_HAWG2026_sf'

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

load(file.path(data.save,paste0("data_sms",SMSkeyRuns,"_sf.RData")))  # NSH, NSH.tun

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
### run single fleet retro
### ============================================================================

if(retroFlag){
  # retro
  n.retro.years <- 10  # Number of years for which to run the retrospective
  NSH.ctrl@residuals <- FALSE
  NSH.retro <- retro(NSH, NSH.tun, NSH.ctrl, retro=n.retro.years)
  
  save(NSH.retro,
       file=file.path(model.save,paste0(runName,'_retro.RData')))
}


# df.plot <- ssb(NSH.retro)
# 
# ggplot(subset(df.plot,year > 2000),aes(x=year,y=value,col=name))+
#   geom_line()


### ============================================================================
### compare model runs
### ============================================================================
# 
# load(file.path(model.save,paste0('NSAS_HAWG2026_sf','.RData')))  # NSH, NSH.tun, NSH.ctrl, NSH.sam
# 
# NSHs <- new('FLSAMs')
# 
# NSHs[['0904_update']] <- NSH.sam
# 
# F01.update <- as.data.frame(quantMeans(NSH@harvest[ac(0,1),]))
# F01.update$name <- '0904_update'
# 
# IBTSQ1.update <- NSH.tun$`IBTS-Q1`
# 
# IBTSQ1.update@index <- sweep(sweep(IBTSQ1.update@index,1,yearMeans(IBTSQ1.update@index),'-'),1,apply(IBTSQ1.update@index,1,sd,na.rm=TRUE),'/')
# 
# IBTSQ1.update <- as.data.frame(IBTSQ1.update@index)
# IBTSQ1.update$name <- '0904_update'
# 
# load(file.path(model.save,paste0('NSAS_HAWG2026_sf_old','.RData')))  # NSH, NSH.tun, NSH.ctrl, NSH.sam
# 
# NSHs[['HAWG_run']] <- NSH.sam
# F01.HAWG <- as.data.frame(quantMeans(NSH@harvest[ac(0,1),]))
# F01.HAWG$name <- 'HAWG_run'
# 
# F01.plot <- rbind(F01.update,F01.HAWG)
# 
# IBTSQ1.HAWG <- NSH.tun$`IBTS-Q1`
# 
# IBTSQ1.HAWG@index <- sweep(sweep(IBTSQ1.HAWG@index,1,yearMeans(IBTSQ1.HAWG@index),'-'),1,apply(IBTSQ1.HAWG@index,1,sd,na.rm=TRUE),'/')
# 
# IBTSQ1.HAWG <- as.data.frame(IBTSQ1.HAWG@index)
# IBTSQ1.HAWG$name <- 'HAWG_run'
# 
# IBTSQ1.plot <- rbind(IBTSQ1.update,IBTSQ1.HAWG)
# 
# df.ssb <- ssb(NSHs)
# df.ssb$quant <- 'ssb'
# df.rec <- rec(NSHs)
# df.rec$quant <- 'rec'
# df.fbar <- fbar(NSHs)
# df.fbar$quant <- 'fbar'
# 
# df.plot <- rbind(df.ssb,df.rec,df.fbar)
# 
# prefix <- 'sf'
# mkdir(file.path("report",prefix))
# setwd(file.path("report",prefix))
# 
# taf.png(paste0(prefix,"_runs update"))
# 
# print(ggplot(subset(df.plot,year >= 2002 & year <= 2025),aes(x=year,y=value,col=name))+
#         theme_bw()+
#         geom_line()+
#         ylim(0,NA)+
#         facet_wrap(~quant,scales='free',ncol=1))
# 
# dev.off()
# 
# 
# taf.png(paste0(prefix,"_F01 update"))
# 
# print(ggplot(subset(F01.plot,year >= 2002 & year <= 2025),aes(x=year,y=data,col=name))+
#         theme_bw()+
#         geom_line()+
#         ylim(0,NA)+
#         ylab('F01'))
# 
# dev.off()
# 
# taf.png(paste0(prefix,"_IBTSQ1 update"))
# 
# print(ggplot(subset(IBTSQ1.plot,year >= 2002 & year <= 2025),aes(x=year,y=data,col=name))+
#         theme_bw()+
#         geom_line()+
#         ylab('IBTSQ1 z-norm'))
# 
# dev.off()
# 
# setwd('../..')

