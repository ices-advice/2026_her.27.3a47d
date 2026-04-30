install.packages(c("icesTAF",
                   'patchwork',
                   'tidyverse',
                   'corrplot',
                   'mvtnorm',
                   'remotes',
                   'TMB',
                   'doParallel',
                   'devtools',
                   'ggh4x',
                   'reshape2',
                   'icesDatras',
                   'icesSAG',
                   'maps',
                   'mapdata',
                   'ggplot2'), repos = c(
                     CRAN = "https://cloud.r-project.org/"))

remotes::install_github("flr/FLCore")
remotes::install_github("flr/ggplotFL")
remotes::install_github('fishfollower/SAM/stockassessment')
remotes::install_github("flr/FLSAM")
remotes::install_github("ices-tools-prod/msy")
remotes::install_github("DTUAqua/DATRAS/DATRAS")
remotes::install_github("casperwberg/surveyIndex/surveyIndex")

library(icesTAF)
taf.bootstrap(software=FALSE)