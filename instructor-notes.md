---
title: Instructor Notes
---

## Instructor notes

### Episode 1

- The exercise **Exercise: Search satellite scenes using metadata filters** needs extra attention. Its output `search.json` is required for the later episodes. Therefore we recommend:
  - Do not skip this exercise;
  - Think twice when you would like to change the query arguments in this exercise;
  - Make sure all the audience have the output `search.json` before continuing.

### Episode 3

-  `brpgewaspercelen_definitief_2020_small.gpkg` was created because the original file was too large to download and load. Original file, which was ~500Mb could take several minutes to load, and could crash the Jupyter terminal.
- The cropped version of `brpgewaspercelen_definitief_2020_small.gpkg`: `data/fields_cropped.shp` is required for later episodes.
- The "Modify the geometry of a GeoDataFrame" section is optional and can be skipped without consequences.

### Episode 4

- It is not recommended to plot the `visual` band directly, due to its size (3 x 10980 x 10980). Please plot the `overview` as in the teaching material.
- The clipped raster data: `raster_clip.tif` is required for later episodes.

### Episode 5

- The calculated NDVI: `NDVI.tif` is required for later episodes.
- The calculated classification identifier: `NDVI_classified.tif` is required for later episodes.

## Workshop setup

- Consider using `mamba` for speeding up the Python environment setup. 
- Make sure the audience has downloaded the three vector datasets to the `data` repository.

