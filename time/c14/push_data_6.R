library(openxlsx)
library(bibtex)
library(RefManageR)
library(rcrossref)
library(purrr)
library(dplyr)
library(Bchron)

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

lcul_col <- list(# colors
  EM = "#0000CF", # BLUE
  MM = "#1D1DFF", # 
  LM = "#3737FF", # 
  LMEN = "#6A6AFF", #  
  UM = "#8484FF", #
  EN = "#FF1B1B", # RED
  EMN = "#FF541B", # 
  MN = "#FF8D1B", # 
  LN = "#FFC04D", # 
  UN = "#E7E700" # NEO UNDEF.
) 

intCal <- 'intcal20'

path.data <-"C:/Rprojects/C14/neonet/"                  # work with C14/
path.data.publi <- paste0(path.data,"publi/")
output.path <- "C:/Rprojects/neonet/inst/extdata/joad/" # export to neonet/


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

# c14doi.to.shinyapp <- T

# if(c14doi.to.shinyapp){
c14doi.to.shinyapp <- function(){
  # get the published TSV and convert for the Shinyapp format
  # read C14 dataset TSV
  df <- read.csv(paste0(path.data.publi, "140_140_id00140_doc_elencoc14.tsv"),
                            sep = '\t', header = TRUE)
  # clean
  df <- df[df$Period %in% names(lcul_col), ] # only selected periods
  df <- df[!is.na(df$Period), ]
  # read references BIB
  c14.bibrefs <- paste0(path.data.publi, "id00140_doc_reference.bib")
  bib <- read.bib(c14.bibrefs)
  
  # write.table(c14.dataset, paste0(path.data.publi,"c14data.tsv"), sep="\t", row.names=FALSE)
}


# fich <- "NeoNet_rvTH_9.xlsx" # whith special characters + Nicco data
# df <- openxlsx::read.xlsx(paste0(path.data, fich), skipEmptyRows=TRUE)
# df <- df[!is.na(df$inTime) & !is.na(df$inSpace), ]

c14data.select <- F
if(c14data.select){
  # TODO: change BDA.select to NEONET,
  # etc. 
  ws_roi.shp <- st_read(dsn = paste0(c14.path, "neonet"),
                        layer = "wsh_roi")
  # by time
  BDA.select <- BDA.select[BDA.select$C14BP <= 8000 & BDA.select$C14BP >= 5000, ]
  BDA.select <- as.data.frame(BDA.select)
  # by ROI
  coordinates(BDA.select) <- ~ Longitude + Latitude # get coords for RTB
  BDA.select <- st_as_sf(BDA.select)
  st_crs(BDA.select) <- "+init=epsg:4326"
  BDA.select$Longitude <- BDA.select$Latitude <- NA
  BDA.select.sp <- as(BDA.select, "Spatial")
  # recover
  for(i in 1:nrow(BDA.select)){
    # i <- 1
    # if(i %% 500 == 0){print(i)}
    BDA.select.sp[i, "Longitude"] <- as.vector(BDA.select.sp@coords[i,1])
    BDA.select.sp[i, "Latitude"] <- as.vector(BDA.select.sp@coords[i,2])
  }
  BDA.select <- st_as_sf(BDA.select.sp)
  # BDA.select <- do.call(rbind, st_geometry(BDA.select)) %>% 
  #     as_tibble() %>% setNames(c("Longitude","Latitude"))
  # intersects.list <- st_intersection(BDA.original, ws_roi.shp)
  BDA.select.roi <- BDA.select %>% mutate(
    intersection = as.integer(st_intersects(geometry, ws_roi.shp)),
    area = if_else(is.na(intersection), '', ws_roi.shp$cat1[intersection])
  ) 
  # save only intersection = 1
  BDA.select.roi <- BDA.select.roi[!is.na(BDA.select.roi$intersection), ]
  BDA.select.roi$geometry <- BDA.select.roi$intersection <- BDA.select.roi$area <- NULL
}

# if(c14data.to.github){
#   # create .tsv from the .xlsx file to be
#   # put file on GitHub
#   write.table(df,"neonet/c14data.tsv", sep="\t", row.names=FALSE)
# }

