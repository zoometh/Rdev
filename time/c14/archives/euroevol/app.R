library(shiny)
library(leaflet)
library(sp)
library(RColorBrewer)
library(raster)
library(rgeos)
library(rhandsontable)
library(DT)
library(shinyjs)
library(mapview)
library(htmlwidgets)
library(dplyr)
library(magrittr)
library(rstudioapi)
library(rsconnect)
library(openxlsx)
library(DescTools)
library(ggplot2)
library(Bchron)
library(rcarbon)
library(shinyWidgets)
library(gsheet)
library(leaflet.extras)
library(bibtex)

# setwd("D:/Cultures_9/Neolithique/web")
# setwd("C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/shinyapp") # read from local
source("functions.R")

# data(intcal13)
#library(shinysky)
# install.packages(c('leaflet','shiny', 'rsconnect','sp','RColorBrewer','raster','rgeos',
#                    'rhandsontable','sf','DT','shinyjs','shinysky','mapview','htmlwidgets',
#                    'dplyr','magrittr','rstudioapi'))

#######################################
#               TITLE                 #
#######################################

# entites_thomas <- 1 # si 'entites_thomas' = 1, lit l'export de la bd de thomas 
# # (on ne met pas de connection directe à la bd)
# entites_didier <- !entites_thomas
# web <- 1 # si web = 1, le fichier 
# correspondances entre l es cultures et leur couleur d'affichage (hexadécimal)

euroevol <- F # euroevol
neonet <- !euroevol ; limit.neonet <- F # neonet and limit to study
webpage.app <- "https://zoometh.github.io/C14/neonet"
# inside.geometry <- F

# xl.url <- 'docs.google.com/spreadsheets/d/1fObKeXF7JdL4MX0PQliHfL82e2cg9KO8/edit' # 14C_1
# useful for EUROEVOL_R
xl.url <- 'docs.google.com/spreadsheets/d/1A85x9wnWGpAhcdQbg1_RKa-OyYj64zqn3-vhkcIgOn8/edit' # 14C_3
ggschol.h <- "https://scholar.google.com/scholar"

lcul_col <- list(# colors
  EM ="#0000cf", # Bleu
  MM ="#1d1dff", # 
  LM ="#3737ff", # 
  LMEN ="#6a6aff", #  
  UM ="#8484ff", # 8484ff
  EN ="#ff1b1b", #
  EMN ="#ff541b", # 
  MN ="#ff8d1b", # 
  LN ="#ffc04d", # 
  UN ="#e7e700", # Undef.
  LNEBA ="#b37400", # 
  EBA="#006800", # Vert
  MBA ="#008100", # 
  LBA ="#00b400", # 
  UBA ="#00e700", 
  # EIA = "#c4c4c4", # Gris
  NoPeriod ="#000000" # Noir
) # Rose /!\ nom variable != nom valeur
# unique(df.tot$Period)
lcul_col <- lapply(lcul_col,toupper)


## graphical param
gcalib.w <- 1500 # abs, px
gcalib.h <- 200 # rel, px
gcalib.lbl.sz <- 1.5 # text
gcalib.strip.text.sz <- 2.5 # facet label
gcalib.axis.title.sz <- 4
gcalib.xaxis.sz <- 3
gcalib.yaxis.sz <- 2
gcalib.gline.sz <- .3 # geom_line sz
gcalib.bin <- 100 # the chrono granul

nsites.14C.cal <- 1000 # max of sites calibrated at the same time, panel calib

# c14bibtex.url <- '../neonet/references_france.bib'
# c14bibtex.url <- 'shinyapp/references_france.bib'
# c14bibtex.url <- 'references_france.bib'
c14bibtex.url <- 'references_OK.bib'
bib <- read.bib(c14bibtex.url)
bib <- sort(bib) # sort
bibrefs.md <- capture.output(print(bib)) # Markdown layout
bibrefs.md <- replace(bibrefs.md, bibrefs.md == "", "<br><br>") 
bibrefs.md <- paste0(bibrefs.md, collapse = '')
bibrefs.html <- markdown(bibrefs.md) # to HTML layout

# material life duration, load df
# mat.life.url <- 'https://raw.github.com/zoometh/C14/master/neonet/c14_material_life.tsv'
# mat.life.url <- '../neonet/c14_material_life.tsv'
mat.life.url <- 'c14_material_life.tsv'
# mat.life.url <- 'shinyapp/c14_material_life.tsv'
# mat.life.url <- paste0(dirname(getwd()), '/neonet/c14_material_life.tsv')
# getwd()
material.life.duration <- read.csv(mat.life.url, sep = "\t")
# material.life.duration <- as.data.frame(gsheet2tbl(paste0(xl.url,"#gid=1800523177"))) # 14C_1, the second one
# material.life.duration <- as.data.frame(gsheet2tbl(paste0(xl.url,"#gid=1417727139"))) # 14C_3, the second one
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

if(neonet){
  # try to read directly - - - - - - - - - - - - - 
  # df.tot <- read.csv(text=gsheet2text(xl.url, format = "csv"),
  #                    stringsAsFactors=FALSE) # 
  # df.tot$bib_url[df.tot$bib_url == ''] <- paste0(ggschol.h,"?hl=en&as_sdt=0%2C5&q=",df.tot$SiteName,"+radiocarbon&btnG=")
  # df.tot$bib[df.tot$bib == ''] <- "v. Google Scholar"
  ## "df_tot.csv" file results from 'push_data.R"
  # print(getwd())
  df.tot <- read.csv("c14_dataset.tsv", sep = "\t")
  # df.tot <- readr::read_csv("df_tot.csv")
  df.tot$tpq <- as.numeric(df.tot$tpq)
  df.tot$taq <- as.numeric(df.tot$taq)
  df.tot$Longitude <- as.numeric(df.tot$Longitude)
  df.tot$Latitude <- as.numeric(df.tot$Latitude)
  df.tot <- subset(df.tot, Longitude != 'NA') # without missing coords
  df.tot <- subset(df.tot, Latitude != 'NA')
  # redneo <- 1 # a limit for the communication workshop
  if(limit.neonet){
    # df.tot <- df.tot[df.tot$PhaseCode != "",]
    df.tot <- df.tot[df.tot$Latitude < 46 & df.tot$Longitude > -10,]
    df.tot <- df.tot[df.tot$RedNeo == 1,] # rm NA
    # # df.tot <- df.tot[(df.tot$Latitude < 46 | df.tot$Country == 'Italy') & df.tot$Longitude > 2,]
    # # df.tot <- df.tot[df.tot$SiteName == "Mas de Vignoles X" | df.tot$SiteName == "Les Usclades",] # rm NA
    # # df.tot <- df.tot[!is.na(df.tot$RedNeo),] # rm NA
  } 
  # else {
  #   # select.date <- (df.tot$tpq > -7500 & df.tot$taq < -4500)# to Early Neo
  #   select.roi <- (df.tot$Country != 'Spain')# no Spain
  #   select.italy <- (df.tot$Latitude < 46 | df.tot$Country == 'Italy')# to geo1
  #   select.france <- (df.tot$Longitude > .7)# no W France
  #   df.tot <- df.tot[(select.roi & select.italy & select.france), ]
  #   # df.tot <- df.tot[(select.date & select.roi & select.italy & select.france), ]
  #   
  # }
  df.tot <- df.tot[!(is.na(df.tot$Latitude)) & !(is.na(df.tot$Longitude)),] # rm NA
  df.tot <- df.tot[df.tot$Latitude != 'NA' & df.tot$Longitude != 'NA',] # rm NA
  out.png.name <- 'neonet.png'
}

