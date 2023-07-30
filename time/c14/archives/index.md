---
title: | 
  | **A radiocarbon review**: 
  | Apps, databases, calibrations and analysis
author: "Thomas Huet"
runtime: shiny
output: 
  html_document:
    highlight: tango
    toc: true
    toc_depth: 3
    toc_float:
      collapsed: false
      smooth_scroll: false
---



Today exists various web-based open access ressources for [database](#c14.db), [calibrations](#c14.cal),  [interactive selection and spatialization](#c14.app) and [analysis](#c14.analysis) 

# Applications {#c14.app}


<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> names </th>
   <th style="text-align:left;"> url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> MedAfriCarbon </td>
   <td style="text-align:left;"> https://theia.arch.cam.ac.uk/MedAfriCarbon/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NeoNet </td>
   <td style="text-align:left;"> https://zoometh.github.io/C14/neonet </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EUROEVOL_R </td>
   <td style="text-align:left;"> https://neolithic.shinyapps.io/Euroevol_R/ </td>
  </tr>
</tbody>
</table>

**MedAfriCarbon**, **NeoNet** and **EUROEVOL_R** allow interactive web form map-based for  of radiocarbon dates selection by geographical region of interest, time span and periods, quality of the date, etc. These apps offer also analysis tools like summing probability densities (SPD). 
These apps have been developped with [R](https://www.r-project.org/) programming language and the [Shiny](https://shiny.rstudio.com/) package

## MedAfriCarbon {#c14.app.MedAfriCarbon}

* **[MedAfriCarbon app](https://theia.arch.cam.ac.uk/MedAfriCarbon/)** covers the South Mediterranean between the beginning of the Holocene ) and the arrival of Phoenicians and Greeks (ca. 9,600 - 600 BC) with near 1,600 radiocarbon dates

<p style="text-align: center;">
![](https://raw.githubusercontent.com/zoometh/C14/main/docs/imgs/app_mediafricarbon_thumbnail.png){width=50%}
</p>

The [MedAfriCarbon](https://theia.arch.cam.ac.uk/MedAfriCarbon/) offers an almost complete toolbox to manage radiocarbon dates


## NeoNet and EUROEVOL_R {#c14.app.14C}

**NeoNet** and **EUROEVOL_R** share the same layout, mostly inherited from the EUROEVOL database, only the datasets are differents

* **[NeoNet app](https://neolithic.shinyapps.io/NeoNet/)** covers the Northern Central Mediterranean between the Late Mesolithic and Middle Neolithic (ca. 8,000 - 4,500 BC) with near to 1,500 radiocarbon dates  

<p style="text-align: center;">
![](https://raw.githubusercontent.com/zoometh/C14/main/docs/imgs/panel_map.png){width=50%}
</p>

The database, an Excel Sheet, see the [**NeoNet app** webpage](https://zoometh.github.io/C14/neonet/#app)

* **[EUROEVOL_R app](https://neolithic.shinyapps.io/Euroevol_R/)** covers the Central, Western and Northern Europe from Paleolithic times to the end of Bronze Age (ca. 17,000 - 500 BC) with near to 14,000 radiocarbon dates  

<p style="text-align: center;"> ![](https://raw.githubusercontent.com/zoometh/C14/main/docs/imgs/app_euroevol_thumbnail.png){width=50%}
</p>

The database is the [EUROEVOL database](http://discovery.ucl.ac.uk/1469811/), is opensource and static (yet developed), see the [**EUROEVOL_R app** webpage](https://zoometh.github.io/C14/euroevol)

# Databases {#c14.db}

An almost exhaustive inventory of open databases has been made on the [c14bazAAR repository](https://github.com/ropensci/c14bazAAR#databases)

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> names </th>
   <th style="text-align:left;"> url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> EUROEVOL </td>
   <td style="text-align:left;"> http://discovery.ucl.ac.uk/1469811 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Radon </td>
   <td style="text-align:left;"> https://radon.ufg.uni-kiel.de/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ORAU </td>
   <td style="text-align:left;"> https://c14.arch.ox.ac.uk </td>
  </tr>
  <tr>
   <td style="text-align:left;"> telearchaeology </td>
   <td style="text-align:left;"> http://telearchaeology.org/c14-databses/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Archaeological Site Index to Radiocarbon Dates from Great Britain and Ireland </td>
   <td style="text-align:left;"> http://www.britarch.ac.uk/info/c14.html </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14SEA Project </td>
   <td style="text-align:left;"> http://www.14sea.org/2_dates.html </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EX ORIENTE </td>
   <td style="text-align:left;"> https://www.exoriente.org/associated_projects/ppnd_sites.php </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BANADORA </td>
   <td style="text-align:left;"> http://www.archeometrie.mom.fr/banadora/ </td>
  </tr>
</tbody>
</table>

R progamming language permits to download radiocarbon data from databases. With [c14bazAAR package](https://github.com/ropensci/c14bazAAR),  [RShiny](https://shiny.rstudio.com/) and [Leaflet](https://rstudio.github.io/leaflet/), it is possible to plot interactive map of radiocarbon dates coming from different databases 

<!--html_preserve--><div class="form-group shiny-input-container" style="width: 25%;">
<label class="control-label" for="c14.db">c14 databases sample</label>
<div>
<select id="c14.db"><option value="emedyd">emedyd</option>
<option value="eubar">eubar</option>
<option value="euroevol">euroevol</option>
<option value="context">context</option>
<option value="katsianis" selected>katsianis</option>
<option value="medafricarbon">medafricarbon</option>
<option value="radon">radon</option></select>
<script type="application/json" data-for="c14.db" data-nonempty="">{}</script>
</div>
</div><!--/html_preserve-->

<!--html_preserve--><div id="outb6cdb8344d8abba8" style="width:100%; height:400px; " class="leaflet html-widget html-widget-output"></div><!--/html_preserve-->

It is also possible to retrieve data (site, c14age, c14std, etc.). As an example, let's load the [Radon database](https://radon.ufg.uni-kiel.de/","https://c14.arch.ox.ac.uk) with the [c14bazAAR package](https://github.com/ropensci/c14bazAAR)


```r
radonC14 <- get_c14data("radon")
```

```
## Trying to download all dates from the requested databases...
```

```
##   |                                                          |                                                  |   0%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++|  99%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
```

And retrieve data from a radiocarbon date LabCode, for example, the 'Ly-11645' LabCode: 


```r
radonC14[radonC14$labnr == 'Ly-11645',
         c("site", "labnr","c14age","c14std", "shortref")]
```

```
## 	Radiocarbon date list
## 	dates: 4
## 	sites: 2
## 	uncalBP: 6000 <U+2015> 6000 
## 
## # A data frame: 4 x 5
##   site         labnr    c14age c14std shortref
##   <chr>        <chr>     <int>  <int> <chr>   
## 1 <NA>         <NA>         NA     NA <NA>    
## 2 <NA>         <NA>         NA     NA <NA>    
## 3 Gazel Grotte Ly-11645   6035     85 <NA>    
## 4 <NA>         <NA>         NA     NA <NA>
```

# Calibrations {#c14.cal}

<table class="table" style="font-size: 12px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> type </th>
   <th style="text-align:left;"> names </th>
   <th style="text-align:left;"> url </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> dedicated </td>
   <td style="text-align:left;"> OxCal </td>
   <td style="text-align:left;"> https://c14.arch.ox.ac.uk/oxcal/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dedicated </td>
   <td style="text-align:left;"> CalPal </td>
   <td style="text-align:left;"> http://www.calpal-online.de/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dedicated </td>
   <td style="text-align:left;"> Calib </td>
   <td style="text-align:left;"> http://calib.org/calib/ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> R programming </td>
   <td style="text-align:left;"> rcarbon </td>
   <td style="text-align:left;"> https://cran.r-project.org/web/packages/rcarbon/index.html </td>
  </tr>
  <tr>
   <td style="text-align:left;"> R programming </td>
   <td style="text-align:left;"> Bchron </td>
   <td style="text-align:left;"> https://cran.r-project.org/web/packages/Bchron/index.html </td>
  </tr>
  <tr>
   <td style="text-align:left;"> R programming </td>
   <td style="text-align:left;"> oxcAAR </td>
   <td style="text-align:left;"> https://cran.r-project.org/web/packages/oxcAAR/index.html </td>
  </tr>
</tbody>
</table>

# Analysis {#c14.analysis}

R offers a comprehensive framework to calibrate, plot, sum and use temporal constraints -- stratigraphy, periodisations, etc., like bayesian analysis -- on radiocarbon datasets. 
Free software offering a dedicated solution for bayesian inference are: [ChronoModel](https://chronomodel.com/), [OpenBUGS](http://www.openbugs.net/w/FrontPage), [JAGS](http://mcmc-jags.sourceforge.net/), etc.

For a overview of the available solutions, see the [R Bayesian task view](https://cran.r-project.org/web/views/Bayesian.html)


