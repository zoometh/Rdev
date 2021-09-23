# regressions
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels

getwd()

# data: 2-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data_regression.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
depots$id <- row.names(depots) # names
typeA_B <- lm(depots$nb_typeA ~ depots$nb_typeB) # linear model

# relation entre les variables à expliquer et des variables explicatives
r.squared <- round(summary(typeA_B)$r.squared*100, 1)
print(paste("la présence de '", colnames(depots)[1],
            "' explique", r.squared, "% de la présence de '", colnames(depots)[2],
            "' (et réciproquement)"))

# afficher
greg <- ggplot(depots, aes(x = nb_typeA, y = nb_typeB)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = id)) +
  scale_x_continuous(breaks= c(min(depots$nb_typeA) : max(depots$nb_typeA))) +
  scale_y_continuous(breaks= c(min(depots$nb_typeB) : max(depots$nb_typeB)))
greg

# sauver
png("out/regression_depots.png")
greg
dev.off()