# df.tot[df.tot$Longitude == 'NA',]
# df.tot <- 

## limit
if(euroevol){
  # not run
  # setwd("D:/Cultures_9/Neolithique/web") # not run
  # load("df_tot.R")
  load("C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/euroevol/euroevol_14C.R")
  Encoding(df.tot$SiteName) <- "UTF-8"
  # TODO: get BIB from the net
  df.tot$bib_url <- paste0(ggschol.h,"?hl=en&as_sdt=0%2C5&q=",df.tot$SiteName,"+radiocarbon&btnG=")
  # df.tot$bib_url[df.tot$bib_url == ''] <- "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=Engedal+radiocarbon&btnG="
  df.tot$bib <- "v. Google Scholar"
  # setwd("D:/Cultures_9/Neolithique/web")
  # limit.euroevol
  # EUROEVOL.url <- "https://discovery.ucl.ac.uk/id/eprint/1469811/" # main EUREVOL DB URL
  # SitCom.url <- paste0(EUROEVOL.url,"9/EUROEVOL09-07-201516-34_CommonSites.csv")
  # S.Com <- read.csv(url(SitCom.url))
  # ChrPh.url <- paste0(EUROEVOL.url,"8/EUROEVOL09-07-201516-34_CommonPhases.csv")
  # ChrPh <- read.csv(url(ChrPh.url)) 
  out.png.name <- 'euroevol.png'
}


# sample - - - - - - - - - - - - - - -  
# df.tot <- df.tot[sample(1:nrow(df.tot),60),] # sample
# df.tot <- df.tot[ with(df.tot, grepl("^P", SiteName)) , ]
# nrow(df.tot)
#  - - - - - - - - - - - - - - - - - - - - -
df.tot$locationID <- df.tot$LabCode
df.tot$secondLocationID <- paste(rownames(df.tot), "_selectedLayer", sep="")

wgs84 <- '+init=EPSG:4326'
# fiab.contxt <- c("certain","probable","autre_pas_infos","NA")
# fiab.datation <- c("excellente","bonne","moyenne","mediocre","NA")
df.tot$lbl <- NA
df.tot[is.na(df.tot)] <- 'NA'
#df.tot <- fperiodes(df.tot) # calcule tpq/taq
df.tot$tpq[df.tot$tpq == 'NA'] <- Inf
df.tot$taq[df.tot$taq == 'NA'] <- -Inf
df.tot$tpq <- as.numeric(df.tot$tpq)
df.tot$taq <- as.numeric(df.tot$taq)
# rearrange columns
# refcols <- c("SiteName","SiteID","Period","Culture",
#              "Longitude","Latitude","Country",
#              "C14ID","C14Age","C14SD","Material")
# material type
mat.type.life <- c("short life","long life","others")
df.tot$mat.life <- ifelse(df.tot$Material %in%  short.life, "short life",
                          ifelse(df.tot$Material %in%  long.life,"long life","others"))
hotcols <- c("Country", "SiteName","Period", "PhaseCode", # "Culture",
             "Longitude","Latitude",
             "tpq","taq",
             "LabCode", "C14Age","C14SD","Material","mat.life",
             "bib","bib_url")
# refcols <- c("SiteName","Period", "PhaseCode", # "Culture",
#              "Longitude","Latitude",
#              "tpq","taq",
#              "LabCode", "C14Age","C14SD","Material","mat.life",
#              "bib","bib_url","locationID", "secondLocationID")
refcols <- c(hotcols, c("locationID", "secondLocationID"))
df.tot <- df.tot[ , c(refcols, setdiff(names(df.tot), refcols))]
df.tot <- df.tot[ ,refcols] # exclude other columns
# replace values
df.tot[df.tot==""]<-"unknown"
# # material type
# mat.type.life <- c("short life","long life","others")
# df.tot$mat.life <- ifelse(df.tot$Material %in%  short.life, "short life",
#                           ifelse(df.tot$Material %in%  long.life,"long life","others"))
# Github html pages
# html.root <- '<a href=https://raw.github.com/zoometh/C14/master/neonet/'
# material.life.html <- paste0(html.root,'material_life.html><span style="color: purple;">material life duration and max accepted SD</span></a>')
# # material.life.html <- paste0(html.root,'material_life.html>14C materials</a>')
# period.abrev.html <- paste0(html.root,'period_abrev.html>periods</a>')
#df.tot <- df.tot[!duplicated(df.tot[,c("SiteID","Period")]),] # supprime doublons, useful ?
df.tot$lbl <- NA
# labels
for (i in seq(1, nrow(df.tot))){
  #desc <- df.tot[i,"SiteID"]
  # i <- 1
  desc <- paste(sep = "<br/>",
                paste0("<b>",df.tot[i,"SiteName"],"</b> / ",df.tot[i,"Material"]," (",df.tot[i,"mat.life"],")"),
                paste0("date: ",df.tot[i,"C14Age"]," +/- ",df.tot[i,"C14SD"]," BP [",df.tot[i,"LabCode"],"]"),
                paste0("tpq/taq: ",df.tot[i,"tpq"]," to ",df.tot[i,"taq"]," cal BC"),
                paste0("period: ", df.tot[i,"Period"]," <b>|</b> PhaseCode: <i>",df.tot[i,"PhaseCode"],"</i> <br/>"))
  if(grepl("^http", df.tot[i,"bib_url"])){
    # TODO: open in new window
    # desc <- paste0(desc, paste0("ref: ", "<a href = \"",df.tot[i,"bib_url"],"\">", df.tot[i,"bib"],"</a>"))
    desc <- paste0(desc, 'ref: <a href=',shQuote(paste0(df.tot[i,'bib_url'])),"\ target=\"_blank\"",
                                ">", df.tot[i,'bib'], "</a>")
    # desc <- paste0(desc, paste0("ref: ", "<a href = \"",df.tot[i,"bib_url"],"\ target=\"_blank\">",df.tot[i,"bib"],"</a>"))
  } else {desc <- paste0(desc, "ref: ", df.tot[i,"bib"])}
  # paste0("ref: ", df.tot[i,"bib"]," -- ",df.tot[i,"bib_url"]),
  df.tot[i,"lbl"]  <- desc
}
df.tot$idf <- seq(1,nrow(df.tot))
# colors
Periods <- as.factor(unique(df.tot$Period))
myColors <- c()
# restrict on recorded period
lcul_col <- lcul_col[names(lcul_col) %in% unique(df.tot$Period)]
for (i in names(lcul_col)){
  myColors <- c(myColors,as.character(lcul_col[i]))
}
df.tot$colors <- NA
for (i in seq(1:nrow(df.tot))){
  df.tot[i,"colors"]  <- toupper(as.character(lcul_col[df.tot[i,"Period"]]))
}
# sp
xy <- list(longitude=c(as.numeric(df.tot$Longitude)),
           latitude=c(as.numeric(df.tot$Latitude)))
