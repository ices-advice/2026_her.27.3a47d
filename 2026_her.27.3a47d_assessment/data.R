# path <- file.path(".","bootstrap","initial","data")
# 
# new_data <- read.csv(file.path(path,'catch_data','30_updated_nsas_input_fleet_2000-2024.csv'))
# new_data$nsas_canum <- new_data$nsas_canum_1000/1000
# new_data$nsas_caton <- new_data$nsas_canum*new_data$weca_kg
# new_data <- new_data %>% select(-c(nsas_canum_1000))
# new_data$wr[new_data$wr == '8+'] <- '8'
# 
# new_data <- new_data %>%
#             arrange(year,fleet,wr,nsas_canum,weca_kg,nsas_caton) %>%
#             rename(
#               Fleet = fleet,
#               numbers = nsas_canum,
#               weight = weca_kg,
#               catch = nsas_caton)
# 
# t <- read.csv(file.path(path,'canum_mf.csv'))
# # t <- t %>% select(-c(X))
# # write.csv(t,file.path(path,'canum_mf.csv'),row.names = F)
# # unique(t$year)
# t <- subset(t,!(wr %in% unique(new_data$wr) & year %in% unique(new_data$year) & Fleet %in% unique(new_data$Fleet)))
# 
# t <- rbind(t,new_data)
# t <- t %>% arrange(year,Fleet,wr)
# # t <- t %>% relocate(year,wr,Fleet)
# 
# t <- subset(t,Fleet != 'total')
# 
# write.csv(x=t,
#           file=file.path(path,'canum_mf_alt.csv'),
#           row.names = F)


source("data_construct_M.R")
source("data_construct_input.R")
#source("data_construct_input_mf.R")
source("data_export.R")
