library(dplyr)
library(leaflet)
library(sf)
library(httr)
library(htmlwidgets)

url.sith <- "http://sith.huma-num.fr/karnak/"
url.3dhop <- "https://zoometh.github.io/3DHOP/minimal/"
url.html <- "https://api.github.com/repos/zoometh/3DHOP/git/trees/master?recursive=1"

## Not Run, local use only
# locus <- st_read(dsn = "D:/Sites_10/Karnak", layer = "locus")
# locus <- cbind(locus, st_coordinates(locus))
# locus$geometry <- NULL

locus <- read.csv("www/locus.csv", sep = ";", row.names = NULL)
locus$url <- paste0('<a href=', shQuote(paste0(url.sith, locus$KIU)),
                    "\ target=\"_blank\"",">", paste0("KIU",locus$KIU), "</a>")
req <- GET(url.html)
stop_for_status(req)
filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
D3.models <- grep("minimal/.*html$", filelist, value = TRUE)
D3.models <- gsub("minimal/", "", D3.models)
D3.models <- sort(gsub(".html$", "", D3.models))
nm.models <- locus[locus$url %in% D3.models, "D3"]
nb.models <- length(nrow(nm.models))

monum.3D <- locus[locus$D3 %in% D3.models, ]
monum.others <- locus[!(locus$D3 %in% D3.models), ]
monum.3D.icons <- icons(
  iconUrl = "https://raw.githubusercontent.com/zoometh/rockart/main/www/icon_3dhop.png",
  iconWidth = 40, iconHeight = 56,
  iconAnchorX = 0, iconAnchorY = 0
)
monum.3D$desc <- paste0(monum.3D$url, " : ", monum.3D$nom, '<br><a href=',
                        shQuote(paste0(url.3dhop, monum.3D$D3, ".html")),
                        "\ target=\"_blank\"",">","<b> modèle 3D </b>", "</a>")
monum.3D$desc[monum.3D$KIU == 2610] <- paste0("crédit : ", monum.3D$desc, "(", monum.3D$credit3D, ")")
monum.others$desc <- paste0(monum.others$url, " : ", monum.others$nom)
carte <- leaflet() %>%
  addTiles(group = 'OSM') %>%
  addProviderTiles("Esri.WorldImagery", group = "Ortho") %>%
  addCircleMarkers(data = monum.others,
                   lng = ~X,
                   lat = ~Y,
                   popup = ~desc,
                   color = ~couleur,
                   radius = 15,
                   opacity = .5) %>%
  addMarkers(data = monum.3D,
             lng = ~X,
             lat = ~Y,
             popup = ~desc,
             icon = monum.3D.icons) %>%
  addLayersControl(
    baseGroups = c('Ortho', 'OSM')) %>%
  addScaleBar(position = "bottomleft")
carte
# save
saveWidget(carte, file="Karnak.html")