df.tot.sp <- SpatialPointsDataFrame(coords = xy,
                                    data = df.tot,
                                    proj4string = CRS("+proj=longlat +datum=WGS84"))
# tit <- HTML(paste0('<a href=',shQuote(paste0("https://zoometh.github.io/C14/neonet/")),"\ target=\"_blank\"",'><b> NeoNet </b></a> ',
#                    'Radiocarbon dating by Location, Chronology and Material Life Duration'))
# tit = HTML(paste0('Radiocarbon Dating by Location, Chronology and Material Life Duration'))
# credits
if(euroevol){
  tit <- HTML(paste0('<b>EUROEVOL_R</b></a> ',
                     'Radiocarbon dating by Location, Chronology and Material Life Duration'))
  data.credits <- HTML(paste0(' <b> DATA SOURCE: </b> ',
                              '<a href=',shQuote(paste0("http://discovery.ucl.ac.uk/1469811/")),"\ target=\"_blank\"",'> EUROEVOL database </a> ',
                              "(accessed the ",Sys.Date(),')'))
}
if(neonet){
  tit <- HTML(paste0('NEONET ',
                     'Radiocarbon dating by Location, Chronology and Material Life Duration'))
  data.credits <- HTML(paste0(' <b> Data gathering: </b>',
                              '<ul>',
                              '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-9315-3625")),"\ target=\"_blank\"",
                              '> Niccolo Mazzucco </a>: nicco.mazzucco@gmail.com </li>',
                              '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-2386-8473")),"\ target=\"_blank\"",
                              '> Miriam Cubas Morera </a>: mcubas.morera@gmail.com, </li>',
                              '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-0830-3570")),"\ target=\"_blank\"",
                              '> Juan Gibaja </a>: jfgibaja@gmail.com, </li>',
                              '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-1642-548X")),"\ target=\"_blank\"",
                              '> F. Xavier Oms</a>: oms@ub.edu, </li>',
                              '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-1112-6122")),"\ target=\"_blank\"",
                              '> Thomas Huet </a>: thomashuet7@gmail.com </li>',
                              '</ul>'))
}
# # TODO: add contacts
if(neonet){
  data.contacts <- 'CONTACT: <thomashuet7@gmail.com>, <nicco.mazzucco@gmail.com>'
  app.page <- HTML(paste0('<a href=',shQuote(paste0("https://zoometh.github.io/C14/neonet/")),"\ target=\"_blank\"",'><b> NeoNet app </b>website</a>'))
  b64 <- base64enc::dataURI(file="neonet.png", mime="image/png") # load image
}
if(euroevol){
  data.contacts <- 'CONTACT: <thomashuet7@gmail.com>'
  app.page <- HTML(paste0('<a href=',shQuote(paste0("https://zoometh.github.io/C14/euroevol/")),"\ target=\"_blank\"",'><b> EUROEVOL_R app </b>website</a>'))
  b64 <- base64enc::dataURI(file="euroevol_R.png", mime="image/png") # load image
}
app.credits <- HTML(paste0(' <b> IT developments: </b> ',
                           '<ul>',
                           '<li> <a href=',shQuote(paste0("https://orcid.org/0000-0002-1112-6122")),"\ target=\"_blank\"",
                           '> Thomas Huet </a> </li>',
                           '</ul>'))
all.credits <- paste0(data.credits,"<br>",app.credits,"<br><br>","      ... visit the ", app.page)
# # logo
# if(neonet){
#   b64 <- base64enc::dataURI(file="neonet.png", mime="image/png") # load image
# }
# if(euroevol){
#   b64 <- base64enc::dataURI(file="euroevol_R.png", mime="image/png") # load image
# }

# for the chrono slider
Mx <- max(df.tot$taq)
Mn <- min(df.tot$tpq)
if(!is.na(Mx %% gcalib.bin)){Mx <- Mx - (Mx %% gcalib.bin)} # round to next xx'
if(!is.na(Mn %% gcalib.bin)){Mn <- Mn - (Mn %% gcalib.bin)} # round to next xx'

