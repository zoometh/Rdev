#' @name neo_calc
#'
#' @description calculate tpq / taq, and other columns
#'
#' @param df.c14 the original XLSX with neonet columns (SiteName, Period, etc.) with with checked values (see: neo_subset)
#' @param intCal calibration curve
#' @param Present to calibrate from BP (1950).
#' @param ref.period period referenced in NeoNet (and colors). A TSV file.
#' @param verbose if TRUE (default) then display different messages.
#'
#' @return
#'
#' @examples
#'
#'
#'
#' @export
neo_calc <- function(df.c14,
                    intCal = 'intcal20',
                    Present = 1950,
                    ref.period = "https://raw.githubusercontent.com/zoometh/neonet/main/inst/extdata/periods.tsv",
                    verbose = TRUE,
                    verbose.freq = 50){
  # calculate tpq/taq
  df.c14$taq <- df.c14$tpq <- df.c14$colors <- NA
  for (i in 1:nrow(df.c14)){
    # for (i in 1500:1700){
    # i <- 1
    if(verbose){
      if(i %% verbose.freq == 0) {
        print(paste0(as.character(i), "/", as.character(nrow(df.c14))))
      }
    }
    # # add HTTPS to DOIs
    # if (grepl("^10\\.", df.c14[i, "bib_url"])){
    #   df.c14[i, "bib_url"] <- paste0("https://doi.org/",df.c14[i, "bib_url"])
    # }
    # calibration
    ages1 <- BchronCalibrate(ages = df.c14[i, "C14Age"],
                             ageSds = df.c14[i, "C14SD"],
                             calCurves = intCal,
                             ids = 'Date1')
    df.c14[i, "tpq"] <- -(min(ages1$Date1$ageGrid) - Present)
    df.c14[i, "taq"] <- -(max(ages1$Date1$ageGrid) - Present)
  }
  # message pas grave (?):
  # Warning message:
  #   In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  :
  #             EOF within quoted string
  # - - - - - - - - - -- -
  # save in the Shiny app folder (git folder)
  # getwd()
  # reorder

  for (i in seq(1, nrow(df.c14))){
    # colors
    per.color <- as.character(periods.colors[periods.colors$period == df.c14[i, "Period"], "color"])
    # per.color <- as.character(lcul_col[df.c14[i, "Period"]])
    if(is.na(per.color)){
      per.color <- "#808080"
    }
    df.c14[i, "colors"] <- per.color
    # popup notification
    desc <- paste(sep = "<br/>",
                  paste0("<b>", df.c14[i,"SiteName"],"</b> / ",
                         df.c14[i,"Material"]," (", df.c14[i,"mat.life"],")"),
                  paste0("date: ", df.c14[i,"C14Age"], " +/- ", df.c14[i,"C14SD"],
                         " BP [", df.c14[i,"LabCode"],"]"),
                  paste0("tpq/taq: ", df.c14[i,"tpq"], " to ", df.c14[i,"taq"],
                         " cal BC"),
                  paste0("<span style='color: ", df.c14[i,"colors"],";'><b>", df.c14[i,"Period"], "</b></span>  ",
                         #paste0("period: ", df.c14[i,"Period"],
                         " <b>|</b> PhaseCode: <i>", df.c14[i,"PhaseCode"],
                         "</i> <br/>"))
    if(grepl("^http", df.c14[i,"bib_url"])){
      # for href, if exist
      desc <- paste0(desc, 'ref: <a href=', shQuote(paste0(df.c14[i, 'bib_url'])),
                     "\ target=\"_blank\"", ">", df.c14[i, 'bib'], "</a>")
    } else {desc <- paste0(desc, "ref: ", df.c14[i, "bib"])}
    df.c14[i, "lbl"]  <- desc
  }
  df.c14$locationID <- df.c14$LabCode
  df.c14$secondLocationID <- paste(rownames(df.c14), "_selectedLayer", sep = "")
  df.c14$idf <- 1:nrow(df.c14)
  df.c14 <- df.c14[ , c("SiteName", "Country", "Period", "PhaseCode",
                        "LabCode", "C14Age", "C14SD",
                        "Material", "MaterialSpecies", "mat.life",
                        "tpq", "taq",
                        "Longitude", "Latitude",
                        "bib", "bib_url", "locationID", "secondLocationID",
                        "lbl", "idf",
                        "colors"
  )]
  return(df.c14)
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
