library(MASS) # pour la LDA
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels

# data: n-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
depots$group <- depots$color
symbols.col <- c("shape", "color", "x", "y")
depots.symbols <- depots[ , (names(depots) %in% symbols.col)]
depots.ca <- depots[ , !(names(depots) %in% symbols.col)]
r <- lda(formula = group  ~ ., data = depots.ca) # analyse discriminante
prop.lda = r$svd^2/sum(r$svd^2) #
inertLD1 <- round(as.numeric(prop.lda[1]*100), 1)
inertLD2 <- round(as.numeric(prop.lda[2]*100), 1)
plda <- predict(object = r, newdata = depots.ca) # predict + coord
conf_mat <- table(predict(r, type = "class")$class,
                  depots.ca$group) # matrice des confusion
bienclass <- sum(diag(conf_mat)) # les biens classés
allclass <- sum(colSums(conf_mat)) # tous
accurval <- round((bienclass/allclass), 3)*100 # l'accuracy en %
dflda <- as.data.frame(plda$x) # extrait coordonnées lda
flda <- merge(dflda, depots.ca, by = "row.names") # regroupe sur row.names
rownames(flda) <- flda$Row.names
names(flda)[names(flda) == 'Row.names'] <- "num" # renomme la colonne
flda$Row.names <- NULL
# test si LD2 existe (sinon = 1 dimension), utile pour per="LA"
if("LD2" %in% names(dflda)==F){
  flda$LD2 <- 0
}
flda <- merge(flda, depots.symbols, by = "row.names")
rownames(flda) <- flda$Row.names
flda$Row.names <- NULL
# titre
tit <- paste("LDA sur", nrow(depots.ca), "individus et", ncol(depots.ca), "variables")
# graphique
glda <- ggplot(flda, aes(LD1, LD2, color = color, shape = shape)) +
  ggtitle(tit) +
  geom_hline(yintercept = 0, linetype = "dashed", size=0.2, alpha = 0.3) +
  geom_vline(xintercept = 0, linetype = "dashed", size=0.2, alpha = 0.3) +
  geom_point() + # 1.5
  geom_text_repel(aes(label = num), cex = 3, segment.size = 0.2, segment.alpha = 0.5)+
  geom_text(x = 0,
            y = -Inf,
            label = paste0(inertLD1, "%"),
            color = "black",
            vjust = -1,
            size = 2,
            alpha = 0.5) +
  geom_text(x = -Inf,
            y = 0,
            label = paste0(inertLD2, "%"),
            color = "black",
            vjust = 1,
            angle = 90,
            size = 2,
            alpha = 0.5) +
  theme(plot.title = element_text(size = 8, face = "bold")) +
  theme(axis.text=element_text(size=5),
        axis.title.x=element_text(size=8),
        axis.title.y=element_text(size=8)) +
  theme(axis.ticks = element_line(size = 0.2)) +
  theme(legend.position = "none")+
  theme(strip.text.x = element_text(size=8),
        strip.text.y = element_blank()) +
  theme(panel.border = element_rect(colour='black',fill=NA,size = 0.2)) +
  theme(panel.background = element_rect(fill = 'transparent')) +
  theme(panel.spacing.y = unit(0,"lines")) +
  scale_colour_identity() +
  scale_shape_identity()
glda

# sauver
png("out/lda_depots.png", width = 8, height = 8, units = "cm", res = 300)
glda
dev.off()
shell.exec(paste0(getwd(), "/out/lda_depots.png"))

