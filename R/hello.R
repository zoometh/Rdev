# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

hello <- function() {
  print("Hello, world Now!")
  print("Hello, world Now!")
}

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
