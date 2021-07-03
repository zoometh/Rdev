# remotes::install_github("zoometh/outlineR")
# library(outlineR)
library(Momocs)
library(magick)

local.root.outlineR <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/outlineR/"

# source the outlineR function (local or from GH)
# devtools::source_url("https://raw.github.com/zoometh/outlineR/master/R/separate_single_artefacts_function.R")
source(paste0(local.root.outlineR, "R/separate_single_artefacts_function.R"))
# gh.repo.path <- 'https://raw.githubusercontent.com/zoometh/Rdev/main/'
inpath <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/Rdev/img/gmm"
outpath <- paste0(inpath, "/out")

# the beads show some light hues, the threshold has to be very high (99%)
separate_single_artefacts(inpath = inpath,
                          outpath = outpath,
                          thres = "99%",
                          min.area = 10)
lf <- list.files(outpath, full.names=TRUE)
coo <- import_jpg(lf)
beads <- Out(coo)

# For example:
# Define where the images containing multiple artefacts are right now.
root.path <-
inpath <- "./test_data/input_data"

# Define where the separate images should be saved.
outpath <- "./test_data/derived_data"