# if(c14ref.to.github){
c14ref.to.github <- function(df, bib){
  # recalcultate the "long.ref" value from DOIs for unique references if exists
  # or BibTex entries (file 'references_xx.bib')
  # a shorter df for uniques references
  uniq.refs <- unique(df[c("bib", "bib_url")])
  # rename fields
  names(uniq.refs) <- c("short.ref","key.or.doi")
  # by default 
  uniq.refs$long.ref <- uniq.refs$key.or.doi
  # wit DOIs if exist
  uniq.refs <- uniq.refs[with(uniq.refs, order(key.or.doi)), ]
  # 
  for(i in 1:nrow(uniq.refs)){
    # i <- 1
    flag <- 0
    a.ref <- uniq.refs[i,"key.or.doi"]
    # a.ref <- "10.4312/dp.46.22"
    print(paste0("[", as.character(i), "] ", a.ref))
    # BibTex - - - - - - - - - - - - - - - - - -
    if(grepl("^[[:upper:]]", a.ref)){
      a.bibref <- capture.output(print(bib[c(a.ref)]))
      a.citation <- paste0(a.bibref, collapse = " ")
      uniq.refs[i, "long.ref"] <- a.citation
      flag <- 1
    }
    # DOIs (all start with '10.') - - - - - - - -
    # a.ref <- "10.1016/j.quaint.2017.05.027"
    if(grepl("^10\\.", a.ref)){
      tryCatch(
        expr = {
          # # OR
          # uniq.refs[i, "long.ref"] <- cr_cn(a.ref, format = "text") %>%
          #   map_chr(., pluck, 1)
          # OR
          uniq.refs[i, "long.ref"] <- as.character(GetBibEntryWithDOI(paste0("https://doi.org/",a.ref)))
        },
        error = function(e){
          print("  - error -> 'MISSING REF'")
          uniq.refs[i, "long.ref"] <- "MISSING REF"
        },
        warning=function(cond) {
          # uniq.refs[i, "reference"] <- "a.ref" # not working
          print("  - DOI not recover")
        })
      flag <- 1
    }
    # others
    if(flag == 0){
      uniq.refs[i, "long.ref"] <- "MISSING REF"
    }
  }
  # print(getwd())
  # # write
  # write.table(uniq.refs, paste0(path.data.publi,"c14refs.tsv"), sep="\t", row.names=FALSE)
}

c14.material.life <- function(){
  mat.life.url <- '140_id00140_doc_thesaurus.tsv'
  material.life.duration <- read.csv(paste0(path.data.publi, mat.life.url), sep = "\t")
  short.life <- subset(material.life.duration, life.duration == 'short.life')
  long.life <- subset(material.life.duration, life.duration == 'long.life')
  other.life <- material.life.duration[is.na(material.life.duration$life.duration),]
  family.life <- c(rep("short.life",nrow(short.life)),
                   rep("long.life",nrow(long.life)),
                   rep("other.life",nrow(other.life)))
  type.life <- c(short.life$material.type,
                 long.life$material.type,
                 other.life$material.type)
  material.life <- data.frame(family.life=family.life,
                              type.life=type.life)
  short.life <- as.character(material.life[material.life$family.life == "short.life", "type.life"])
  long.life <- as.character(material.life[material.life$family.life == "long.life", "type.life"])
  other.life <- as.character(material.life[material.life$family.life == "other.life", "type.life"])
  df$mat.life <- ifelse(df$Material %in%  short.life, "short life",
                        ifelse(df$Material %in%  long.life,"long life","others"))
}

