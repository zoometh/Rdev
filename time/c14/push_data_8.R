# library(openxlsx)
# library(bibtex)
# library(RefManageR)
# library(rcrossref)
# library(purrr)
# library(dplyr)
# library(Bchron)

# lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("R/neo_subset.R")
source("R/neo_bib.R")
source("R/neo_matlife.R")
source("R/neo_calc.R")


# c14
data.c14 <- "neonet/NeoNet_atl_ELR (1).xlsx"
data.bib <- paste0(getwd(), "/neonet/NeoNet_atl_ELR.bib")
df.c14 <- openxlsx::read.xlsx(data.c14)
df.c14 <- df.c14[df.c14$Country == "France", ]
df.c14 <- neo_subset(df.c14)

# getwd()

## - - - - - - - - - - - - - - - - - - - - - - -
## Prepare data for Rshiny app data

# setwd("C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/")

# c14data.to.github <- T # from .xlsx, create c14data.tsv -> GitHub
# c14ref.to.github <- T #
# join.c14data.and.c14ref <- T

# references.bib <- "references.bib"
# references.bib <- "references_OK.bib"
# references.bib <- "references_OK_2.bib"
# references.bib <- "references_OK_4.bib"

# verbose <- T


# lcul_col <- list(# colors
#   EM = "#0000CF", # BLUE
#   MM = "#1D1DFF", #
#   LM = "#3737FF", #
#   LMEN = "#6A6AFF", #
#   UM = "#8484FF", #
#   EN = "#FF1B1B", # RED
#   EMN = "#FF541B", #
#   MN = "#FF8D1B", #
#   LN = "#FFC04D", #
#   UN = "#E7E700" # NEO UNDEF.
# )


# path.data <-"C:/Rprojects/Rdev/time/c14/neonet/"                  # work with C14/



# bib

# out
# path.data.publi <- paste0(path.data, "publi/")
# output.path <- paste0(path.data.publi, "publi/") # export to neonet/


df.c14 <- neo_bib(df.c14, data.bib)
# View(head(df.c14, 50))
ref.mat.life <- read.csv(paste0(getwd(), '/neonet/publi/140_id00140_doc_thesaurus.tsv'), sep = "\t")
df.c14 <- neo_matlife(df.c14, ref.mat.life)
View(df.c14)

# references.bib <- "references_OK_7.bib"
# gh.master <- 'https://raw.github.com/zoometh/C14/master/' # github 'C14' folder
# gt.master <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/"
# gs.master <- paste0(getwd(), "/shinyapp/")
#gh.master <- paste0(getwd(),"/") # working folder
# out.folder <- "D:/Cultures_9/Neolithique/web/" # app folder
# ggschol.h <- "https://scholar.google.com/scholar"
# path.data <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Desktop/NeoNet/"
# fich <- "14C_DATES_v3_France_8.xlsx"
# fich <- "14C_DATES_v3_France_11.xlsx" # prb with special characters
# fich <- "14C_DATES_v3_France_15.xlsx" # without special characters
# fich <- "_NeoNet_BDAmissingLabCode_6.xlsx" # whith special characters
# fich <- "_NeoNet_BDAmissingLabCode_9.xlsx" # whith special characters + Nicco data


# fich <- "NeoNet_rvTH_9.xlsx" # whith special characters + Nicco data
# df <- openxlsx::read.xlsx(paste0(path.data, fich), skipEmptyRows=TRUE)
# df <- df[!is.na(df$inTime) & !is.na(df$inSpace), ]

