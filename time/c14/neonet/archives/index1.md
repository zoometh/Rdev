---
title: | 
  | **NeoNet app** 
  | mapping radiocarbon dating online
author: "Thomas Huet, Niccolo Mazzucco"
# date: "11/12/2020"
header-includes:
  - \usepackage{float}
  - \floatplacement{figure}{H}  #make every figure with capti
# output: html_document
output: 
  bookdown::html_document2:
    number_sections: false
    keep_md: true
  # html_document:
    toc: true
    toc_float: 
      collapsed: false
      smooth_scroll: false
---



<p style="text-align: center;"> <font size="5">
[![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_map.png){width=50%}](https://neolithic.shinyapps.io/neonet/)<br>
the [**NeoNet app**](https://neolithic.shinyapps.io/neonet/)</font>
</p>  


# **Presentation**

The **NeoNet app** allows the selection of radiocarbon dating by location, chronology and material life duration by subsetting a radiocarbon dataset according to: 

* a geographical region of interest (ROI) and a selection shape
* a time span between a *tpq* and a *taq* in cal BC
* some periods
* some type of material life duration (short like, long life or others)
* a maximum accepted standard deviation threshold (SD)

The chronological span covers the Late Mesolithic and the Early Neolithic. The region of interest is the Central and Western Mediterranean and more precisely the Mediterranean watersheds of this area

<p style="text-align: center;">
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/ws_roi.png){width=35%}
</p>

We will see how to use the [**NeoNet app**](#app), what is the [**NeoNet database**](#bd) and our [**Objectives**](#particip)

# **NeoNet app** {#app}

The app is a [RShiny](https://shiny.rstudio.com/) hosted on the [**shinyapps.io**](https://www.shinyapps.io/) server. The app is divided into five (5) panels:

1. [**map** panel](#panel.map): ROI with selection menus
2. [**calib** panel](#panel.calib): calibration of the selected dates
3. [**data** panel](#panel.data): the whole dataset
4. [**biblio** panel](#panel.biblio): bibliographical references
5. [**infos** panel](#panel.infos): credits and link to the webpage handbook of the app

To calibrate one or various dates in the [**calib** panel](#panel.calib), a date has to be clicked in the [**map** panel](#panel.map).

<center>

![click on a date to calibrate a selected group of dates](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_map_select.png){width=250px}

</center>

This date will be shown **bolded** on the [**calib** panel](#panel.calib) output figure

## 1. **map** panel {#panel.map}
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_map_idx.png){width=20%}
  
 
The panel **map** is a geographical window provided by the [Leaflet](https://rstudio.github.io/leaflet/) package. This panel is used for selection of radiocarbon dates [by location](#panel.map.select.loc), [by chronology](#panel.map.select.chr), [by quality of dates](#panel.map.select.quali).  


<div class="figure" style="text-align: center">
<img src="index1_files/figure-html/panel-map1-1.png" alt="The different menus of the map panel"  />
<p class="caption">(\#fig:panel-map1)The different menus of the map panel</p>
</div>
  
The current functions are:

* Fig. \@ref(fig:panel-map1), <span style="color:red"><u>red</u></span> box, top-left button ***group C14 on map***: allows to cluster dates by spatial proximities ([Marker Clusters](http://rstudio.github.io/leaflet/markers.html)) 

* Fig. \@ref(fig:panel-map1), <span style="color:pink"><u>pink</u></span> box, top-right layer button: allows to change the basemap. By default, the basemap is **OSM**, an [OpenStreetMap general basemap](https://leaflet-extras.github.io/leaflet-providers/preview/#filter=OpenStreetMap.Mapnik), but it can be switch to **Topo**, an [ESRI topographical basemap](https://leaflet-extras.github.io/leaflet-providers/preview/#filter=Esri.WorldImagery)

* Fig. \@ref(fig:panel-map1), <span style="color:darkgrey"><u>grey</u></span> box, bottom inline text: reactive count of selected dates and select sites 

* Fig. \@ref(fig:panel-map1), <span style="color:green"><u>green</u></span> box, bottom table: reactive datatable ([DT package](https://cran.r-project.org/web/packages/DT/index.html)) listing all the dates within the map extent (ROI) and the optional selection menus (tpq/taq, material life duration, maximum SD, periods, selection shapes)

### select by location {#panel.map.select.loc}

By default only the data within the window extent (ROI) will be selected. But selection shapes can be drawn inside this ROI to have a spatial intersection:
  
* Fig. \@ref(fig:panel-map1), <span style="color:black"><u>black</u></span> box, top-left draw toolbar: selection shapes, ***polygons*** and ***rectanges***, can *freeze* the date selection inside a given ROI. They can be removed with the trash button. All the dates inside the ROI and selected with the others filters will be visible on the map, but only those inside the selections shapes will be calibrated  

<center>

![selection inside a shape, here a single polygon. Before shape selection: 190 sites and 895 dates. After shape selection: 13 sites and 68 dates](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_map_shape.png){width=700px}

</center>

#### retrieve coordinates from the map

As said, the default basemap of the app is OSM. It offers a well documented basemap where archaeological sites are sometimes already located, like the Ligurian site of [Grotta della Pollera](https://www.openstreetmap.org/#map=19/44.20058/8.31466). Clicking on the map show the lat/long coordinates of the current point (under the tpq/tap slider). These coordinates can then be copied and used to modify the NeoNet database

<center>

![get coordinates by clicking on the map](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_map_coords.png){width=250px}

</center>

### select by chronology {#panel.map.select.chr}

* Fig. \@ref(fig:panel-map1), <span style="color:brown"><u>brown</u></span> box, top-right checkboxes: allow to select dating by periods

* Fig. \@ref(fig:panel-map1), <span style="color:orange"><u>orange</u></span> box, bottom-left legend: reactive legend periods is a dynamic list of periods which exist in the selected periods

* Fig. \@ref(fig:panel-map1), <span style="color:blue"><u>blue</u></span> box, bottom-left slider: allows to subset a range of accepted dates between a *tpq* and a *taq* (in cal BC)

### select by dates quality {#panel.map.select.quali}

* Fig. \@ref(fig:panel-map1), <span style="color:purple">purple</span> box, bottom-right checkboxes and slider: a group of menus for selection on the material life duration and max accepted SD:
  + relatively to the duration of their material (short to long-life material)
  + below a maximum accepted threshold for the standard deviations (SD) for the dates


## 2. **calib** panel {#panel.calib}
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_calib_idx.png){width=20%}


The panel **calib** is used for dates on-the-fly calibration with the R packages [Bchron](https://cran.r-project.org/web/packages/Bchron/index.html) and [rcarbon](https://cran.r-project.org/web/packages/rcarbon/index.html). Calibrations are done on the whole dataset of dates displayed in the [table of the **map panel**](#panel.map). If the dates are numerous (eg > 100) the computing time could take times.

### c14 group by *filter* {#panel.calib.group}

The only selection which can be done is on the top-center radio button  (Fig. \@ref(fig:panel-calib), <span style="color:red"><u>red</u></span> box). The **c14 group by** filter allows to plot dates and to sum their probability densities depending on different levels of grouping:

* **by date**: each date is plot separately (by default)

* **by PhaseCode**: dates from the same site, having the same archaeological unit (layer, structure, etc.), are summed. See the [PhaseCode](#mf.phasecode) field.

* **by site and period**: dates from the same site, having the same period are summed

* **by period**: dates having the same period are summed  

* **all C14**: all dates are summed 

<div class="figure" style="text-align: center">
<img src="index1_files/figure-html/panel-calib-1.png" alt="The different menus of the calib panel"  />
<p class="caption">(\#fig:panel-calib)The different menus of the calib panel</p>
</div>

### plot area *output*

The plot area (Fig. \@ref(fig:panel-calib), <span style="color:orange"><u>orange</u></span> box) shows dynamically the SPD of the cabibrated dates seriated on their weighted means. The top-right  button **Download** (Fig. \@ref(fig:panel-calib), <span style="color:green"><u>green</u></span> box) allows to export the last plot in a PNG image

<p style="text-align: center;">
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/neonet_calib_example.png){width=80%}
</p>

## 3. **data** panel {#panel.data}
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_data_idx.png){width=20%}

The complete database from the GitHub  [c14data.tsv](https://github.com/zoometh/C14/blob/main/neonet/c14data.tsv) file (a dataframe with tab-separated values). The first rows are:

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Country </th>
   <th style="text-align:right;"> Latitude </th>
   <th style="text-align:right;"> Longitude </th>
   <th style="text-align:left;"> SiteName </th>
   <th style="text-align:left;"> Period </th>
   <th style="text-align:left;"> PhaseCode </th>
   <th style="text-align:left;"> LabCode </th>
   <th style="text-align:right;"> C14BP </th>
   <th style="text-align:right;"> C14SD </th>
   <th style="text-align:left;"> Material </th>
   <th style="text-align:left;"> bib </th>
   <th style="text-align:left;"> bib_url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.52 </td>
   <td style="text-align:right;"> 4.82 </td>
   <td style="text-align:left;"> Espeluche-Lalo </td>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> St. 76 </td>
   <td style="text-align:left;"> AA-32638 </td>
   <td style="text-align:right;"> 6560 </td>
   <td style="text-align:right;"> 85 </td>
   <td style="text-align:left;"> WC </td>
   <td style="text-align:left;"> Beeching et al. 2000 </td>
   <td style="text-align:left;"> Beeching00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.52 </td>
   <td style="text-align:right;"> 4.82 </td>
   <td style="text-align:left;"> Espeluche-Lalo </td>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> St. 73 </td>
   <td style="text-align:left;"> AA-32639 </td>
   <td style="text-align:right;"> 6520 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:left;"> WC </td>
   <td style="text-align:left;"> Beeching et al. 2000 </td>
   <td style="text-align:left;"> Beeching00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.52 </td>
   <td style="text-align:right;"> 4.82 </td>
   <td style="text-align:left;"> Espeluche-Lalo </td>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> St. 120 </td>
   <td style="text-align:left;"> AA-32641 </td>
   <td style="text-align:right;"> 6585 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> WC </td>
   <td style="text-align:left;"> Beeching et al. 2000 </td>
   <td style="text-align:left;"> Beeching00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.52 </td>
   <td style="text-align:right;"> 4.82 </td>
   <td style="text-align:left;"> Espeluche-Lalo </td>
   <td style="text-align:left;"> LM </td>
   <td style="text-align:left;"> St. 8 </td>
   <td style="text-align:left;"> AA-32642 </td>
   <td style="text-align:right;"> 7315 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:left;"> WC </td>
   <td style="text-align:left;"> Beeching et al. 2000 </td>
   <td style="text-align:left;"> Beeching00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.32 </td>
   <td style="text-align:right;"> 4.47 </td>
   <td style="text-align:left;"> Baume d'Oullins </td>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> C6B </td>
   <td style="text-align:left;"> AA-53291 </td>
   <td style="text-align:right;"> 6233 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> Garcia-Puchol et Salazar-Garcia 2017 </td>
   <td style="text-align:left;"> 10.1007/978-3-319-52939-4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 44.32 </td>
   <td style="text-align:right;"> 4.47 </td>
   <td style="text-align:left;"> Baume d'Oullins </td>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> n/a </td>
   <td style="text-align:left;"> AA-53292 </td>
   <td style="text-align:right;"> 6210 </td>
   <td style="text-align:right;"> 69 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> Garcia-Puchol et Salazar-Garcia 2017 </td>
   <td style="text-align:left;"> 10.1007/978-3-319-52939-4 </td>
  </tr>
</tbody>
</table>

At first, these data are recorded in a Excel spreadsheet (c14 spreadsheet) in order to facilitate their editing (filter, sorting, fill). Then a R function read this spreadsheet, calculate the *tpq* and *taq* (in BC) of each unCal BP (with [Bchron](https://cran.r-project.org/web/packages/Bchron/index.html)),  and convert it into a .tsv file. As data came from various publications, an homogenization the different values (material, cultures, bibliographical references, etc.) must be done. The database **mandatory fields** are:

* **SiteName**: the site name
* **Longitude**: in decimal degrees (ex: `1.045`)
* **Latitude**: in decimal degrees (ex: `43.921`)
* **Period**: a value from the [**period.abrev**](#bd.period) spreadsheet
* [**PhaseCode**](#mf.phasecode): a code for the dating stratigaphical unit and/or structure
* **C14Age**: a numerical radiocarbon dating in BP
* **C14SD**: the standard deviation (SD) of the radiocarbon dating
* [**LabCode**](#mf.labcode): the unique identifier of the radiocarbon dating
* **Material**: a value from the [**material.life**](#bd.material) spreadsheet 
* **tpq**: the *terminus post quem* of the radiocarbon dating in cal BC
* **taq**: the *terminus ante quem* of the radiocarbon dating in cal BC
* [bibliographical references (two fields)](#mf.bib_all)
  + [**bib**](#mf.bib): a short plain text bibliographical reference
  + [**bib_url**](#mf.bib_url): a DOI or a BibTex key bibliographical reference

The **recommended** fields are:

* **MaterialSpecies**: a specification of the field **Material**
* **Culture**: a specification of the field **Period**

The others fields (if there's any) only concern the **[EUROEVOL_R app](https://zoometh.github.io/C14)** 

#### mandatory fields

Here we explain more precisely some of the mandatory fields

##### **PhaseCode** {#mf.phasecode}

The PhaseCode field provide a more precise archaeological context than the site name. It is useful for [**layer/structure C14 grouping**](#panel.calib.group). Most of the time, it correspond to an archaeological layer or structure

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> PhaseCode </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> C5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C7-8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> foyer 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> niv. II </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ... </td>
  </tr>
</tbody>
</table>

This values of this field needs to be homogeneized (for example: `C.5` -> `C5`), at first for the same sites, then for the whole dataset 

##### **LabCode** {#mf.labcode}

The conventional syntax for a laboratory code (**LabCode**) is '*AbrevLab*-*number*', respecting the case letters (upper case and lower case) For example:

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> LabCode </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Beta-103487 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CSIC-1133 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ETH-15984 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gif-1855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GrN-6706 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KIA-21356 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LTL-13440A </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ly-11338 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MC-2145 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> OxA-9217 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Poz-18393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ... </td>
  </tr>
</tbody>
</table>

##### **bib** and **bib_url** {#mf.bib_all}

Every radiocarbon date should be referenced with a bibliographical reference with a plain text in the [**bib**](#mf.bib) field and and a DOI or a BibTex key in the [**bib_url**](#mf.bib_url) field. We favor the earliest mention of the radiocarbon date

###### **bib** {#mf.bib}

The plain text that will be plot for each radiocarbon date under the bibliographical reference section. Basically the name of the author(s) and the publication year, for example `Guilaine et al. 1993`, `Binder 2018` or `Manen et Sabatier 2013`

###### **bib_url** {#mf.bib_url}

Either a DOI (starting with "`10`") or a unique BibTeX key. We favor the DOI as a unique bibliographical reference. For example: 

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> tpq </th>
   <th style="text-align:left;"> taq </th>
   <th style="text-align:left;"> select </th>
   <th style="text-align:left;"> RedNeo </th>
   <th style="text-align:left;"> bib </th>
   <th style="text-align:left;"> bib_url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> -6086 </td>
   <td style="text-align:left;"> -5923 </td>
   <td style="text-align:left;"> VRAI </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Binder et al. 2018 </td>
   <td style="text-align:left;"> <b>https://doi.org/10.4312/dp.44.4</b> </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
  </tr>
</tbody>
</table>

When the DOI is lacking, the bibliographical reference should be include into the BibTex document [references.bib](https://raw.githubusercontent.com/zoometh/C14/master/neonet/references_france.bib) with the name of the first author and the two last digits of the year:


```r
@book{Guilaine93,
  title={Dourgne: derniers chasseurs-collecteurs et premiers {\'e}leveurs de la Haute-Vall{\'e}e de l'Aude},
  author={Guilaine, Jean and Barbaza, Michel},
  year={1993},
  publisher={Centre d'anthropologie des soci{\'e}t{\'e}s rurales; Arch{\'e}ologie en Terre d'Aude}
}
```

The key of this reference is added to the **bib_url** field. For example, the key value **Guilaine93** from the c14 spreadsheet will match this complete reference 

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> tpq </th>
   <th style="text-align:left;"> taq </th>
   <th style="text-align:left;"> select </th>
   <th style="text-align:left;"> RedNeo </th>
   <th style="text-align:left;"> bib </th>
   <th style="text-align:left;"> bib_url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> -3330 </td>
   <td style="text-align:left;"> -2492 </td>
   <td style="text-align:left;"> FAUX </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Guilaine et al. 1993 </td>
   <td style="text-align:left;"> <b>Guilaine93</b> </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
   <td style="text-align:left;"> ... </td>
  </tr>
</tbody>
</table>

### correspondance tables

The NeoNet app makes joins to two tables in order to retrieve information and to provide a handy user interface

#### material.life {#bd.material}

Material life duration are read from the GitHub  [c14_material_life.tsv](https://github.com/zoometh/C14/blob/main/neonet/c14_material_life.tsv) file. The two fields show the material type (column 1) and the material life duration (column 2), for example: 

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> material.type </th>
   <th style="text-align:left;"> life.duration </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Drusch - trilladura </td>
   <td style="text-align:left;"> long.life </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Agla </td>
   <td style="text-align:left;"> long.life </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Angiosperma </td>
   <td style="text-align:left;"> long.life </td>
  </tr>
  <tr>
   <td style="text-align:left;"> animal bone </td>
   <td style="text-align:left;"> short.life </td>
  </tr>
  <tr>
   <td style="text-align:left;"> animal hair </td>
   <td style="text-align:left;"> short.life </td>
  </tr>
  <tr>
   <td style="text-align:left;"> antler </td>
   <td style="text-align:left;"> short.life </td>
  </tr>
</tbody>
</table>

#### period.abrev {#bd.period}

Periods and periods abbreviations are read from the GitHub  [c14_period_abrev.tsv](https://raw.githubusercontent.com/zoometh/C14/master/neonet/c14_period_abrev.tsv) file. The two fields show the period abbreviation (column 1) and the period full label (column 2), for example:

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> period.brev </th>
   <th style="text-align:left;"> period </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> EM </td>
   <td style="text-align:left;"> Early Mesolithic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MM </td>
   <td style="text-align:left;"> Middle Mesolithic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LM </td>
   <td style="text-align:left;"> Late Mesolithic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UM </td>
   <td style="text-align:left;"> Undefined Mesolithic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LMEN </td>
   <td style="text-align:left;"> Late Mesolithic/Early Neolithic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EN </td>
   <td style="text-align:left;"> Early Neolithic </td>
  </tr>
</tbody>
</table>


In the NeoNet app, this database is rendered with the ([DT package](https://cran.r-project.org/web/packages/DT/index.html)) allowing sorting and filtering tools

## 4. **biblio** panel {#panel.biblio}
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_biblio_idx.png){width=20%}

Bibliographical references from the GitHub [c14refs.tsv](https://github.com/zoometh/C14/blob/main/neonet/c14refs.tsv) file. If only exist a BibTeX key, and no DOI, this file results of the join between the *bib_url* field of the C14 spreadsheet and the *references.bib*. If the DOI exists, the full bibliographical reference is  file The first rows are:

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> short.ref </th>
   <th style="text-align:left;"> key.or.doi </th>
   <th style="text-align:left;"> long.ref </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Beeching et al. 2000 </td>
   <td style="text-align:left;"> Beeching00 </td>
   <td style="text-align:left;"> Beeching A, Brochier J, Cordier F (2000). “La transition Mésolithique-Néolithique entre la plaine du Rhône moyen et ses bordures préalpines.” _Les Paléoalpins e Hommage à Pierre Bintz, Géologie Alpine e Mémoire Hs_, *31*, 201-210. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garcia-Puchol et Salazar-Garcia 2017 </td>
   <td style="text-align:left;"> 10.1007/978-3-319-52939-4 </td>
   <td style="text-align:left;"> García-Puchol, O., &amp; Salazar-García, D. C. (Eds.). (2017). Times of Neolithic Transition along the Western Mediterranean. Fundamental Issues in Archaeology. doi:10.1007/978-3-319-52939-4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Binder et al. 2002 </td>
   <td style="text-align:left;"> Binder02 </td>
   <td style="text-align:left;"> Binder D, Jallot L, Thiebault S, others (2002). “Les occupations néolithiques des Petites Bâties (Lamotte-du-Rhône, Vaucluse).” _Archéologie du TGV Méditerranée: fiches de synthèse_, *1*, 103-122. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Perrin et Defranould 2016 </td>
   <td style="text-align:left;"> 10.1016/j.quaint.2015.09.046 </td>
   <td style="text-align:left;"> Perrin, T., &amp; Defranould, E. (2016). The Montclus rock shelter (Gard) and the continuity hypothesis between 1st and 2nd Mesolithic in Southern France. Quaternary International, 423, 230–241. doi:10.1016/j.quaint.2015.09.046 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nicod et al. 2019 </td>
   <td style="text-align:left;"> 10.1080/00934690.2019.1580077 </td>
   <td style="text-align:left;"> Nicod, P.-Y., Perrin, T., Le Bourdonnec, F.-X., Philibert, S., Oberlin, C., &amp; Besse, M. (2019). First Obsidian in the Northern French Alps during the Early Neolithic. Journal of Field Archaeology, 44(3), 180–194. doi:10.1080/00934690.2019.1580077 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Binder et al. 2017 </td>
   <td style="text-align:left;"> 10.15184/aqy.2017.65 </td>
   <td style="text-align:left;"> Binder, D., Battentier, J., Delhon, C., &amp; Sénépart, I. (2017). In pursuit of a missing transition: the Mesolithic and Neolithic radiocarbon chronology at La Font-aux-Pigeons rockshelter. Antiquity, 91(357), 605–620. doi:10.15184/aqy.2017.65 </td>
  </tr>
</tbody>
</table>

In the NeoNet app, these bibliographical references are rendered in APA citation format (field `long.ref`) 

## 5. **infos** panel {#panel.infos}
![](C:/Users/supernova/Dropbox/My PC (supernova-pc)/Documents/C14/docs/imgs/panel_infos_idx.png){width=20%}

Infos, credits and link to this webpage (https://zoometh.github.io/C14/neonet)

# **Objectives** {#particip}

Today, the **NeoNet app** release is online. At the short-term, and in the frame of [**FAIR** Open Science principles](https://www.go-fair.org/fair-principles/) (*Findable*, *Accessible*, *Interoperable* & *Reusable*), our publication plan is:

1. publish the **NeoNet database** in a Open Data repository (ex: [Zenodo](https://zenodo.org/))
2. reference the **NeoNet database**  in a data paper (ex: [JOAD](https://openarchaeologydata.metajnl.com/))
3. publish the RShiny **NeoNet app** source code in a Open digital humanities paper (ex: [JOSS](https://joss.theoj.org/))
  
Thanks to the facilities offer by the app, and in the frame of the **[NeoNet project](https://redneonet.com)**, conducted by [Juan Gibaja](https://orcid.org/0000-0002-0830-3570) and [Miriam Cubas](https://orcid.org/0000-0002-2386-8473), we expect to conduct collaborative spatio-temporal analysis for the origin, the spread and the consolidation of the farming way-of-life in Mediterranean. Beside the database and the app publications, we will also:

* publish the archaeological result(s) in scientific paper(s) (*journal to be defined*)
* present the results and the app in conferences, seminars, etc.

Contact <nicco.mazzucco@gmail.com> for database and data integration, and <thomashuet7@gmail.com> for app updates and IT integration
