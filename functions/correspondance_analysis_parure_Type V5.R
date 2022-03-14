library(FactoMineR) # pour les analyses factorielles
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels
library(openxlsx)
library(reshape2)
library(dplyr)
library(scales)
options(ggrepel.max.overlaps = Inf) # nbrx labels

# # data: n-columns
# xlsx.df <- "AFC Catégories fonctionnelles Nbr restes 2021.xlsx"
# xlsx.df.fe <- "Feuil1"
# n.depots <- c(1:147)
# col.xy <- c(2:3)
# col.num <- c(1)
# col.types <- c(12:21)
# col.region <- c(22:34)
# par[["root.path"]] <- "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/Rdev/_depots/"
#
param.choice <- 4
show.roi.rect <- F
color.1col <- F

param <- list(
  # 1
  list(
    root.path = "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/Rdev/_depots/",
    xlsx.df = "AFC Code typologique V1.xlsx",
    xlsx.df.fe = "Feuil4",
    n.depots = c(1:149),
    col.xy = c(2:3),
    col.num = c(1),
    col.types = c(6:509),
    col.region = c(521:533),
    xlsx.color = "my_colors.xlsx",
    xlsx.color.fe = "code_typo",
    g.roi.rect = list(
      list(bottom.left.xy = c(0, -.5),
           top.right.xy = c(1, .5))
      , list(bottom.left.xy = c(-.5, 0),
             top.right.xy = c(0, 1))
      # ...
      # , list()
      # ...
    ),
    g.shp.sz = c(1, 10),
    g.name = "ca_depots_B",
    g.png = T,
    g.label = F
  )
  # 2
  , list(root.path = "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/Rdev/_depots/",
         xlsx.df = "AFC Catégories fonctionnelles Nbr restes 2021.xlsx",
         xlsx.df.fe = "Feuil1",
         n.depots = c(1:147),
         col.xy = c(2:3),
         col.num = c(1),
         col.types = c(12:21),
         col.region = c(22:34),
         xlsx.color = "my_colors.xlsx",
         xlsx.color.fe = "code_famille",
         g.shp.sz = c(1, 5),
         g.name = "ca_depots",
         g.png = T,
         g.label = F)
  # 3
  , list(root.path = "C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/Rdev/_depots/",
         xlsx.df = "AFC Catégories fonctionnelles Nbr restes 2021.xlsx",
         xlsx.df.fe = "Feuil1",
         n.depots = c(1:147),
         col.xy = c(2:3),
         col.num = c(1),
         col.types = c(12:21),
         col.region = c(22:34),
         xlsx.color = "my_colors.xlsx",
         xlsx.color.fe = "code_typo",
         g.shp.sz = c(1, 5),
         g.name = "ca_depots",
         g.png = F,
         g.label = T)
  # ...
  # , list()
  # ...
  # 4
  , list(root.path = paste0(getwd(),"/functions/"),
         xlsx.df = "Corpus ParureV2.xlsx",
         xlsx.df.fe = "Feuil3",
         n.depots = c(1:111),
         col.xy = c(2:3),
         col.num = c(1),
         col.types = c(5:157),
         col.region = c(158:170),
         xlsx.color = "my_colors.xlsx",
         xlsx.color.fe = "code_typo",
         g.shp.sz = c(1,5),
         g.name = "ca_depotsparure",
         g.png = T,
         g.label = T)
  # ...
  # , list()
  # ...
)
par <- param[[ param.choice ]]
# par[["root.path"]] <- "C:/Users/onizuka/Desktop/Stat/Stat Pennors/Stat pennors final/"
# première lecture pour les noms de colonnes
depots <- openxlsx::read.xlsx(paste0(par[["root.path"]], par[["xlsx.df"]]),
                              sheet = par[["xlsx.df.fe"]],
                              rows = par[["n.depots"]])
col.xy.n <- colnames(depots)[ par[["col.xy"]] ]
col.num.n <- colnames(depots)[ par[["col.num"]] ]
col.types.n <- colnames(depots)[ par[["col.types"]] ]
col.region.n <- colnames(depots)[ par[["col.region"]] ]
# lit une deuxième fois sur les colonnes sélectionnées
depots <- openxlsx::read.xlsx(paste0(par[["root.path"]], par[["xlsx.df"]]),
                              sheet = par[["xlsx.df.fe"]],
                              rows = par[["n.depots"]],
                              cols = c(par[["col.xy"]],
                                       par[["col.num"]],
                                       par[["col.types"]],
                                       par[["col.region"]]))
# colnames(depots)[ncol(depots)]
colnames(depots)[1] <- "x"
colnames(depots)[2] <- "y"
depots$id <- depots[ , par[["col.num"]] ]
depots[, col.num.n] <- NULL
depots[is.na(depots)] <- 0

