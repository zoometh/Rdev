# Kharaysin

Original photograph:

![](doc/img1.jpg)

Remove the scale:

![](doc/img1-noscale.jpg)

Convert to B/W:

![](doc/img1-bw.jpg)

Run [kharaysin.R](https://github.com/zoometh/Rdev/blob/master/gmm/kharaysin/kharaysin.R):

```R
# remotes::install_github("zoometh/outlineR")
library(outlineR)

sampling <- T

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

inpath <- "./img/input_data"
jpgs <- "./img/out"

separate_single_artefacts(inpath = inpath,
                          outpath = jpgs)
```

Will creates individual objects

![](doc/img1-001.jpg)

Run [crop.py](https://github.com/zoometh/Rdev/blob/master/gmm/kharaysin/crop.py):

```Python
py "C:\Rprojects\Rdev\gmm\kharaysin\crop.py"
```

Will crop the individual images

![](doc/img1-002.jpg)

Open all the individual images in QGIS