# c14data.select <- F
# if(c14data.select){
#   # TODO: change BDA.select to NEONET,
#   # etc.
#   ws_roi.shp <- st_read(dsn = paste0(c14.path, "neonet"),
#                         layer = "wsh_roi")
#   # by time
#   BDA.select <- BDA.select[BDA.select$C14BP <= 8000 & BDA.select$C14BP >= 5000, ]
#   BDA.select <- as.data.frame(BDA.select)
#   # by ROI
#   coordinates(BDA.select) <- ~ Longitude + Latitude # get coords for RTB
#   BDA.select <- st_as_sf(BDA.select)
#   st_crs(BDA.select) <- "+init=epsg:4326"
#   BDA.select$Longitude <- BDA.select$Latitude <- NA
#   BDA.select.sp <- as(BDA.select, "Spatial")
#   # recover
#   for(i in 1:nrow(BDA.select)){
#     # i <- 1
#     # if(i %% 500 == 0){print(i)}
#     BDA.select.sp[i, "Longitude"] <- as.vector(BDA.select.sp@coords[i,1])
#     BDA.select.sp[i, "Latitude"] <- as.vector(BDA.select.sp@coords[i,2])
#   }
#   BDA.select <- st_as_sf(BDA.select.sp)
#   # BDA.select <- do.call(rbind, st_geometry(BDA.select)) %>%
#   #     as_tibble() %>% setNames(c("Longitude","Latitude"))
#   # intersects.list <- st_intersection(BDA.original, ws_roi.shp)
#   BDA.select.roi <- BDA.select %>% mutate(
#     intersection = as.integer(st_intersects(geometry, ws_roi.shp)),
#     area = if_else(is.na(intersection), '', ws_roi.shp$cat1[intersection])
#   )
#   # save only intersection = 1
#   BDA.select.roi <- BDA.select.roi[!is.na(BDA.select.roi$intersection), ]
#   BDA.select.roi$geometry <- BDA.select.roi$intersection <- BDA.select.roi$area <- NULL
# }

# if(c14data.to.github){
#   # create .tsv from the .xlsx file to be
#   # put file on GitHub
#   write.table(df,"neonet/c14data.tsv", sep="\t", row.names=FALSE)
# }



# mat_life_duration <- function(df, ref.mat.life){
#   # 3 types
#   short.life <- subset(ref.mat.life, life.duration == 'short.life')
#   long.life <- subset(ref.mat.life, life.duration == 'long.life')
#   other.life <- ref.mat.life[is.na(ref.mat.life$life.duration),]
#   # dataframe
#   family.life <- c(rep("short.life", nrow(short.life)),
#                    rep("long.life", nrow(long.life)),
#                    rep("other.life", nrow(other.life)))
#   type.life <- c(short.life$material.type,
#                  long.life$material.type,
#                  other.life$material.type)
#   material.life <- data.frame(family.life = family.life,
#                               type.life = type.life)
#   #
#   short.life <- as.character(material.life[material.life$family.life == "short.life", "type.life"])
#   long.life <- as.character(material.life[material.life$family.life == "long.life", "type.life"])
#   other.life <- as.character(material.life[material.life$family.life == "other.life", "type.life"])
#   df$mat.life <- ifelse(df$Material %in%  short.life, "short life",
#                         ifelse(df$Material %in%  long.life,"long life","others"))
#   return(df)
# }


# ref.mat.life <- read.csv(paste0(getwd(), '/neonet/publi/140_id00140_doc_thesaurus.tsv'), sep = "\t")
# df.c14.mat <- mat_life_duration(df.c14, ref.mat.life)
# View(df.c14.mat)