##  functions - - - - - - - - - - - - - - - - - - - - - - - - -
# for the legend, reorder Period dataframe on average date  
reord_moy <- function(df,legende){
  duniq_cul <- unique(df[,c("Period",lper)])
  duniq_cul <- duniq_cul[which(duniq_cul$Period %in% legende$Period),]
  duniq_cul <- duniq_cul[!duplicated(duniq_cul$Period),] # au cas où une Period aurait des per !=
  row.names(duniq_cul) <- as.character(duniq_cul$Period)
  duniq_cul$Period<- NULL
  duniq_cul$moy <- 0 
  for (i in seq(1,nrow(duniq_cul))){
    sum_ <- c() # un vecteur vide
    for (j in seq(1,ncol(duniq_cul)-1)){ # loop sur périodes (sans colonne 'moyenne')
      val <- dper[j]
      if (duniq_cul[i,j] != 'NA'){
        colnme <- colnames(duniq_cul)[j] # la période représentée
        idx_colnme <- match(colnme,lper) # l'index de la période représentée
        sum_ <- c(sum_,mean(unlist(dper[idx_colnme])))
      }
    }
    duniq_cul[i,"moy"] <- mean(sum_)
  }
  return(duniq_cul)
}
# plot various calibrated dates
# f.gcalib <- function(ages3,some_14C,clicked_site, gperiod){
# QQQ

f.hgg <- function(some_14C,C14.grouped){
  # height, add 1 by default
  if(C14.grouped == "C14ungroup"){
    h.gg <- nrow(some_14C)
  }
  if(C14.grouped == "C14groupsl"){
    h.gg <- nrow(some_14C[!duplicated(some_14C[c("SiteName","PhaseCode")]),])
  }
  if(C14.grouped == "C14groupsp"){
    h.gg <- nrow(some_14C[!duplicated(some_14C[c("SiteName","Period")]),])
  }
  if(C14.grouped == "C14groupp"){
    h.gg <- nrow(some_14C[!duplicated(some_14C[c("Period")]),])
  }
  if(C14.grouped == "C14all"){
    h.gg <- 1 #nrow(some_14C[!duplicated(some_14C[c("Period")]),])
  }
  return(h.gg+1)
}

plotInput <- function() {
  # useful ??
  ggplot(dat.cumul)+
    facet_grid(means ~ ., switch="both", labeller = labeller(means = supp.labs)) +
    geom_text(data=a.label, size = gcalib.lbl.sz, aes(x = means,
                                                      y = -Inf,
                                                      label = site.per,
                                                      colour = color,
                                                      vjust=-0.1,
                                                      fontface=ifelse(clicked,"bold","plain"))
    )+
    geom_line(data=dat.cumul,aes(datations,densites,colour = color),
              size=gcalib.gline.sz) +
    scale_color_identity() +
    xlab("cal BC")+ylab("densities")+
    scale_x_continuous(breaks = seq(mm,MM,gcalib.bin))+
    theme(legend.position=c(1,1),
          strip.text = element_text(size = gcalib.strip.text.sz),
          strip.background =element_rect(fill="white"),
          panel.background = element_rect(fill = 'transparent'),
          axis.title=element_text(size=gcalib.axis.title.sz),
          axis.text.y = element_text(size=gcalib.yaxis.sz),
          axis.text.x = element_text(size=gcalib.xaxis.sz),
          axis.ticks = element_line(size = .01))
}

# color
# mat.type.life <- c("A","B","C")
my.colors <- rep('purple',length(mat.type.life))
my.fun <- function() {
  res <- list()
  for (o in mat.type.life) {
    # o <- mat.type.life[1]
    res[[length(res)+1]] <- tags$span(tags$b(o),
                                      style = paste0('color: ', my.colors[which(mat.type.life == o)],';'))
  }
  res
}
max.accepted.sd <- "<span style='color: purple;'>max acceped sd</span>"
# View(head(df.tot))
############################################### ui #################################################

