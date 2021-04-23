# Rdev
> Test Files for R and Python

## 'Roche de l'archer' 3D photogrammetry model

A photogrammetric model of the engraved rock [*Roche de l’archer * (ZXVIII.GI.R28@a)](https://www.openstreetmap.org/#map=15/44.0874812216558/7.45581273137977), from the Mont Bego rock-art site (Alpes-Maritimes, France). Files and Python code are stored temporarily on a GitHub repository to estimate Python programming facilities considering 3D models management

* `roche_archer_2` + `.obj` + `.mlt` + `.jpg` : files coming from the rock-art low-resolution photogrammetric model (Wavefront Stanford object). [See it on Sketchlab](https://sketchfab.com/3d-models/roche-archer-2-a5c0771d898d4816950570cd7fb1be37).

* [`roche_archer_2` + `.pyw`](https://github.com/zoometh/Rdev/blob/master/roche_archer_2.pyw) : a Python 3 code script inspired by [this GitHub document](https://github.com/pywavefront/PyWavefront/blob/master/examples/globe_simple.py). This script allows to: 

  + read the photogrammetric model
  
  + create a rotation view in a RGL window
  
  
<p align="center">
  <img alt="img-name" src="www/snapshot_roche_archer_2.png" width="500">
  <br>
    <em>snapshot from the RGL window generated from the Python script</em>
</p>
  
