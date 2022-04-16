# GMM
> Geometry Morphometry with the Momocs package

<p align="center">
  <img alt="img-name" src="../www/5_kmeans.jpg" width="300">
  <br>
    <em>Kmeans on 225 sickles, with 6 centers (ie, clusters)</em>
</p>

---

## Extract lithics from photographs

<p align="center">
  <img alt="img-name" src="../www/IMG_0901.JPG" width="300">
</p>
<p align="center">
:arrow_down:
</p>
<p align="center">
  <img alt="img-name" src="../www/IMG_0901_shape.JPG" width="300">
</p>

Use [ImageMagick](https://imagemagick.org/) processes, in a Python loop, to extract flints from standardized photographs:

1. Read a XLSX file to recover folder names and photographs filenames
2. Compute several ImageMagick operations (thresholds, connected-components, etc.)
3. Write a black and white image of the lithic with the same filename of the original photo + suffix '`_shape`'

The black and white image is ready to be used for GMM processes

---


## Sickles

R Script for the shape analysis and classification of sickles blades

