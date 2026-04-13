---
title: Setup
---

## Data Sets

1. Create a new directory on your Desktop called `geospatial-python`.
2. Within `geospatial-python`, create a directory called `data`.
3. Download the data required for this lesson via [this link](https://figshare.com/ndownloader/articles/25721754/versions/3) (678MB).
4. Unzip the downloaded file and save its content into the just created `data` directory.

Now you should have the following files in the `data` directory:

- `sentinel-2` - This is a directory containing multiple bands of Sentinel-2 raster images collected over the island of Rhodes on Aug 27, 2023. 
- `dem/rhodes_dem.tif` - This is the Digital Elevation Model (DEM) of the island of Rhodes, retrieved from the [Copernicus Digital Elevation Model (GLO-30)](https://spacedata.copernicus.eu/collections/copernicus-digital-elevation-model). The original tiles have been cropped and mosaicked for this lesson.
- `gadm/ADM_ADM_3.gpkg` - This is the administration boundaries of Rhodes, downloaded from [GADM](https://gadm.org/) and modified for this lesson.
- `osm/osm_landuse.gpkg` and `osm/osm_roads.gpkg` - They are land-use poylgons and roads polylines of Rhodes, downloaded from [Openstreetmaps](www.openstreetmaps.org) via [Geofabrik](https://www.geofabrik.de/data/download.html) and modified for this lesson.

## Software Setup

[Python](https://python.org) is a popular language for scientific computing, and great for
general-purpose programming as well. There are many ways to install Python and the
required dependencies. In this workshop, we suggest to use [`uv`](https://docs.astral.sh/uv/) 
for its fast and easy installation process. 

:::::::::::::::::::::::::::::::::::::::discussion

### Software Setup using uv

Please follow the instructions below according to your operating system.

Regardless of how you choose to install it, please make sure you install Python
version 3.x (e.g., 3.12 is fine). Also, please set up your python environment at
least a day in advance of the workshop. If you encounter problems with the
installation procedure, ask your workshop organizers via e-mail for assistance so
you are ready to go as soon as the workshop begins.

:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: solution

### Linux / MacOS

Open a terminal and install `uv` following the [official installation instructions](https://docs.astral.sh/uv/getting-started/installation/):

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then make sure you are inside the `geospatial-python` directory you created during the data setup step by doing:

```sh
cd ~/Desktop/geospatial-python
```

Finally, run the following command to create a virtual environment and install the required dependencies:

```sh
uv venv --python=3.12 && uv pip install -r https://raw.githubusercontent.com/carpentries-incubator/geospatial-python/main/files/requirements.txt
```

:::::::::::::::::::::::::


:::::::::::::::: solution

### Windows

On Windows, first we install `uv` using PowerShell following the [official installation instructions](https://docs.astral.sh/uv/getting-started/installation/):

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

After the installation, you may see suggestions on the PowerShell terminal like `$env:Path = "C:\Users\username\.local\bin;$env:Path"` This means you need to manually add the `uv` executable to your system's PATH variable. Please run the suggested command in your PowerShell terminal to add `uv` to your PATH. Otherwise PowerShell will not recognize the `uv` command in the next step.

Then make sure you are inside the `geospatial-python` directory you created during the data setup step by doing:

```powershell
cd \Users\<Username>\Desktop\geospatial-python
```

And replace the `<Username>` patter (including the angle brackets `<>`) with your Windows username.
Finally, run the following command to create a virtual environment and install the required dependencies:

```powershell
uv venv --python=3.12; if ($LASTEXITCODE -eq 0) { uv pip install -r https://raw.githubusercontent.com/carpentries-incubator/geospatial-python/main/files/requirements.txt}
```

:::::::::::::::::::::::::

After the installation, a `.venv` directory will be created in the current directory, which contains the virtual environment with all the required dependencies.

### Testing the installation

In order to follow the lesson, you should launch JupyterLab. Let's try it now to make sure everything is set up correctly. You should run the following command in your terminal from the `geospatial-python` directory:

```
uv run jupyter lab
```

Once you have launched JupyterLab, create a new Python 3 notebook, type the following code snippet in a cell and press the "Play" button:

```python
import rioxarray
```

If all the steps above completed successfully you are ready to follow along with the lesson!

::: callout

### Alternative: software setup using Anaconda

If you prefer to use Anaconda, you can follow the alternative setup instructions on [this
page](./setup_alternative.md).

:::