library(oxcAAR)
# library(c14bazAAR)
library(RPostgreSQL)
library(DescTools)
library(Amelia)
library(ggplot2)
library(jpeg)

temp.dates <- paste0(tempdir(), "/some_dates.csv") # tempfile

# ## functions
# 
# c14.missingdata <- function(){
#   ylabels <- c(1, 50, 100, 150, 200, 250, 300, 350)
#   df.tot <- read.csv("shinyapp/df_tot.csv", sep = "\t")
#   df.tot[df.tot == "n/a"] <- NA
#   df.tot <- df.tot[,c("SiteName", "Country", "Period", "PhaseCode",
#                       "LabCode", "C14Age", "C14SD", "Material", "MaterialSpecies", "tpq", "taq", 
#                       "Longitude", "Latitude", "bib", "bib_url"
#                       )]
#   jpeg("docs/publication/missing_info.jpg", width =12, height = 12, units="cm", res=300)
#   missmap(df.tot,
#           x.cex=.6,
#           y.cex=.4,
#           # y.labels=row.names(df.tot),
#           y.labels=ylabels,
#           y.at=ylabels,
#           # cex.main = 0.5,
#           main="",
#           legend = F,
#           col = c("white", "grey"),
#           rank.order=FALSE,
#           margins = c(5,2))
#   dev.off()
#   # ggsave(filename = "docs/publication/missing_info.png", g.miss, width = 17, units = "cm")
# }
# 
# c14.missingdata()
# 
# 
# c14.summary <- function(){
#   df.tot <- read.csv("shinyapp/df_tot.csv", sep = "\t")
#   missing.values <- c("", "n/a")
#   linfos <- list()
#   n.dates <- nrow(df.tot) # number of dates
#   n.sites <- length(unique(df.tot$SiteName)) # number of dates
#   geo.extent <- list(N = max(df.tot$Latitude), # NSEW extent
#                      S = min(df.tot$Latitude),
#                      E = max(df.tot$Longitude),
#                      W = min(df.tot$Longitude))
#   time.extent <- list(tpq = min(df.tot$tpq),
#                       taq = max(df.tot$taq))
#   df.tot$context <- paste0(df.tot$SiteName,"-",df.tot$PhaseCode)
#   n.context <- length(unique(df.tot$context))
#   n.missing.context <- nrow(df.tot[df.tot$PhaseCode %in% missing.values, ])
#   perc.missing.context <- paste0(as.character(
#     as.integer((n.missing.context/nrow(df.tot))*100)),"%")
#   n.missing.material <- nrow(df.tot[df.tot$Material %in% missing.values, ])
#   perc.missing.material <- paste0(as.character(
#     as.integer((n.missing.material/nrow(df.tot))*100)),"%")
#   linfos <- c(linfos, 
#               n.dates = n.dates,
#               n.sites = n.sites,
#               n.context = n.context,
#               geo.extent = geo.extent,
#               time.extent = time.extent,
#               perc.missing.context = perc.missing.context,
#               perc.missing.material = perc.missing.material)
#   return(str(linfos))
# }
# 
# c14.summary()

read.c14.from.PG <- function(){
  # read from PostGres
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv,
                   dbname="mailhac_9",
                   host="localhost",
                   port=5432,
                   user="postgres",
                   password="postgres")  
  c14s <- dbGetQuery(con,"select * from datations")
  dbDisconnect(con)
  return(c14s)
}

f.info.a.date <- function(a.db, a.dt, to.tsv){
  # a.dt <- 'code:%Ly-11186%'; a.db <- "" ; get.infos.out <- F
  a.dat <- unlist(strsplit(a.dt,':'))[2]
  a.cat <- unlist(strsplit(a.dt,':'))[1]
  # retrieve main info for a selected date
  if(a.cat == "code"){
    # a.dat <- 'code:%Beta-433211%'
    if(a.db == 'PG'){
      c14s <- read.c14.from.PG()
      df <- c14s[c14s$code %like any% a.dat, get.infos.PG]
      df <- df[!is.na(df$code), ]
    } else {
      # dbC14 <- get_c14data(dbs)
      df <- dbC14[dbC14$labnr %like any% a.dat, get.infos.out]
      df <- df[!is.na(df$labnr), ]
      names(df)[names(df) == 'labnr'] <- 'code'
      # TODO: filters (country, etc.)
      # sdb <- dbC14 %>%
      #   fix_database_country_name() %>%
      #   determine_country_by_coordinate()
      # # clean up
      # sdb.Fr <- sdb[sdb$country_thes == "France",]
      # sdb.Fr <- sdb.Fr[sdb.Fr$lat <= 46,]
      # sdb.Fr <- sdb.Fr[sdb.Fr$c14age <= 8000,]
      # sdb.Fr <- sdb.Fr[sdb.Fr$c14age >= 5000,]
    }
  }
  if(a.cat == "site"){
    if(a.db == 'PG'){
      c14s <- read.c14.from.PG()
      df <- c14s[c14s$site %like any% a.dat, get.infos.PG]
      df <- df[!is.na(df$code), ]
    } else {
      dbC14 <- get_c14data(dbs)
      df <- dbC14[dbC14$site %like any% a.dat, get.infos.out]
      df <- as.data.frame(df)
      df <- df[!is.na(df$site), ]
      # rename column
      names(df)[names(df) == 'labnr'] <- 'code'
    }
  }
  df <- as.data.frame(df)
  df <- df[order(df$code),]
  df <- df[c("site", "culture", "us", "code", "bp", "delta", "taxon", "bib", "bib_invent")]
  if(to.tsv){
    df.out <- write.table(df, file = temp.dates, sep = "\t", row.names = F) 
    shell.exec(temp.dates)
  }
  return(as.data.frame(df))
}

## call
# a.dt <- 'code:LTL-8483A'
### examples
## code: 'code:LTL-8483A'
# f.info.a.date("PG", 'code:LTL-8483A')

# site: "site:Pendim%"
# f.info.a.date("PG", 'site:Pendim%')

# selected ext db(s)
dbs <- c("radon","calpal","euroevol","pacea","14cpalaeolithic") # varia
# dbs <- c("radon") # varia
# retrieve from selected code
# a.dat <- 'Ly-5185'
# retrieve selected info
get.infos.PG <- c("site", "us", "code", "bp", "delta", "us", "taxon", "culture", "bib", "bib_invent")
get.infos.out <- c("site", "labnr","c14age","c14std", "shortref")

f.info.a.date("PG", 'code:%OxA-18236%', F)







