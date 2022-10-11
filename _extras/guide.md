---
layout: page
title: "Instructor Notes"
---

## Instructor notes

### Episode 1-3

- The three episodes are basic introductions for raster, vector, and CRS. Keep in mind the audience may already be very experienced in these topics. Please consider starting the lesson with episodes 4 or 5 if the introductory episodes are not necessary.

### Episode 5

- The exercise **Exercise: Search satellite scenes using metadata filters** needs extra attention. Its output `search.json` is required for the later episodes. Therefore we recommend:
  - Do not skip this exercise;
  - Think twice when you would like to change the query arguments in this exercise;
  - Make sure all the audience have the output `search.json` before continuing.

### Episode 7

-  `brpgewaspercelen_definitief_2020_small.gpkg` was created because the original file was too large to download and load. Original file, which was ~500Mb could take several minutes to load, and could crash the Jupyter terminal.
- The cropped version of `brpgewaspercelen_definitief_2020_small.gpkg`: `cropped_field.shp` is required for later episodes.

### Episode 8

- It is not recommended to plot the `visual` band directly, due to its size (3 x 10980 x 10980). Please plot the `overview` as in the teaching material.
- The clipped raster data: `raster_clip.tif` is required for later episodes.

### Episode 9

- The calculated NDVI: `NDVI.tif` is required for later episodes.
- The calculated classification identifier: `NDVI_classified.tif` is required for later episodes.

## Workshop setup

- Consider using `mamba` for speeding up the Python environment setup. 
- Make sure the audience has downloaded the three vector datasets to the `data` repository.

{% include links.md %}