# if(join.c14data.and.c14ref){
# df_calc <- function(df.c14,
#                     intCal = 'intcal20',
#                     Present = 1950,
#                     ref.period = "https://raw.githubusercontent.com/zoometh/neonet/main/inst/extdata/periods.tsv",
#                     verbose = TRUE,
#                     verbose.freq = 50){
#   # calculate tpq/taq
#   df.c14$taq <- df.c14$tpq <- df.c14$colors <- NA
#   for (i in 1:nrow(df.c14)){
#     # for (i in 1500:1700){
#     # i <- 1
#     if(verbose){
#       if(i %% verbose.freq == 0) {
#         print(paste0(as.character(i), "/", as.character(nrow(df.c14))))
#       }
#     }
#     # # add HTTPS to DOIs
#     # if (grepl("^10\\.", df.c14[i, "bib_url"])){
#     #   df.c14[i, "bib_url"] <- paste0("https://doi.org/",df.c14[i, "bib_url"])
#     # }
#     # calibration
#     ages1 <- BchronCalibrate(ages = df.c14[i, "C14Age"],
#                              ageSds = df.c14[i, "C14SD"],
#                              calCurves = intCal,
#                              ids = 'Date1')
#     df.c14[i, "tpq"] <- -(min(ages1$Date1$ageGrid) - Present)
#     df.c14[i, "taq"] <- -(max(ages1$Date1$ageGrid) - Present)
#   }
#   # message pas grave (?):
#   # Warning message:
#   #   In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  :
#   #             EOF within quoted string
#   # - - - - - - - - - -- -
#   # save in the Shiny app folder (git folder)
#   # getwd()
#   # reorder
#
#   for (i in seq(1, nrow(df.c14))){
#     # colors
#     per.color <- as.character(periods.colors[periods.colors$period == df.c14[i, "Period"], "color"])
#     # per.color <- as.character(lcul_col[df.c14[i, "Period"]])
#     if(is.na(per.color)){
#       per.color <- "#808080"
#     }
#     df.c14[i, "colors"] <- per.color
#     # popup notification
#     desc <- paste(sep = "<br/>",
#                   paste0("<b>", df.c14[i,"SiteName"],"</b> / ",
#                          df.c14[i,"Material"]," (", df.c14[i,"mat.life"],")"),
#                   paste0("date: ", df.c14[i,"C14Age"], " +/- ", df.c14[i,"C14SD"],
#                          " BP [", df.c14[i,"LabCode"],"]"),
#                   paste0("tpq/taq: ", df.c14[i,"tpq"], " to ", df.c14[i,"taq"],
#                          " cal BC"),
#                   paste0("<span style='color: ", df.c14[i,"colors"],";'><b>", df.c14[i,"Period"], "</b></span>  ",
#                          #paste0("period: ", df.c14[i,"Period"],
#                          " <b>|</b> PhaseCode: <i>", df.c14[i,"PhaseCode"],
#                          "</i> <br/>"))
#     if(grepl("^http", df.c14[i,"bib_url"])){
#       # for href, if exist
#       desc <- paste0(desc, 'ref: <a href=', shQuote(paste0(df.c14[i, 'bib_url'])),
#                      "\ target=\"_blank\"", ">", df.c14[i, 'bib'], "</a>")
#     } else {desc <- paste0(desc, "ref: ", df.c14[i, "bib"])}
#     df.c14[i, "lbl"]  <- desc
#   }
#   df.c14$locationID <- df.c14$LabCode
#   df.c14$secondLocationID <- paste(rownames(df.c14), "_selectedLayer", sep = "")
#   df.c14$idf <- 1:nrow(df.c14)
#   df.c14 <- df.c14[ , c("SiteName", "Country", "Period", "PhaseCode",
#                         "LabCode", "C14Age", "C14SD",
#                         "Material", "MaterialSpecies", "mat.life",
#                         "tpq", "taq",
#                         "Longitude", "Latitude",
#                         "bib", "bib_url", "locationID", "secondLocationID",
#                         "lbl", "idf",
#                         "colors"
#   )]
#   return(df.c14)
#   # # change Material to fit it to c14bazAAR thesaurus
#   # df.tot$Material[df.tot$Material=="CE"]<-"cereal"
#   # df.tot$Material[df.tot$Material=="H"]<-"bone (human)"
#   # df.tot$Material[df.tot$Material=="F"]<-"fauna"
#   # df.tot$Material[df.tot$Material=="OR"]<-"organic"
#   # df.tot$Material[df.tot$Material=="SE"]<-"plant seed"
#   # df.tot$Material[df.tot$Material=="SH"]<-"shell"
#   # df.tot$Material[df.tot$Material=="WC"]<-"wood charcoal"
#   # "n/a" was already OK
#   # write.csv(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
#   # TODO: encode in UTF-8 ??
#   # write.table(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
# }




View(df.tot[sample(1:nrow(df.tot),25), ])
write.table(df.tot, paste0(output.path, "c14_dataset.tsv"),
            sep="\t",
            row.names=FALSE)
write.table(c14.bibrefs, paste0(output.path, "references.bib"),
            sep="\t",
            row.names=FALSE)
write.table(material.life.duration, paste0(output.path, "c14_material_life.tsv"),
            sep="\t",
            row.names=FALSE)