ui <- navbarPage(tit,
                 # titlePanel(
                 #   windowTitle = "NOAA",
                 #   title = tags$head(tags$link(rel="shortcut icon", 
                 #                               href="https://www.noaa.gov/sites/all/themes/custom/noaa/favicon.ico", 
                 #                               type="image/vnd.microsoft.icon"))),
                 # ui <- navbarPage("EUROEVOL - dynamic mapping of radiocarbon dating",
                 tabPanel(title = "map",
                          fluidPage(
                            tags$style(".checkbox { /* checkbox is a div class*/
                                       line-height: 12px;font-size:12px;
                                        background-color: #f2f2f2;
                                       }
                                       input[type='checkbox']{ /* style for checkboxes */
                                       width: 12px; /*Desired width*/
                                       height: 12px; /*Desired height*/
                                       line-height: 12px;
                                       }
                                       "),
                            # tags$style(HTML(".js-irs-2 .irs-single, .js-irs-2 .irs-bar-edge, .js-irs-2 .irs-bar {background: green}")),
                            tags$style(HTML(".js-irs-1 .irs-single, .js-irs-1 .irs-bar-edge, .js-irs-1 .irs-bar {background: purple}")),
                            fluidRow(htmlOutput("presentation")),
                            fluidRow(
                              column(12,
                                     # helpText("move chrono slider to selected sites within 'tpq' and 'taq' calculated on 14C and 'intcal13' calibration curve |
                                     #          check/uncheck 'Periods' pour show/hide sites by Periods"),
                                     leafletOutput("map", width = "100%", height = 700),
                                     # tpq taq slider
                                     absolutePanel(bottom = 10, left = 150,
                                                   sliderInput("range", 
                                                               width='600px',
                                                               label="tpq/taq", Mn, Mx,
                                                               value = range(Mn,Mx),
                                                               step = gcalib.bin)),
                                     # a txt output
                                     fluidRow(verbatimTextOutput("Click_text")),
                                     # a radio button
                                     absolutePanel(top = 40, left = 80,
                                                   materialSwitch(inputId = "hover",
                                                                  label = "group C14 on map",
                                                                  status = "default",
                                                                  width = "120px")
                                     ),
                                     ## selection on material type and sd
                                     # type of material (short,...,long life)
                                     absolutePanel(bottom = 70, right = 40,
                                                   checkboxGroupInput("mater",
                                                                      label="material life duration and max accepted SD",
                                                                      # choices=my.fun(),
                                                                      # selected=my.fun(),
                                                                      choiceNames = my.fun(),
                                                                      choiceValues = mat.type.life,
                                                                      # choiceValues = my.colors,
                                                                      # choices=mat.type.life,
                                                                      selected=mat.type.life,
                                                                      inline = TRUE,
                                                                      width = "300px")
                                     ),
                                     # slider, filter on sd
                                     absolutePanel(bottom = 10, right = 40,
                                                   sliderInput("sds",
                                                               width='300px',
                                                               label=NULL,
                                                               # label=HTML(max.accepted.sd),
                                                               min = 0,
                                                               max = max(df.tot$C14SD),
                                                               # label="max acceped sd",0, max(df.tot$C14SD),
                                                               value = max(df.tot$C14SD),
                                                               step = 10)
                                     ),
                                     # periods
                                     absolutePanel(top = 70, right = 40,
                                                   checkboxGroupInput("cults", 
                                                                      label="periods",
                                                                      # choiceNames = list(
                                                                      #   tags$span("A", style = "color: red;"),
                                                                      #   tags$span("B", style = "color: red;"), 
                                                                      #   tags$span("C", style = "color: blue;"), 
                                                                      #   tags$span("D", style = "font-weight: bold;")
                                                                      # ),
                                                                      choices=names(lcul_col),
                                                                      selected=names(lcul_col),
                                                                      # colors=as.character(lcul_col),
                                                                      # choices=sort(Periods),
                                                                      # selected=sort(Periods),
                                                                      width = "100px")),
                                     # the logo
                                     absolutePanel(top = 15, left = 80,
                                                   img(src=b64, width="10%", align='left')),
                                     # # the credits
                                     # absolutePanel(top = 55, left = 80,
                                     #               htmlOutput("credits")),
                                     # the plot of coordinates ?0
                                     absolutePanel(bottom = 10, left = 250,
                                                   textOutput("out"),
                                                   tags$head(tags$style(HTML("#out {font-size: 14px;}")))
                                     ))),
                            fluidRow(
                              # KKK
                              htmlOutput("nb.dat"),
                              column(12,
                                     div(DTOutput("tbl"), style = "font-size:70%"))
                            )
                          )),
                 # tabsetPanel(id = "tabs",
                 tabPanel("calib",
                          fluidRow(
                            column(5,
                                   htmlOutput("calib.presentation")
                            ),
                            column(5,
                                   # QQQ a radio button
                                   radioButtons(
                                     inputId = "C14group",
                                     label = "C14 grouped by site and/ or period",
                                     choices = c("by dates" = "C14ungroup",
                                                 # TODO
                                                 "by PhaseCode" =  "C14groupsl",
                                                 "by site and period" = "C14groupsp",
                                                 "by period" = "C14groupp",
                                                 "all C14" = "C14all"),
                                     selected = "C14ungroup",
                                     inline = TRUE,width = NULL,choiceNames = NULL,
                                     choiceValues = NULL
                                   )
                            ),
                            # column(3,
                            #        sliderInput("distpercent",
                            #                    width='300px',
                            #                    label="percent of the distribution", 0, 100,
                            #                    value = 100,
                            #                    step = 5)
                            # ),
                            column(1,
                                   downloadButton('dwnld_calib'))
                          ),
                          # showModal(modalDialog("Doing a function", footer=NULL)),
                          fluidRow(imageOutput("rdpd")
                                   # removeModal()
                          )
                          # )
                 ),
                 tabPanel("data",
                          fluidPage(
                            fluidRow(
                              fluidRow(div(DTOutput("hot"), style = "font-size:70%"))
                            )
                          )
                 ),
                 tabPanel("biblio",
                          fluidPage(
                            htmlOutput("biblio")
                          )
                 ),
                 tabPanel("infos",
                          #          fluidPage(htmlOutput("webpage")
                          #          )
                          # )
                          fluidPage(
                            tags$head(
                              tags$style(HTML("
                    li {
                    font-size: 14px;
                    }
                    li span {
                    font-size: 18px;
                    }
                    ul {
                    list-style-type: square;
                    }
                    "))
                            ),
                            HTML(all.credits)
                          )
                 )
                 # tabPanel("web",
                 #          fluidPage(htmlOutput("webpage")
                 #          )
                 # )
)
############################################### server #################################################

server <- function(input, output, session) {
  output$presentation <- renderUI({
    HTML(paste0("move the <b> window map </b>  to select dates by location |", 
                " move the <b> tpq/taq slider </b> to selected sites within ‘standard’ cal BC duration ",
                "(calibration with the <a href='https://rdrr.io/cran/Bchron/man/BchronCalibrate.html'>BchronCalibrate</a> ", 
                # "and ", " <a ref='https://cran.r-project.org/web/packages/rcarbon/vignettes/rcarbon.html'>calibrate</a>", 
                "function and the ","'Intcal13' ", 
                # "or 'Intcal20'", 
                "calibration curve) <br/>",
                " draw <b> polygon or rectangle </b> to subset dates by a smaller area than the ROI |",
                " check/uncheck <b> material buttons </b> to show/hide sites by type of life duration material |",
                " check/uncheck <b> periods buttons </b> to show/hide sites by Periods |",
                " <b> click </b> on sites to get informations | <b> click </b> on the map to get long/lat coordinates <br/>"))
  })
  output$calib.presentation <- renderUI({
    HTML(paste0(" in the <b>map panel</b>, click on a site to get its C14 calibration ",
                "and those of all sites within the region of interest ('Intcal13' calibration curve, limited to <b><font color= green >",
                nsites.14C.cal," dates</font></b>) | ",
                "<b>check/uncheck</b> by dates, by site and/or stratigraphical layer and/or period, all C14 to (un)group dates | ",
                "<b>download</b> the plot with the button"))
  })
  # TODO: loading message
  # output$text <- renderText({paste0("You are viewing tab \"", input$tabs, "\"")})
  # the 'big' table
  output$hot <- DT::renderDataTable({
    datatable(
      df.tot[ , hotcols],
      rownames = FALSE,
      width = "100%",
      editable=FALSE,
      options = list(
        scrollX = TRUE,
        pageLength = 100
      )
    )
  })
  # petite table éditable filtrée
  output$tbl <- renderDataTable({
    datatable(
      #df.tot,
      data_map(),
      rownames = FALSE,
      extensions = c("Scroller","Buttons"),
      style = "bootstrap",
      class = "compact",
      width = "100%",
      editable = F, # TODO: F
      callback = JS("table.on('click.dt', 'td', function() {
                               Shiny.onInputChange('click', Math.random());
                });"),
      options = list(
        deferRender = TRUE,
        scrollX = TRUE,
        scrollY = 300,
        scroller = TRUE,
        dom = 'tp'
      )
    )
  })
  # édition de cellule pour la table filtrée 'tbl'
  proxy = dataTableProxy('tbl')
  observeEvent(input$tbl_cell_edit, {
    info = input$tbl_cell_edit
    idf = data_map()[info$row,"idf"]
    j = info$col+1
    v = info$value
    df.tot[idf, j] <<- DT::coerceValue(v, df.tot[idf, j] )
    replaceData(proxy, df.tot, resetPaging = FALSE)  # important
  })
  # édition de cellule pour la petite table
  proxy1 = dataTableProxy('hot')
  observeEvent(input$hot_cell_edit, {
    info = input$hot_cell_edit
    i = info$row
    j = info$col+1
    v = info$value
    df.tot[i,j] <- v
    replaceData(proxy1, df.tot, resetPaging = FALSE)  # important
  })
  # le tableau dynamique (sous la carte) - - - - - - - - - - - - - - - - 
  in_bounding_box <- function(data.f, lat, long, tpq, taq, sds, bounds) {
    # filter sites on coordonates, chrono & type of material
    if(is.null(inside.geometry$LabCode.selected)){
      # there is no selection shape
      data.f %>%
        dplyr::filter(
          # conditional select on map and chrono extent
          lat >= bounds$south &
            lat <= bounds$north &
            long <= bounds$east & 
            long >= bounds$west &
            sds <= input$sds &
            ((taq > input$range[1] & tpq < input$range[1]) |
               (tpq < input$range[2] & taq > input$range[2]) |
               (tpq >= input$range[1] & taq <= input$range[2]) |
               (tpq <= input$range[1] & taq >= input$range[2])) &
            Period %in% input$cults &
            mat.life %in% input$mater
        )
    } else {
      # a shape has been traced
      # print(inside.geometry$LabCode.selected)
      # print(colnames(data.f))
      # print("SHAPE")
      data.f %>%
        dplyr::filter(
          LabCode %in% inside.geometry$LabCode.selected &
            lat >= bounds$south &
            lat <= bounds$north &
            long <= bounds$east & 
            long >= bounds$west &
            sds <= input$sds &
            ((taq > input$range[1] & tpq < input$range[1]) |
               (tpq < input$range[2] & taq > input$range[2]) |
               (tpq >= input$range[1] & taq <= input$range[2]) |
               (tpq <= input$range[1] & taq >= input$range[2])) &
            Period %in% input$cults &
            mat.life %in% input$mater
        )
    }
  }
  # calcule l'extension de la carte (dynamique)
  data_map <- reactive({
    data.f <- df.tot
    data.f <- data.f[ ,!(colnames(data.f) %in% c("lbl","idf","colors"))] # rm some col from dynamic table
    if (is.null(input$map_bounds)) {
      data.f
    } 
    else {
      bounds <- input$map_bounds
      in_bounding_box(data.f, df.tot$Latitude, df.tot$Longitude,
                      df.tot$tpq, df.tot$taq, df.tot$C14SD, bounds)
    }
  })
  data_count <- reactive({
    data.f <- df.tot
    data.f <- data.f[ ,!(colnames(data.f) %in% c("lbl","idf","colors"))] # rm some col from dynamic table
    if (is.null(input$map_bounds)) {
      # ZZZ
      as.character(c(0,0))
    }
    else {
      bounds <- input$map_bounds
      sel.data <- in_bounding_box(data.f,
                                  df.tot$Latitude, df.tot$Longitude,
                                  df.tot$tpq, df.tot$taq, df.tot$C14SD,
                                  bounds)
      # ndat <- nrow(filteredData()@data)
      ndat <- nrow(sel.data)
      # View(sel.data)
      if(ndat <= nsites.14C.cal){
        ndat <- paste0("<font color= green >",as.character(ndat),"</font>")
      }
      # nsite <- length(unique(filteredData()@data$SiteName))
      nsite <- length(unique(sel.data$SiteName))
      as.character(c(ndat,nsite))
    }
  })
  # filtered data on ROI, tpq/taq, periods, etc.
  # reactive, return a SpatialPointsDataFrame
  filteredData <- reactive({
    tpq.taq.val <- (df.tot.sp$taq > input$range[1] & df.tot.sp$tpq < input$range[1]) | 
      (df.tot.sp$tpq < input$range[2] & df.tot.sp$taq > input$range[2]) | 
      (df.tot.sp$tpq >= input$range[1] & df.tot.sp$taq <= input$range[2]) |
      (df.tot.sp$tpq <= input$range[1] & df.tot.sp$taq >= input$range[2])
    cult.select <- df.tot.sp$Period %in% input$cults
    mat.select <- df.tot$mat.life %in% input$mater
    dat.sds <- df.tot$C14SD <= input$sds
    dyna.df_ <- df.tot.sp[tpq.taq.val & cult.select & mat.select & dat.sds,]
    dyna.df_
  })
  output$map <- renderLeaflet({
    # non dynamic
    leaflet(df.tot.sp) %>%
      # addProviderTiles(providers$Esri.WorldImagery) %>%
      addTiles() %>%
      # addMapPane("buff.j1_", zIndex = 410) %>% # BUFFERS
      addMapPane("sites_", zIndex = 420) %>%
      fitBounds(~min(Longitude),~min(Latitude),~max(Longitude),~max(Latitude)) %>%
      # obtient les coord.
      onRender(
        "function(el,x){
                    this.on('click', function(e) {
                        var lat = e.latlng.lat;
                        var lng = e.latlng.lng;
                        var coord = [lng, lat];
                        Shiny.onInputChange('hover_coordinates', coord)
                    });
                }"
      )
  })
  # les coordonnées cliquées
  output$out <- renderText({
    if(!is.null(input$hover_coordinates)) {
      paste0(round(input$hover_coordinates[1],4),",",round(input$hover_coordinates[2],4))
    }
  })
  output$nb.dat <- renderUI({
    HTML(paste0("Dataset within the region of interest (ROI) and the selected parameters: ",
                "<b>",data_count()[2],"</b> sites, ",
                "<b>",data_count()[1],"</b> dates "))
  })
  observe({
    # print(input$sds)
    legende <- unique(filteredData()@data[c("Period", "colors")])
    legende_ord <- legende[match(names(lcul_col), legende$Period),] # réordonne sur liste Didier
    legende_ord <- legende_ord[complete.cases(legende_ord),]
    # print(legende_ord)
    if (nrow(filteredData()) > 0) {
      # legende <- unique(filteredData()@data[c("Period", "colors")])
      # legende_ord <- legende[match(names(lcul_col), legende$Period),] # réordonne sur liste Didier
      # legende_ord <- legende_ord[complete.cases(legende_ord),]
      # print(legende_ord)
      df_colors <-  data.frame(color = filteredData()@data$colors,
                               material = filteredData()@data$Material,
                               stringsAsFactors = FALSE)
      nhd_wms_url <- "https://basemap.nationalmap.gov/arcgis/services/USGSTopo/MapServer/WmsServer"
      # to get the info on df.tot -> filteredData()
      proxy.sites <- leafletProxy("map", data = filteredData()) %>%
        # setView(lng = -111.846061, lat = 36.115847, zoom = 12) %>%
        addTiles(group = 'OSM') %>%
        # addWMSTiles(nhd_wms_url, layers = "0", group='Topo')
        addProviderTiles(providers$Esri.WorldImagery, group='Topo')
      proxy.sites %>% clearControls() %>% clearShapes() %>% clearMarkers() %>%
        addLayersControl(
          baseGroups = c('OSM', 'Topo')) %>%
        addLegend("bottomleft",
                  colors = as.vector(legende_ord$colors),
                  labels= as.vector(legende_ord$Period),
                  # pal = pal,
                  # values = ~Period,
                  title = "Periods",
                  opacity = 1) %>%
        addScaleBar("map", position = "bottomleft")
      #proxy.sites <- proxy.sites %>% clearShapes() %>% clearMarkers()
      # clustered - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if(input$hover == TRUE){
        proxy.sites <- proxy.sites %>% removeMarkerFromCluster(layerId = ~LabCode,
                                                clusterId  = "grouped")
        # proxy.sites <- proxy.sites %>% clearControls() %>% clearShapes() %>% clearMarkers() %>%
        proxy.sites <- proxy.sites %>%
          addCircleMarkers(layerId = ~LabCode, 
                           lng = ~Longitude,
                           lat = ~Latitude,
                           weight = 1,
                           radius = 3,
                           popup = ~lbl,
                           clusterId  = "grouped",
                           fillColor = df_colors$color,
                           color = "black",
                           opacity = 0.7,
                           fillOpacity = 0.7,
                           group = df.tot.sp$Period,
                           clusterOptions = markerClusterOptions(showCoverageOnHover = T,
                                                                 zoomToBoundsOnClick = T),
                           options = pathOptions(pane = "sites_", markerOptions(riseOnHover = TRUE))) %>%
          # highlightOptions = highlightOptions(color = "mediumseagreen",
          #                                     opacity = 1.0,
          #                                     weight = 2,
          #                                     bringToFront = TRUE)) %>%
          addDrawToolbar(
            targetGroup='Selected',
            polylineOptions=FALSE,
            # rectangleOptions = FALSE,
            circleOptions = FALSE,
            circleMarkerOptions=FALSE,
            markerOptions=FALSE,
            polygonOptions = drawPolygonOptions(shapeOptions=drawShapeOptions(fillOpacity = 0
                                                                              ,color = 'white'
                                                                              ,weight = 3)),
            rectangleOptions = drawRectangleOptions(shapeOptions=drawShapeOptions(fillOpacity = 0
                                                                                  ,color = 'white'
                                                                                  ,weight = 3)),
            # circleOptions = drawCircleOptions(shapeOptions = drawShapeOptions(fillOpacity = 0
            #                                                                   ,color = 'white'
            #                                                                   ,weight = 3)),
            editOptions = editToolbarOptions(edit = FALSE, 
                                             selectedPathOptions = selectedPathOptions()))
      }
      # non clustered - - - - - - - - - - - - - - - - - - - - -  - - - - - - - -
      if(input$hover == FALSE){
        proxy.sites <- proxy.sites %>% removeMarkerFromCluster(layerId = df.tot$LabCode,
                                                # proxy.sites %>% removeMarkerFromCluster(layerId = ~LabCode,
                                                clusterId  = "grouped")
        proxy.sites <- proxy.sites  %>%
          addCircleMarkers(layerId = ~LabCode, # to get the info on df.tot
                           lng = ~Longitude,
                           lat = ~Latitude,
                           weight = 1,
                           radius = 3,
                           popup = ~lbl,
                           fillColor = df_colors$color,
                           color = "black",
                           opacity = 0.7,
                           fillOpacity = 0.7,
                           label = ~lapply(paste0("<b>",as.character(SiteName),"</b><br>",
                                                  as.character(Period)," - <i>",as.character(PhaseCode),"</i><br>",
                                                  "[",as.character(LabCode),"]"),
                                           htmltools::HTML),
                           group = df.tot.sp$Period,
                           options = pathOptions(pane = "sites_")) %>%
          # highlightOptions = highlightOptions(color = "mediumseagreen",
          #                                     opacity = 1.0,
          #                                     weight = 2,
          #                                     bringToFront = TRUE)) %>%
          addDrawToolbar(
            targetGroup='Selected',
            polylineOptions=FALSE,
            # rectangleOptions = FALSE,
            circleOptions = FALSE,
            circleMarkerOptions=FALSE,
            markerOptions=FALSE,
            polygonOptions = drawPolygonOptions(shapeOptions=drawShapeOptions(fillOpacity = 0
                                                                              ,color = 'white'
                                                                              ,weight = 3)),
            rectangleOptions = drawRectangleOptions(shapeOptions=drawShapeOptions(fillOpacity = 0
                                                                                  ,color = 'white'
                                                                                  ,weight = 3)),
            # circleOptions = drawCircleOptions(shapeOptions = drawShapeOptions(fillOpacity = 0
            #                                                                   ,color = 'white'
            #                                                                   ,weight = 3)),
            editOptions = editToolbarOptions(edit = FALSE, selectedPathOptions = selectedPathOptions()))
      }
      # for both, cluster or uncluster: legend & map
      # proxy.sites <- proxy.sites %>%
      #   addLayersControl(
      #     baseGroups = c('OSM', 'Topo')) %>%
      #   addLegend("bottomleft",
      #             colors = as.vector(legende_ord$colors),
      #             labels= as.vector(legende_ord$Period),
      #             # pal = pal,
      #             # values = ~Period,
      #             title = "Periods",
      #             opacity = 1) %>%
      #   addScaleBar("map", position = "bottomleft")
      # proxy.sites
    }
  })
  observeEvent(input$map_marker_click, { 
    # on click
    p <- input$map_marker_click  # typo was on this line
    sel.r <- subset(df.tot, LabCode == p$id)
    # select other sites in bounding box
    bounds <- input$map_bounds
    some_14C <- in_bounding_box(df.tot, 
                                df.tot$Latitude,df.tot$Longitude,
                                df.tot$tpq,df.tot$taq,df.tot$C14SD,
                                bounds)
    # calibrate QQQ
    C14.grouped <- input$C14group
    # save(some_14C,file="D:/Cultures_9/Neolithique/some_14C.R")
    clicked_site <- c(sel.r$SiteName,sel.r$C14Age,sel.r$LabCode) # to identify the clicked site
    # save(some_14C,file="D:/Cultures_9/Neolithique/some_14C.R");save(clicked_site,file="D:/Cultures_9/Neolithique/clicked_site.R")
    # threshold of n
    if(nrow(some_14C) < nsites.14C.cal){
      # showModal(modalDialog("Doing a function", footer=NULL))
      output$rdpd <- renderImage({
        # TODO: show message "Wait"
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = '.png')
        # # Generate the PNG
        out <- paste0(df.tot[i,"LabCode"],".png") # useful ?
        gcalib <- f.gcalib(some_14C,clicked_site,C14.grouped)
        h.gg <- f.hgg(some_14C,C14.grouped)
        ggsave(outfile, gcalib, 
               width=gcalib.w/300,
               height = (gcalib.h*h.gg/300)+1,
               dpi=300,
               units="in",
               limitsize = FALSE)
        list(src = outfile,
             contentType = 'image/png',
             width = gcalib.w,
             height = (gcalib.h*h.gg)+1,
             # height = gcalib.h*nrow(some_14C),
             alt = "This is alternate text")
        # removeModal()
      }, deleteFile = TRUE)
    }
    observeEvent(input$C14group, {
      p <- input$map_marker_click  # typo was on this line
      sel.r <- subset(df.tot, LabCode == p$id)
      # select other sites in bounding box
      bounds <- input$map_bounds
      some_14C <- in_bounding_box(df.tot, df.tot$Latitude,df.tot$Longitude,
                                  df.tot$tpq,df.tot$taq,df.tot$C14SD,
                                  bounds)
      C14.grouped <- input$C14group
      clicked_site <- c(sel.r$SiteName,sel.r$C14Age,sel.r$LabCode) # to
      if(nrow(some_14C) < nsites.14C.cal){
        output$rdpd <- renderImage({
          # A temp file to save the output.
          # This file will be removed later by renderImage
          outfile <- tempfile(fileext = '.png')
          # # Generate the PNG
          out <- paste0(df.tot[i,"LabCode"],".png")
          # QQQ
          gcalib <- f.gcalib(some_14C,clicked_site,C14.grouped)
          h.gg <- f.hgg(some_14C,C14.grouped)
          # gcalib <- f.gcalib(ages3,some_14C,clicked_site,C14.grouped)
          # gcalib <- f.gcalib(ages3,some_14C,clicked_site,input$gperiod)
          ggsave(outfile, gcalib, 
                 width=gcalib.w/300,
                 height = gcalib.h*h.gg/300,
                 # height = gcalib.h*nrow(some_14C)/300,
                 dpi=300,
                 units="in",
                 limitsize = FALSE)
          # Return a list containing the filename
          list(src = outfile,
               contentType = 'image/png',
               width = gcalib.w,
               height = gcalib.h*h.gg,
               # height = gcalib.h*nrow(some_14C),
               alt = "This is alternate text")}, deleteFile = TRUE)
      }
    })
    output$dwnld_calib <- downloadHandler(
      filename = out.png.name,
      content = function(file) {
        p <- input$map_marker_click  # typo was on this line
        sel.r <- subset(df.tot, LabCode == p$id)
        bounds <- input$map_bounds
        some_14C <- in_bounding_box(df.tot, 
                                    df.tot$Latitude, df.tot$Longitude, 
                                    df.tot$tpq, df.tot$taq, df.tot$C14SD, 
                                    bounds)
        # QQQ
        C14.grouped <- input$C14group
        h.gg <- f.hgg(some_14C,C14.grouped)
        device <- function(..., width, height) {
          grDevices::png(..., width = gcalib.w/300,
                         height = gcalib.h*h.gg/300,
                         # height = gcalib.h*nrow(some_14C)/300,
                         res = 300, units = "in")
        }
        ggsave(file, plot = f.gcalib(some_14C,clicked_site,C14.grouped), device = device, limitsize = FALSE)
      })
  })
  # - - - - - - - - - - - - - - - - - - - - - - -
  # to select by polygon seee selection by polygon
  ############################################### section three #################################################
  # list to store the selections for tracking
  inside.geometry<-reactiveValues(LabCode.selected = NULL)
  data_of_click <- reactiveValues(clickedMarker = list())
  observeEvent(input$map_draw_new_feature,{
    # A selection shape is created
    coordinates <- as.data.frame(filteredData())
    coordinates <- SpatialPointsDataFrame(coordinates[,c('Longitude', 'Latitude')] , coordinates)
    found_in_bounds <- findLocations(shape = input$map_draw_new_feature,
                                     location_coordinates = coordinates,
                                     location_id_colname = "locationID")
    # usefull ?
    for(id in found_in_bounds){
      if(id %in% data_of_click$clickedMarker){
        # don't add id
      } else {
        # add id
        data_of_click$clickedMarker<-append(data_of_click$clickedMarker, id, 0)
      }
    }
    # - - - - - - - - -
    # look up df.tot by ids found
    selected <- subset(filteredData(), locationID %in% data_of_click$clickedMarker)
    LabCode.selected <- selected@data$LabCode
    inside.geometry$LabCode.selected <- LabCode.selected
  })
  ############################################### section four ##################################################
  observeEvent(input$map_draw_deleted_features,{
    # A selection shape is deleted -> all classic selected dates
    selected <- filteredData()
    LabCode.selected <- selected@data$LabCode
    inside.geometry$LabCode.selected <- LabCode.selected
  })
  output$biblio <- renderText({ 
    # bibliographical references
    bibrefs.html
  })
}
shinyApp(ui, server)