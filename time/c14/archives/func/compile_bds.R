library(openxlsx)
# install.packages("c14bazAAR", repos = c(ropensci = "https://ropensci.r-universe.dev"))
library(c14bazAAR)
library(sf)

path <- "C:/Rprojects/C14/"


ws_atl.shp <- st_read(dsn = paste0(path, "neonet"),
                      layer = "wsh_atl")


c14.BD.equ <- read.xlsx(paste0(path, "docs/data/_equivalences_BD_short.xlsx"), 
                        skipEmptyRows = T)
NEONET <- read.xlsx(paste0(path, "docs/data/14C_DATES_NEONET_Portugal_v2_rvTH.xlsx"), 
                    skipEmptyRows = T)

BDA <- get_bda()
c14.BD.equ$DBA
BDA_sub <- BDA[, na.omit(c14.BD.equ$DBA)]
fields.to.add <- c14.BD.equ[is.na(c14.BD.equ$DBA), "NEONET"]
# c14.BD.equ[c14.BD.equ["DBA"] == names(BDA_sub), "NEONET"]
# setdiff(names(c14.BD.equ$NEONET), names(BDA_sub))
names(BDA_sub) <- c14.BD.equ$NEONET[!(c14.BD.equ$NEONET %in% fields.to.add)]
BDA_sub[, fields.to.add] <- NA
BDA_sub$BD <- "BDA"
NEONET$BD <- "NEONET"
# join
mergedDB <- rbind(NEONET, BDA_sub)
write.xlsx(mergedDB, paste0(path, "docs/data/_mergedDB_atlantic.xlsx"))