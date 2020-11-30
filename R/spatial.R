#' @import RPostgreSQL
#' @import DBI
rdev.conn.pg <- function(){
  drv <- DBI::dbDriver("PostgreSQL")
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
