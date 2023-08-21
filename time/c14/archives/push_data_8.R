setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("R/neo_subset.R")
source("R/neo_bib.R")
source("R/neo_matlife.R")
source("R/neo_calc.R")

# c14
data.c14 <- "neonet/NeoNet_atl_ELR (1).xlsx"
data.bib <- paste0(getwd(), "/neonet/NeoNet_atl_ELR.bib")
df.c14 <- openxlsx::read.xlsx(data.c14)
df.c14 <- df.c14[df.c14$Country == "France", ]
df.c14 <- neo_subset(df.c14)
df.c14 <- neo_bib(df.c14, data.bib)
df.c14 <- neo_matlife(df.c14)
df.c14 <- neo_calc(df.c14)
# print
col.not.used <- c("Anatomical.part.(type)", "OBS", "Reliability", "bib_url", "MaterialSpecies")
df.c14[ , col.not.used] <- NULL
View(df.c14)
# export
write.table(df.tot, paste0(output.path, "c14_dataset.tsv"),
            sep="\t",
            row.names=FALSE)
# write.table(c14.bibrefs, paste0(output.path, "references.bib"),
#             sep="\t",
#             row.names=FALSE)
# write.table(material.life.duration, paste0(output.path, "c14_material_life.tsv"),
#             sep="\t",
#             row.names=FALSE)



