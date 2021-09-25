# Rdev
> Test Files and Functions for R, Python and JavaScript

## 3D model management and viewers with open softwares

Low-resolution photogrammetric model of engraved rocks from the Mont Bego rock-art site (Alpes-Maritimes, France) with: 

* Python programming 

* [3DHOP framework](https://3dhop.net/)

I've forked the [3DHOP repo](https://github.com/cnr-isti-vclab/3DHOP) -> to [https://github.com/zoometh/3DHOP](https://github.com/zoometh/3DHOP). A `.nxz` file is created from `.obj` files with [Nexus](http://vcg.isti.cnr.it/nexus/):

* function [nxsbuild](https://github.com/cnr-isti-vclab/nexus/blob/master/doc/nxsbuild.md#nxsbuild): `.obj` -> `.nxs` 
* function [nxscompress](https://github.com/cnr-isti-vclab/nexus/blob/master/doc/nxscompress.md#nxscompress): `.nxs` -> `.nxz`

### 3DHOP

3D models stored on GitHub, using 3DHOP fork. See their location on my [rockart repo](https://zoometh.github.io/rockart/)

### Python + pywavefront + pyglet

Photogrammetric files of the *Roche de l'archer*, and Python code are stored on GitHub: 

* **Files**: `roche_archer_2` + `.obj` + `.mlt` + `.jpg` : files coming from the rock-art low-resolution photogrammetric model (Wavefront Stanford object). [See it on Sketchlab](https://sketchfab.com/3d-models/roche-archer-2-a5c0771d898d4816950570cd7fb1be37).

* **Code**: [`roche_archer_2` + `.pyw`](https://github.com/zoometh/Rdev/blob/master/roche_archer_2.pyw) : a Python 3 code script inspired by [this GitHub document](https://github.com/pywavefront/PyWavefront/blob/master/examples/globe_simple.py). This script allows to: 

  + read the photogrammetric model
  
  + create a rotation view in a RGL window
  
  
<p align="center">
  <img alt="img-name" src="www/snapshot_roche_archer_2.png" width="500">
  <br>
    <em>snapshot from the RGL window generated from the Python script</em>
</p>
  
## Miscellaneous of R functions

Set of statistical functions for uni-, bi-, and multi-variate dataframes, with data and outputs

| statistics    | data          |code          |output          |
| ------------- | ------------- |--------------|----------------|
| regressions   | [data_regression.csv](https://github.com/zoometh/Rdev/blob/master/data/data_regression.csv)  | [regressions.R](https://github.com/zoometh/Rdev/blob/master/functions/regressions.R) | [reg_depots.png](https://github.com/zoometh/Rdev/blob/master/out/reg_depots.png)| 
| CA            | [data_factor_analysis.csv](https://github.com/zoometh/Rdev/blob/master/data/data_factor_analysis.csv) | [factor_analysis.R](https://github.com/zoometh/Rdev/blob/master/functions/factor_analysis.R) | [ca_depots.png](https://github.com/zoometh/Rdev/blob/master/out/ca_depots.png) |
| LDA           | [data_factor_analysis.csv](https://github.com/zoometh/Rdev/blob/master/data/data_factor_analysis.csv) | [discriminant_analysis.R](https://github.com/zoometh/Rdev/blob/master/functions/discriminant_analysis.R) | [lda_depots.png](https://github.com/zoometh/Rdev/blob/master/out/lda_depots.png) |
| CAH           | [data_factor_analysis.csv](https://github.com/zoometh/Rdev/blob/master/data/data_factor_analysis.csv) | [cluster_analysis.R](https://github.com/zoometh/Rdev/blob/master/functions/cluster_analysis.R) | [cah_depots.png](https://github.com/zoometh/Rdev/blob/master/out/cah_depots.png) |