# sum(duplicated(depots$Num?ro.de.d?p?t)) # tests
# taille des symboles
depots$tot <- as.integer(rowSums(depots[ , par[["col.types"]] ])) # somme des types
depots$tot.gg <- rescale(depots$tot, to = par[["g.shp.sz"]]) # tailles pour le graphe

# rownames(depots) <- depots[, col.num]
if(!color.1col){
  # si les couleurs sont sur plusieurs colonnes
  regions <- depots[ , col.region.n]
  # as.integer(rowSums(regions)) # # testssomme des regions
  regions$id <- depots$id
  regions.melt <- melt(regions, id.vars=c("id"))
  regions.melt.clean <- regions.melt[(regions.melt$value == 1), ]
  regions.melt.clean$value <- NULL
  colnames(regions.melt.clean)[colnames(regions.melt.clean) == 'variable'] <- 'region'
  df.colors <- openxlsx::read.xlsx(paste0(par[["root.path"]], par[["xlsx.color"]]),
                                   sheet = par[["xlsx.color.fe"]])
  regions.melt.clean <- merge(regions.melt.clean, df.colors, by = 'region', all.x = T)
} else {
  regions <- depots[ , c("id", col.region.n)]
  df.colors <- openxlsx::read.xlsx(paste0(par[["root.path"]], par[["xlsx.color"]]),
                                   sheet = par[["xlsx.color.fe"]])
  regions.melt.clean <- merge(regions, df.colors, by = 'region', all.x = T)
}

# couleur des depots sur les regions
# n <- length(col.region.n)
# df.colors <- data.frame(region = col.region.n,
#                         couleur = rainbow(n))


symbols.col <- c("x", "y", col.types.n, "region")
# depots.symbols <- depots[ , (names(depots) %in% symbols.col)]
# CA
depots.ca <- depots[ , (names(depots) %in% c("id", col.types.n, col.region.n))]
rownames(depots.ca) <- depots.ca$id
depots.ca$id <- NULL
col.region.m <- which(names(depots.ca) %in% col.region.n)
colnames.ca <- colnames(depots.ca)
#colSums(depots.ca[,col.region.m])
#col.region.m <- col.region.m[-2]
ca <- CA(depots.ca,
         col.sup = col.region.m,
         graph = FALSE)            # AFC
inertCA1 <- round(as.numeric(ca$eig[,2][1]), 1)
inertCA2 <- round(as.numeric(ca$eig[,2][2]), 1)
# # pour afficher les %
coords_ind_ca <- as.data.frame(ca$row$coord[, c(1,2)])
coords_var_ca <- as.data.frame(ca$col$coord[, c(1,2)])
abbrev.var <- as.character(abbreviate(rownames(coords_var_ca), 5))
abbrev.df <- data.frame(abbrev = abbrev.var,
                        var = rownames(coords_var_ca),
                        stringsAsFactors = F)
rownames(coords_var_ca) <- abbrev.var
coords_var_sup_ca <- as.data.frame(ca$col.sup$coord[, c(1,2)])
coords_ca <- rbind(coords_ind_ca,
                   coords_var_ca,
                   coords_var_sup_ca)
colnames(coords_ca)[1] <- 'CA1'
colnames(coords_ca)[2] <- 'CA2'
coords_ca$id <- row.names(coords_ca)
# jointure données + coordonnées CA
depots.m <- merge(coords_ca, depots[ , c('id', 'tot', 'tot.gg')],  by = "id", all.x = T)
# rownames(depots.m) <- depots.m$id
# depots.m$Row.names <- NULL
# sur "id"
# joint 'region'
depots.r <- merge(depots.m,
                  regions.melt.clean,
                  by = "id", all.x = T)

# # couleur des region sur les regions... à verfi/renommer
depots.r <- merge(depots.r, df.colors,  by.x = 'id', by = 'region', all.x = T)
depots.r <- depots.r %>% mutate(couleur = coalesce(couleur.x, couleur.y))
# colnames(depots.r)
depots.cr <- depots.r[c("id", "region", "couleur", "tot", "tot.gg", "CA1", "CA2")]
depots.cr$shape <- depots.cr$size <- depots.cr$alpha <- NA

# les variables
depots.cr$couleur[is.na(depots.cr$couleur)] <- "#000000" # noir
depots.cr$shape[depots.cr$couleur == "#000000"] <- 17 # triangle
depots.cr$size[depots.cr$couleur == "#000000"] <- 1 #
depots.cr$alpha[depots.cr$couleur == "#000000"] <- 1 #
# les regions
depots.cr$shape[depots.cr$id %in% col.region.n] <- 15 # carré
depots.cr$size[depots.cr$id %in% col.region.n] <- 1.5
depots.cr$alpha[depots.cr$id %in% col.region.n] <- 1
# depots.cr$id[depots.cr$id %in% col.region.n] <- toupper(depots.cr$id)
# les depots
depots.cr$shape[is.na(depots.cr$shape)] <- 16 # rond
depots.cr$size[depots.cr$shape == 16] <- depots.cr$tot.gg
depots.cr$alpha[depots.cr$shape == 16] <- 1

