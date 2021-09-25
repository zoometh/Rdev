# library(FactoMineR) # pour les analyses factorielles
library(ggdendro) # pour les dendrogrammes
library(dendextend) # pour les dendrogrammes
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels
library(dplyr) # méthode

# data: n-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data_factor_analysis.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
depots.symbols <- depots[ , (names(depots) %in% c("shape", "color"))]
depots.symbols$ord <- 1:nrow(depots.symbols) # utile pour réordonner
depots.ca <- depots[ , !(names(depots) %in% c("color", "shape"))]
symb_dd <- merge (depots.ca, depots.symbols, by = "row.names") # regroupe sur row.names
# créer le dendrogramme
dend1 <- depots.ca %>%
  dist %>% hclust(method = "complete") %>%
  as.dendrogram  # créé un 'dendrogram'
# réordonne le tab de données après le clustering
symb_dd <- symb_dd[match(order.dendrogram(dend1), symb_dd$ord),] # reord
dend1 <- dend1 %>%
 set("branches_lwd", .2) %>% # ie: dendextend::set
  set("labels_cex", .3) %>% #.3
  set("leaves_cex", 1.2) %>%  # 1.2
  set("leaves_pch", symb_dd$shape) %>%  # node point type
  set("leaves_col", symb_dd$color)
ggd1 <- as.ggdend(dend1) # tranform en 'ggdend'
# titre
tit <- paste("CAH sur", nrow(depots.ca), "individus et", ncol(depots.ca), "variables")
# graphique
gcah <- ggplot(ggd1, horiz = T, theme = theme_minimal(), offset_labels = -1) +
  ggtitle(tit) +
  theme(plot.title = element_text(size = 8, face = "bold")) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 8)) +
  theme(plot.margin = unit(c(0, 0, 0 ,0), "pt"))
  # annotate(geom = "text",  # écrit la période
  #          x = as.integer(nrow(symb_dd)/2),  # au milieu du jeu de données
  #          y = hdend,
  #          vjust = 0,
  #          hjust = 0,
  #          angle = ang.cah,
  #          label = unique(symb_dd$per)) +
  # ylim(hdend, 0) + # fixe l'emprise pour comparer plusieurs dendro
  # scale_y_continuous(breaks = seq(hdend, 10, by = -20)) +
gcah

# sauver
png("out/cah_depots.png", width = 8, height = 8, units = "cm", res = 300)
gcah
dev.off()
shell.exec(paste0(getwd(), "/out/cah_depots.png"))
