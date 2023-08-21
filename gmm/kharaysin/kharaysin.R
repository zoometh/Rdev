# remotes::install_github("zoometh/outlineR")
# remotes::install_github("benmarwick/outliner")
library(Momocs)
library(outlineR)

sampling <- T

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

inpath <- "./img/input_data"
jpgs <- "./img/out"

separate_single_artefacts(inpath = inpath,
                          outpath = jpgs)

lf <- list.files(jpgs, full.names=TRUE) # store to list
if(sampling){
  lf.samp <- sample(1:length(lf), 3)
  lf <- lf[lf.samp]
}

coo <- import_jpg(lf) # convert JPG to Coo
sickles <- Out(coo)

# panel.out <- paste0(path.data, "/out/1_panel.jpg")
# jpeg(panel.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
panel(sickles,
      names=TRUE,
      # names.col = sickles$fac$cols,
      # cols = sickles$fac$cols,
      # borders = sickles$fac$cols,
      cex.names = 0.5,
      # main = sickle.legend,
      cex.main = 0.8
)
# dev.off()
