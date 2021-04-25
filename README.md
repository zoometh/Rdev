# Rdev
> Test Files for R, Python and JavaScript

## 3D model management and viewers with open softwares

Photogrammetric model of engraved rocks from the Mont Bego rock-art site (Alpes-Maritimes, France)

**Objectives**: 

* Python programming 

* Use the [3DHOP framework](https://3dhop.net/)

The [3DHOP repo](https://github.com/cnr-isti-vclab/3DHOP) has been forked. A .nxz file is created from .obj files with the Nexus functions [nxsbuild](https://github.com/cnr-isti-vclab/nexus/blob/master/doc/nxsbuild.md#nxsbuild) and [nxscompress](https://github.com/cnr-isti-vclab/nexus/blob/master/doc/nxscompress.md#nxscompress)

### 3DHOP

3D models stored on GitHub:

* [*Looped Skin Rock*](https://zoometh.github.io/3DHOP/minimal/ZXVIIGIIR59@c.html)

* [*Roche de l'archer*](https://zoometh.github.io/3DHOP/minimal/ZXVIIIGIR28@a.html)

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
  
