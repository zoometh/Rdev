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

c14data.to.github <- T # from .xlsx, create c14data.tsv -> GitHub 
c14ref.to.github <- T # 
join.c14data.and.c14ref <- T

# references.bib <- "references.bib"
# references.bib <- "references_OK.bib"
# references.bib <- "references_OK_2.bib"
# references.bib <- "references_OK_4.bib"
intCal <- 'intcal20'
references.bib <- "references_OK_7.bib"
gh.master <- 'https://raw.github.com/zoometh/C14/master/' # github 'C14' folder
# gt.master <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/"
# gs.master <- paste0(getwd(), "/shinyapp/")
#gh.master <- paste0(getwd(),"/") # working folder
# out.folder <- "D:/Cultures_9/Neolithique/web/" # app folder
ggschol.h <- "https://scholar.google.com/scholar"
# path.data <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Desktop/NeoNet/"
path.data <- paste0(getwd(),"/neonet/")
# fich <- "14C_DATES_v3_France_8.xlsx"
# fich <- "14C_DATES_v3_France_11.xlsx" # prb with special characters
# fich <- "14C_DATES_v3_France_15.xlsx" # without special characters
# fich <- "_NeoNet_BDAmissingLabCode_6.xlsx" # whith special characters
# fich <- "_NeoNet_BDAmissingLabCode_9.xlsx" # whith special characters + Nicco data


c14doi.to.shinyapp <- T

if(c14doi.to.shinyapp){
  # get published TSV and convert for the Shinyapp format
  path.data.publi <- paste0(path.data,"publi/")
  # read C14 dataset TSV
  df <- read.csv(paste0(path.data.publi, "140_140_id00140_doc_elencoc14.tsv"),
                            sep = '\t', header = TRUE)
  # read references BIB
  c14.bibrefs <- paste0(path.data.publi, "id00140_doc_reference.bib")
  bib <- read.bib(c14.bibrefs)
  
  # write.table(c14.dataset, paste0(path.data.publi,"c14data.tsv"), sep="\t", row.names=FALSE)
}


fich <- "NeoNet_rvTH_9.xlsx" # whith special characters + Nicco data
df <- openxlsx::read.xlsx(paste0(path.data, fich), skipEmptyRows=TRUE)
df <- df[!is.na(df$inTime) & !is.na(df$inSpace), ]

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

if(c14data.to.github){
  # create .tsv from the .xlsx file to be
  # put file on GitHub
  write.table(df,"neonet/c14data.tsv", sep="\t", row.names=FALSE)
}

