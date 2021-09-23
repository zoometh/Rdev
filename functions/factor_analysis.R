library(FactoMineR)

# data: n-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data_factor_analysis.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
# depots$id <- row.names(depots) # names
ca <- CA(depots, graph = FALSE)            # AFC
inertCA1 <- round(as.numeric(ca$eig[,2][1]), 1)
inertCA2 <- round(as.numeric(ca$eig[,2][2]), 1)
# # pour afficher les %
# perCA_tsit <- rbind(perCA_tsit,
#                     data.frame(perCA1 = inertCA1,
#                                perCA2 = inertCA2,
#                                per = per))
coords_ind_ca <- as.data.frame(ca$row$coord)
coords_var_ca <- as.data.frame(ca$col$coord)
coords_ca <- rbind(coords_ind_ca, coords_var_ca)
colnames(coords_ca)[1] <- 'CA1'
colnames(coords_ca)[2] <- 'CA2'
coords_ca$id <- row.names(coords_ca)
# dataset.p <- merge(df_lda.per, coords_ca, by="row.names", all.y = T)
# dataset.ps <- merge(dataset.p, typsit_symb, by.x="Type.site", by.y="tsite", all.x = T)
# dataset.ps$per <- per
# dataset.ps$color <- as.character(dataset.ps$color)
# colVar <- "black"
# shpVar <- 17
# for (i in seq(1,nrow(dataset.ps))){
#   if(dataset.ps[i,"Row.names"]=='percOC'){
#     dataset.ps[i,"Row.names"] <- "OC"
#     dataset.ps[i,"color"] <-  colVar # green
#     dataset.ps[i,"shape"] <-  shpVar #
#     dataset.ps[i,"Type.site"] <- "var" # triangle plein
#   }
#   if(dataset.ps[i,"Row.names"]=='percBOTA'){
#     dataset.ps[i,"Row.names"] <- "BOTA"
#     dataset.ps[i,"color"] <- colVar  # blue
#     dataset.ps[i,"shape"] <- shpVar
#     dataset.ps[i,"Type.site"] <- "var" # triangle plein
#   }
#   if(dataset.ps[i,"Row.names"]=='percSUDO'){
#     dataset.ps[i,"Row.names"] <- "SUDO"
#     dataset.ps[i,"color"] <- colVar # "black" # red
#     dataset.ps[i,"shape"] <- shpVar # 17 # triangle plein
#     dataset.ps[i,"Type.site"] <- "var" # triangle plein
#   }
# }
# dataset.ps$shape <- as.factor(dataset.ps$shape)
# names(dataset.ps)[names(dataset.ps) == 'Row.names'] <- "num" # renomme la colonne
# CAT_per_site <- CAT_per[ ,c("Site","num")]
# ff <- merge(dataset.ps,CAT_per_site,by="num",all.x=T)# les types de sites
# matches <- colnames(ca_all_tsite) # réordonne
# ff <- ff[,match(matches, colnames(ff))]
# ca_all_tsite <- rbind(ca_all_tsite,ff)
color <- "black"
gca <- ggplot(coords_ca, aes(CA1, CA2)) +
  # sites
  #subset(ca_all_tsite, Type.site != 'var')
  geom_point(aes(CA1, CA2), # change to aes
                 colour = color,
                 fill = color,
                 stroke = .5,
             pch = 17,
                 # pch = as.numeric(levels(ca_all_tsite$shape))[ca_all_tsite$shape]),
             size = 1.5) + # 1.5
  geom_text_repel(aes(CA1, CA2, label = id),
                  cex=2,
                  segment.size = 0.1,
                  segment.alpha = 0.5)+
  geom_hline(yintercept=0, linetype="dashed", size=0.2, alpha=0.3)+
  geom_vline(xintercept=0, linetype="dashed",size=0.2, alpha=0.3)+
  geom_text(x = 0,
            y = -Inf,
            label = paste0(inertCA2,"%"),
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
  theme(axis.text=element_text(size = 5),
        axis.title.x=element_text(size = 8),
        axis.title.y=element_text(size = 8))+
  theme(axis.ticks = element_line(size = 0.2))+
  theme(legend.position = "none")+
  theme(strip.text.x = element_text(size = 8),
        strip.text.y = element_blank())+
  theme(panel.border = element_rect(colour = 'black', fill = NA, size = 0.2))+
  theme(panel.background = element_rect(fill = 'transparent'))+
  theme(panel.spacing.y = unit(0,"lines"))
  # scale_x_continuous(limits = c(-1, 2), expand = c(0, 0))+
  # scale_y_continuous(limits = c(-1, 1), expand = c(0, 0))+
  # scale_colour_identity()+
  # scale_shape_identity()+
  # scale_fill_identity()+
  # facet_grid(per ~ .)
gca

# sauver
png("out/ca_depots.png")
gca
dev.off()
