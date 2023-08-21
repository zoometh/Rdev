library(c14bazAAR)


BDA <- get_bda()
# BDA <- as.data.frame(BDA)
# sort(unique(BDA$site))
View(BDA[BDA$site %in% "Saint-Michel-du-Touch", ])
View(BDA[BDA$site %in% "Roquemissou", ])