# titre
tit <- paste("AFC sur", length(par[["n.depots"]]), "depots et",
             length(col.types.n), "variables actives")
# graphique
gca <- ggplot(depots.cr, aes(CA1, CA2,
                             color = couleur,
                             shape = shape,
                             alpha = alpha,
                             size = size)) +
  ggtitle(tit) +
  geom_point() +
  scale_color_identity() +
  scale_shape_identity() +
  scale_alpha_identity() +
  geom_hline(yintercept = 0, linetype = "dashed", size = 0.2, alpha = 0.3) +
  geom_vline(xintercept = 0, linetype = "dashed",size = 0.2, alpha = 0.3) +
  geom_text(x = 0,
            y = -Inf,
            label = paste0(inertCA1,"%"),
            vjust = -1,
            size = 2,
            alpha = 0.5) +
  geom_text(x = -Inf,
            y = 0,
            label = paste0(inertCA2,"%"),
            vjust = 1,
            angle = 90,
            size = 2,
            alpha = 0.5) +
  theme(plot.title = element_text(size = 8, face = "bold")) +
  theme(axis.text=element_text(size = 5),
        axis.title.x=element_text(size = 8),
        axis.title.y=element_text(size = 8))+
  theme(axis.ticks = element_line(size = 0.2))+
  theme(legend.position = "none")+
  theme(strip.text.x = element_text(size = 8),
        strip.text.y = element_blank()) +
  theme(panel.border = element_rect(colour = 'black', fill = NA, size = 0.2)) +
  theme(panel.background = element_rect(fill = 'transparent')) +
  theme(panel.spacing.y = unit(0, "lines"))
# scale_x_continuous(limits = c(-1, 2), expand = c(0, 0)) + # par période ou régions
# scale_y_continuous(limits = c(-1, 1), expand = c(0, 0)) +
# scale_fill_identity() + # pour les shape > 20
# facet_grid(per ~ .) # par période ou régions
if(par[["g.label"]]){
  gca <- gca + geom_text_repel(aes(label = id),
                               cex = 2,
                               segment.size = 0.1,
                               segment.alpha = 0.5)
}
if(show.roi.rect){
  n.roi.rect <- length(par[["g.roi.rect"]])
  for (a.roi.rect in 1:n.roi.rect){
    # a.roi.rect <- 1
    bottom.left.xy <- par[["g.roi.rect"]][[a.roi.rect]]$bottom.left.xy
    top.right.xy <- par[["g.roi.rect"]][[a.roi.rect]]$top.right.xy
    xmin <- bottom.left.xy[1]
    ymin <- bottom.left.xy[2]
    xmax <- top.right.xy[1]
    ymax <- top.right.xy[2]
    gca <- gca +
      geom_rect(xmin = xmin,
                xmax = xmax,
                ymin = ymin,
                ymax = ymax, fill = NA, size = .2)
    # export roi
    gca.roi <- gca +
      scale_x_continuous(limits = c(xmin, xmax), expand = c(0, 0)) + # par période ou régions
      scale_y_continuous(limits = c(ymin, ymax), expand = c(0, 0))
    if(par[["g.png"]]){png(paste0(par[["root.path"]], par[["g.name"]],
                                  "_roi_", as.character(a.roi.rect),".png"), width = 28, height = 20,
                           units = "cm", res = 300)}
    if(!par[["g.png"]]){pdf(paste0(par[["root.path"]], par[["g.name"]],
                                   "_roi_", as.character(a.roi.rect), ".pdf"), width = 28, height = 20)}
    print(gca.roi)
    dev.off()
  }
}

# tableau des abbrev
if(par[["g.label"]]){
  write.csv2(abbrev.df, paste0(par[["root.path"]], par[["g.name"]], "_ca_abbrev.csv"),
             row.names = F)
}
# sauver general plot
if(par[["g.png"]]){png(paste0(par[["root.path"]], par[["g.name"]], ".png"), width = 28, height = 20,
                       units = "cm", res = 300)}
if(!par[["g.png"]]){pdf(paste0(par[["root.path"]], par[["g.name"]], ".pdf"), width = 28, height = 20)}
gca
dev.off()
if(par[["g.png"]]){shell.exec(paste0(par[["root.path"]],par[["g.name"]], ".png"))}
if(!par[["g.png"]]){shell.exec(paste0(par[["root.path"]], par[["g.name"]], ".pdf"))}
