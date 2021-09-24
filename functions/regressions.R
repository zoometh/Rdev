# regressions
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels

# data: 2-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data_regression.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
depots$id <- row.names(depots) # names
typeA_B <- lm(depots$nb_typeA ~ depots$nb_typeB) # linear model

# relation entre les variables à expliquer et des variables explicatives
tit <- paste("la présence de '", colnames(depots)[1],
            "' explique", round(summary(typeA_B)$r.squared*100, 1),
            "% de \nla présence de '", colnames(depots)[2],
            "' (coefficient de régression:", summary(typeA_B)$r.squared, ")")

# afficher
greg <- ggplot(depots, aes(color = color, shape = shape))+
  geom_point(aes(nb_typeA, nb_typeB)) +
  geom_text_repel(aes(nb_typeA, nb_typeB, label = id)) +
  scale_color_identity() +
  scale_shape_identity() +
  scale_x_continuous(breaks= c(min(depots$nb_typeA) : max(depots$nb_typeA))) +
  scale_y_continuous(breaks= c(min(depots$nb_typeB) : max(depots$nb_typeB))) +
  theme_bw()
greg


# sauver
png("out/regression_depots.png")
greg
dev.off()
getwd()
shell.exec(paste0(getwd(), "/out/regression_depots.png"))
