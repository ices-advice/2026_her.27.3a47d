## Prepare plots for report

## Before: results_sf.RData (model)
## After:  summary.png (report)

rm(list=ls())

library(icesTAF)
library(FLCore)
library(stockassessment)
library(FLSAM)
library(ggplot2)
library(reshape2)
library(tidyverse)
library(scales)
library(patchwork)

mkdir("report")

data.source     <- file.path(".", "bootstrap",'data')
data.source.init     <- file.path(".", "bootstrap",'initial','data')
data.save       <- file.path(".", "data")
model.save      <- file.path(".", "model")
output.save     <- file.path(".", "output")

SMSkeyRuns  <- 2023
runName <- 'NSAS_HAWG2026'

NSH.tun   <- readFLIndices(file.path(data.source,"fleet.txt"))

year <- c(2018,2019,2021,2022,2023,2024,2025,2026)

IBTSQ1.FLR <- new('FLIndices')
IBTSQ3.FLR <- new('FLIndices')

# fill in indices from DATRAS
IBTSQ1.DATRAS <- read.csv(file.path(data.source.init,'DATRAS_IBTSQ1.csv'))


dmns        <- dimnames(NSH.tun$`IBTS-Q1`)
temp    <- FLQuant(NA, # iterations
                   dimnames=dmns)
tab <- subset(IBTSQ1.DATRAS,IndexArea == 'NS_Her') %>% select(c('Age_1','Age_2','Age_3','Age_4','Age_5','Age_6'))
temp[] <- t(tab)

idx.tab <- tab %>% select(-c('Age_6'))
idx.tab$dummy <- 1
idx.tab <- idx.tab %>% 
  select(dummy, everything())

write.table(round(idx.tab, digits = 2), file.path(data.source.init,"IBTSQ1_DATRAS.txt"), sep=" ",row.names = FALSE,col.names=FALSE)

IBTSQ1.FLR[['DATRAS']] <- FLIndex(index=temp)

IBTSQ3.DATRAS <- read.csv(file.path(data.source.init,'DATRAS_IBTSQ3.csv'))
dmns        <- dimnames(NSH.tun$`IBTS-Q3`)
temp    <- FLQuant(NA, # iterations
                   dimnames=dmns)
tab <- subset(IBTSQ3.DATRAS,IndexArea == 'NS_Her') %>% select(c('Age_0','Age_1','Age_2','Age_3','Age_4','Age_5','Age_6'))
temp[] <- t(tab)

IBTSQ3.FLR[['DATRAS']] <- FLIndex(index=temp)

# fill in modelled indices
flagFirst <- T
for(idxYear in year){
  IBTSQ3 <- read.table(file.path(file.path(data.source.init,'old_standardized_index',idxYear,'IBTSQ3_output.txt')))
  IBTSQ3 <- IBTSQ3[,2:dim(IBTSQ3)[2]]
  colnames(IBTSQ3) <- paste0('age.',0:(dim(IBTSQ3)[2]-1))
  IBTSQ3$year <- 1998:(idxYear-1)
  IBTSQ3$HAWG <- idxYear
  IBTSQ3$survey <- 'IBTSQ3'
  
  dmns        <- dimnames(NSH.tun$`IBTS-Q3`)
  dmns$year <-  ac(1998:(idxYear-1))
  temp    <- FLQuant(NA, # iterations
                     dimnames=dmns)
  
  temp[] <- t(IBTSQ3[,1:7])
  IBTSQ3.FLR[[ac(idxYear)]] <- FLIndex(index=temp)
  
  IBTSQ1 <- read.table(file.path(file.path(data.source.init,'old_standardized_index',idxYear,'IBTSQ1_output.txt')))
  IBTSQ1 <- IBTSQ1[,2:dim(IBTSQ1)[2]]
  colnames(IBTSQ1) <- paste0('age.',1:dim(IBTSQ1)[2])
  IBTSQ1$year <- 1984:idxYear
  IBTSQ1$HAWG <- idxYear
  IBTSQ1$survey <- 'IBTSQ1'
  
  dmns        <- dimnames(NSH.tun$`IBTS-Q1`)
  dmns$year <-  ac(1984:idxYear)
  temp    <- FLQuant(array( NA,
                            dim=c(length(dmns$age),
                                  length(dmns$year),
                                  1,
                                  1,
                                  1,
                                  1)), # iterations
                            dimnames=dmns)
  
  tab <- IBTSQ1 %>% select(c('age.1','age.2','age.3','age.4','age.5','age.6'))
  temp[] <- t(tab)
  
  IBTSQ1.FLR[[ac(idxYear)]] <- FLIndex(index=temp)
  
  if(flagFirst){
    IBTSQ1.all <- rbind(IBTSQ1)
    IBTSQ3.all <- rbind(IBTSQ3)
    flagFirst <- F
  }else{
    IBTSQ1.all <- rbind(IBTSQ1.all,IBTSQ1)
    IBTSQ3.all <- rbind(IBTSQ3.all,IBTSQ3)
  }
}

