library(htmlwidgets)
library(kableExtra)
library(dplyr)
library(knitr)
library(magick)
library(leaflet)
library(RPostgreSQL)
library(rpostgis)
library(rdrop2)
library(sp)
library(plotly)

rdev.conn.pg <- function(){
  drv <- RPostgreSQL::dbDriver("PostgreSQL")
  con <- RPostgreSQL::dbConnect(drv,
                   dbname="bego",
                   host="localhost",
                   port=5432,
                   user="postgres",
                   password="postgres")
}

rdev.reproj <- function(a.geom){
  # rdev.reproject
  a.geom <- sp::spTransform(a.geom, wgs84)
  return(a.geom)
}
