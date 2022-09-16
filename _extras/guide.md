---
layout: page
title: "Instructor Notes"
---

## Instructor notes

### Episode 1-3

- The three episodes are basic introductions for raster, vector, and CRS. Keep in mind the audience may already be very experienced in these topics. Please consider not going into too many details if not necessary.

### Episode 5

- The exercise **Exercise: Search satellite scenes using metadata filters** needs extra attention. Its output `search.json` is required for the later episodes. Therefore we recommend:
  - Do not skip this exercise;
  - Think twice when you would like to change the query arguments in this exercise;
  - Make sure all the audience have the output `search.json` before continuing.

### Episode 7

- Loading the crop fields polygons `data/brpgewaspercelen_definitief_2020.gpkg` is not recommended, because it takes quite some time (about several minutes), and may crush the Jupyter terminal.
- The cut version of fields: `data/cropped_field.shp` is required for later episodes.

### Episode 8

- It is not recommended to plot the `visual` band directly, due to its size (3 x 10980 x 10980). Please plot the `overview` as in the teaching material.
- The clipped raster data: `raster_clip.tif` is required for later episodes.

### Episode 9

- The calculated NDVI: `data/NDVI.tif` is required for later episodes.
- The calculated classification identifier: `data/NDVI_classified.tif` is required for later episodes.

## Workshop setup

- Consider using `mamba` for speeding up the Python environment setup. 
- Make sure the audience has downloaded the three vector datasets to the `data` repository.

{% include links.md %}
