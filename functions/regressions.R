# regressions
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels

# data: n-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
depots$id <- row.names(depots) # names
# data: 2-columns
typeA_B <- lm(depots$nb_typeA ~ depots$nb_typeB) # linear model
# titre
tit <- paste("la présence de '", colnames(depots)[1],
            "' explique", round(summary(typeA_B)$r.squared*100, 1),
            "% de \nla présence de '", colnames(depots)[2],
            "'\n(coefficient de régression:", summary(typeA_B)$r.squared, ")")
# graphique
greg <- ggplot(depots, aes(x = nb_typeA, y = nb_typeB, color = color, shape = shape))+
  ggtitle(tit) +
  # geom_smooth(method = "lm", se = FALSE) +
  geom_point(aes(nb_typeA, nb_typeB)) +
  geom_text_repel(aes(nb_typeA, nb_typeB, label = id)) +
  scale_color_identity() +
  scale_shape_identity() +
  scale_x_continuous(breaks= c(min(depots$nb_typeA) : max(depots$nb_typeA))) +
  scale_y_continuous(breaks= c(min(depots$nb_typeB) : max(depots$nb_typeB))) +
  theme(plot.title = element_text(size = 6, face = "bold")) +
  theme_bw()
greg


# sauver
png("out/reg_depots.png", width = 12, height = 12, units = "cm", res = 300)
greg
dev.off()
getwd()
shell.exec(paste0(getwd(), "/out/reg_depots.png"))