if(c14ref.to.github){
  # for a .xlsx file of 14C
  # recalcultate the "long.ref" value from BibTex entries (file 'references_xx.bib')
  # or DOIs for unique references 
  # TODO: link with .xlsx file
  # df <- read.csv("neonet/c14data.tsv", sep="\t")
  bibrefs <- paste0(gs.master, references.bib)
  bib <- read.bib(bibrefs)
  # a shorter df for uniques references
  uniq.refs <- unique(df[c("bib", "bib_url")])
  # uniq.bib <- as.data.frame(unique(df$bib))
  names(uniq.refs) <- c("short.ref","key.or.doi")
  # # sample - - - - - - - -
  # uniq.refs <- uniq.refs[grepl("^10\\.", uniq.refs[, "ref"]), "ref"]
  # uniq.refs <- as.data.frame(uniq.refs)
  # names(uniq.refs)[1] <- "ref"
  # - - - - - - - - - - - -
  uniq.refs$long.ref <- uniq.refs$key.or.doi # by default
  # uniq.refs <- uniq.refs[order("key.or.doi"),] 
  uniq.refs <- uniq.refs[with(uniq.refs, order(key.or.doi)), ]
  # 
  for(i in 1:nrow(uniq.refs)){
    # i <- 1
    flag <- 0
    a.ref <- uniq.refs[i,"key.or.doi"]
    print(paste0("[", as.character(i), "] ", a.ref))
    # bibtex - - - - - - - - - - - - - - - - - -
    if(grepl("^[[:upper:]]", a.ref)){
      a.bibref <- capture.output(print(bib[c(a.ref)]))
      a.citation <- paste0(a.bibref, collapse = " ")
      uniq.refs[i, "long.ref"] <- a.citation
      flag <- 1
    }
    # dois (all start with '10.') - - - - - - - -
    # a.ref <- "10.1016/j.quaint.2017.05.027"
    if(grepl("^10\\.", a.ref)){
      tryCatch(
        expr = {
          uniq.refs[i, "long.ref"] <- cr_cn(a.ref, format = "text") %>%
            map_chr(., pluck, 1)
          # uniq.refs[i, "long.ref"] <- as.character(GetBibEntryWithDOI(paste0("https://doi.org/",a.ref)))
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
  print(getwd())
  write.table(uniq.refs,"neonet/c14refs.tsv", sep="\t", row.names=FALSE)
  references.df <- read.csv("neonet/c14refs.tsv", sep = "\t")
  View(references.df)
}

if(join.c14data.and.c14ref){
  # load .tsv from GitHub (C14/neonet/)
  # write to C14/shinyapp
  c14data.url <- paste0(gt.master, 'neonet/c14data.tsv') # write to local folder
  # c14data.url <- paste0(gh.master, 'neonet/c14data.tsv') # write to GH folder
  c14data <- read.csv(c14data.url, sep = "\t")
  # c14ref.url <- paste0(gh.master, 'neonet/c14refs.tsv') # write to GH folder
  c14ref.url <- paste0(gt.master, 'neonet/c14refs.tsv') # write to local folder
  c14ref <- read.csv(c14ref.url, sep = "\t")
  # merge on unique keys
  df.tot <- merge(c14data, c14ref, by.x="bib_url", by.y="key.or.doi", all.x = T)
  # renames before run app ()
  colnames(df.tot)[which(names(df.tot) == "long.ref")] <- "bib"
  colnames(df.tot)[which(names(df.tot) == "C14BP")] <- "C14Age"
  # df.tot$bib_url[df.tot$bib_url == ''] <- "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=Engedal+radiocarbon&btnG="
  # df.tot$bib[df.tot$bib == ''] <- "v. Google Scholar"
  # calculate tpq/taq
  df.tot$taq <- df.tot$tpq <- NA
  for (i in 1:nrow(df.tot)){
    # i <- 1
    if(i %% 100 == 0) print(paste0(as.character(i),"/", as.character(nrow(df.tot))))
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
  df.tot <- df.tot[,c("SiteName", "Country", "Period", "PhaseCode",
                      "LabCode", "C14Age", "C14SD", 
                      "Material", "MaterialSpecies",
                      "tpq", "taq", 
                      "Longitude", "Latitude", 
                      "bib", "bib_url"
  )]
  # change Material to fit it to c14bazAAR thesaurus
  df.tot$Material[df.tot$Material=="CE"]<-"cereal"
  df.tot$Material[df.tot$Material=="H"]<-"bone (human)"
  df.tot$Material[df.tot$Material=="F"]<-"fauna"
  df.tot$Material[df.tot$Material=="OR"]<-"organic"
  df.tot$Material[df.tot$Material=="SE"]<-"plant seed"
  df.tot$Material[df.tot$Material=="SH"]<-"shell"
  df.tot$Material[df.tot$Material=="WC"]<-"wood charcoal"
  # "n/a" was already OK
  # write.csv(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
  # TODO: encode in UTF-8 ??
  write.table(df.tot, paste0(gs.master, "c14_dataset.tsv"),
              sep="\t",
              row.names=FALSE)
  # write.table(df.tot, paste0(getwd(),"/shinyapp/df_tot.csv"), fileEncoding = "UTF-8", sep="\t", row.names=FALSE)
}

