# Sample arrowheads from the Petrix, and Nicolas datasets for the Oxford GOA lecture on GMM. Save a new .Rds file that will be read by 'C:\Rprojects\thomashuet\profiles\oxford\stats\GOA\stats\dim3\app.R' (dataset source: Matzig et al. 2021, see: https://doi.org/10.5281/zenodo.4560743)

library(Momocs)

# Petrik dataset
my.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
petrik <- readRDS(file = file.path(my.dir, "outlines_combined_petrik_2018.RDS"))
ids.petrik <- data.frame(id = c(1:length(petrik)),
                         color = rep("blue", length(petrik)))
petrik$fac <- ids.petrik
petrik <- petrik %>%
  Momocs::filter(id < 21)

# Nicolas dataset
nicolas <- readRDS(file = file.path(my.dir, "outlines_combined_nicholas_2016.RDS"))
ids.nicolas <- data.frame(id = c(1:length(nicolas)),
                          color = rep("red", length(nicolas)))
nicolas$fac <- ids.nicolas
nicolas <- nicolas %>%
  Momocs::filter(id < 21)

## Goshen: Dataset Not Used
# goshen <- readRDS(file = file.path(dirname(dirname(rstudioapi::getSourceEditorContext()$path)),"1_data","outlines_combined_goshen_plainview.RDS"))
# ids.goshen <- data.frame(id = c(1:length(goshen)),
#                           color = rep("red", length(goshen)))
# goshen$fac <- ids.goshen
# goshen <- goshen %>%
#   Momocs::filter(id < 21)

arrow.heads <- Momocs::combine(petrik, nicolas)

saveRDS(arrow.heads, paste0(my.dir, "/arrowheads/arrowheads.RDS"))