prefix <- 'input'
setwd(file.path("report",prefix))

taf.png(paste0(prefix,"_IBTSQ3 internal DATRAS"))
plot(IBTSQ3.FLR[["DATRAS"]][ac(0:5),],type="internal")
dev.off()

taf.png(paste0(prefix,"_IBTSQ3 internal model"))
plot(IBTSQ3.FLR[["2026"]][ac(0:5),],type="internal")
dev.off()

taf.png(paste0(prefix,"_IBTSQ1 internal DATRAS"))
plot(IBTSQ1.FLR[["DATRAS"]][ac(1:5),],type="internal")
dev.off()

taf.png(paste0(prefix,"_IBTSQ1 internal model"))
plot(IBTSQ1.FLR[["2026"]][ac(1:5),],type="internal")
dev.off()

# apply z-norm
for(surveyCurrent in names(IBTSQ1.FLR)){
  # z-norm
  IBTSQ1.FLR[[surveyCurrent]]@index <- sweep(sweep(IBTSQ1.FLR[[surveyCurrent]]@index,1,yearMeans(IBTSQ1.FLR[[surveyCurrent]]@index),'-'),1,apply(IBTSQ1.FLR[[surveyCurrent]]@index,1,sd,na.rm=TRUE),'/')
}

for(surveyCurrent in names(IBTSQ3.FLR)){
  # z-norm
  IBTSQ3.FLR[[surveyCurrent]]@index <- sweep(sweep(IBTSQ3.FLR[[surveyCurrent]]@index,1,yearMeans(IBTSQ3.FLR[[surveyCurrent]]@index),'-'),1,apply(IBTSQ3.FLR[[surveyCurrent]]@index,1,sd,na.rm=TRUE),'/')
}

taf.png(paste0(prefix,"_IBTSQ1 comp"))

df.plot <- as.data.frame(IBTSQ1.FLR)

print(ggplot(subset(df.plot,age == 1 & slot == 'index' & cname %in% c('2026','DATRAS')),aes(x=year,y=data,col=cname))+
  theme_bw()+
  ggtitle('IBTS-Q1 DATRAS/model comparison')+
  geom_line()+
    facet_wrap(~age,scales='free'))
dev.off()

taf.png(paste0(prefix,"_IBTSQ3 comp"))
df.plot <- as.data.frame(IBTSQ3.FLR)

print(ggplot(subset(df.plot,slot == 'index' & cname %in% c('2026','DATRAS')),aes(x=year,y=data,col=cname))+
  theme_bw()+
  geom_line()+
  ggtitle('IBTS-Q3 DATRAS/model comparison')+
  facet_wrap(~age,scales='free'))
dev.off()

# retro plot IBTSQ3
taf.png(paste0(prefix,"_IBTSQ3 retro"))
df.plot <- as.data.frame(IBTSQ3.FLR)
print(ggplot(subset(df.plot,slot == 'index' & cname != c('DATRAS')),aes(x=year,y=data,col=cname))+
        theme_bw()+
        geom_line()+
        ggtitle('IBTS-Q3 retro')+
        facet_wrap(~age,scales='free'))
dev.off()

# retro plot IBTSQ1
taf.png(paste0(prefix,"_IBTSQ1 retro"))

df.plot <- as.data.frame(IBTSQ1.FLR)

print(ggplot(subset(df.plot,age == 1 & slot == 'index' & cname != c('DATRAS')),aes(x=year,y=data,col=cname))+
        theme_bw()+
        ggtitle('IBTS-Q1 retro')+
        geom_line()+
        facet_wrap(~age,scales='free'))
dev.off()


setwd('../..')