# if(join.c14data.and.c14ref){
join.c14data.and.c14ref <- function(df, uniq.refs){
  # merge C14 data and references
  df.tot <- merge(df, uniq.refs, by.x="bib_url", by.y="key.or.doi", all.x = T)
  colnames(df.tot)[which(names(df.tot) == "long.ref")] <- "bib"
  colnames(df.tot)[which(names(df.tot) == "C14BP")] <- "C14Age"
  # calculate tpq/taq
  df.tot$taq <- df.tot$tpq <- df.tot$colors <- NA
  for (i in 1:nrow(df.tot)){
  # for (i in 1500:1700){
    # i <- 1
    if(i %% 50 == 0) print(paste0(as.character(i),"/", as.character(nrow(df.tot))))
    # add HTTPS to DOIs
    if (grepl("^10\\.", df.tot[i, "bib_url"])){
      df.tot[i, "bib_url"] <- paste0("https://doi.org/",df.tot[i, "bib_url"])
    }
    # calibration
    ages1 = BchronCalibrate(ages = df.tot[i,"C14Age"],
                            ageSds = df.tot[i,"C14SD"],
                            calCurves = intCal,
                            ids = 'Date1')
    df.tot[i,"tpq"] <- -(min(ages1$Date1$ageGrid) - 1950)  
    df.tot[i,"taq"] <- -(max(ages1$Date1$ageGrid) - 1950) 
  }
  # message pas grave (?):
  # Warning message:
  #   In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  :
  #             EOF within quoted string
  # - - - - - - - - - -- -
  # save in the Shiny app folder (git folder)
  # getwd()
  # reorder
  for (i in seq(1, nrow(df.tot))){
    # colors
    per.color <- as.character(lcul_col[df.tot[i, "Period"]])
    df.tot[i,"colors"] <- per.color
    # popup notification
    desc <- paste(sep = "<br/>",
                  paste0("<b>", df.tot[i,"SiteName"],"</b> / ",
                         df.tot[i,"Material"]," (", df.tot[i,"mat.life"],")"),
                  paste0("date: ", df.tot[i,"C14Age"], " +/- ", df.tot[i,"C14SD"],
                         " BP [", df.tot[i,"LabCode"],"]"),
                  paste0("tpq/taq: ", df.tot[i,"tpq"], " to ", df.tot[i,"taq"],
                         " cal BC"),
                  paste0("<span style='color: ", df.tot[i,"colors"],";'><b>", df.tot[i,"Period"], "</b></span>  ",
                         #paste0("period: ", df.tot[i,"Period"],
                         " <b>|</b> PhaseCode: <i>", df.tot[i,"PhaseCode"],
                         "</i> <br/>"))
    if(grepl("^http", df.tot[i,"bib_url"])){
      # for href, if exist
      desc <- paste0(desc, 'ref: <a href=', shQuote(paste0(df.tot[i, 'bib_url'])),
                     "\ target=\"_blank\"", ">", df.tot[i, 'bib'], "</a>")
    } else {desc <- paste0(desc, "ref: ", df.tot[i, "bib"])}
    df.tot[i, "lbl"]  <- desc
  }
  df.tot$locationID <- df.tot$LabCode
  df.tot$secondLocationID <- paste(rownames(df.tot), "_selectedLayer", sep = "")
  df.tot$idf <- 1:nrow(df.tot)
  df.tot <- df.tot[,c("SiteName", "Country", "Period", "PhaseCode",
                      "LabCode", "C14Age", "C14SD", 
                      "Material", "MaterialSpecies", "mat.life",
                      "tpq", "taq", 
                      "Longitude", "Latitude", 
                      "bib", "bib_url", "locationID", "secondLocationID",
                      "lbl", "idf",
                      "colors"
  )]
  # # change Material to fit it to c14bazAAR thesaurus
  # df.tot$Material[df.tot$Material=="CE"]<-"cereal"
  # df.tot$Material[df.tot$Material=="H"]<-"bone (human)"
  # df.tot$Material[df.tot$Material=="F"]<-"fauna"
  # df.tot$Material[df.tot$Material=="OR"]<-"organic"
  # df.tot$Material[df.tot$Material=="SE"]<-"plant seed"
  # df.tot$Material[df.tot$Material=="SH"]<-"shell"
  # df.tot$Material[df.tot$Material=="WC"]<-"wood charcoal"
  # "n/a" was already OK
  # write.csv(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
  # TODO: encode in UTF-8 ??
  # write.table(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
}
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
