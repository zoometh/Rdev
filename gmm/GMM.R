# remotes::install_github("zoometh/outlineR")
# library(outlineR)
library(Momocs)
library(dplyr)
# library(magick)

# source the outlineR function (local or from GH)
# devtools::source_url("https://raw.github.com/zoometh/outlineR/master/R/separate_single_artefacts_function.R")
# inpath <- paste0(getwd(), "/gmm/")
outpath <- paste0(getwd(), "/gmm/out")

# # the beads show some light hues, the threshold has to be very high (99%)
# separate_single_artefacts(inpath = inpath,
#                           outpath = outpath,
#                           thres = "99%",
#                           min.area = 10)
lf <- list.files(outpath, full.names = TRUE)
coo <- import_jpg(lf)
beads <- Out(coo)

# stack
beads %>%
  coo_center %>%
  coo_scale %>%
  coo_slidedirection("up") %T>%
  print() %>%
  stack()

# panel
beads %>%
  panel()

beads.f <- efourier(beads)

# CLUST
beads.p <- CLUST(beads.f)
plot(beads.p)

# Kmeans
beads.p <- PCA(beads.f)
KMEANS(beads.p, centers = 4)

# # For example:
# # Define where the images containing multiple artefacts are right now.
# # root.path <-
# inpath <- "./test_data/input_data"
#
# # Define where the separate images should be saved.
# outpath <- "./test_data/derived_data"
