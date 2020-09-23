---
layout: page
title: Setup
---

# Overview

This workshop is designed to be run on your local machine. First, you will need to download the data we use in the workshop. Then, you need to install python and the python libraries used in this lesson. We provide instructions below to install all dependencies with a single conda command after installing Python for Anaconda. If you have already installed Python 3 with Anaconda, you can skip Step 1. 

However, if you have installed Python without Anaconda, you will need to complete Step 1 (there is no need to uninstall the other python installations). We recommend Anaconda and the conda package manager, since they make installing geospatial python packages easier.

## Data

You can download all of the data used in this workshop by clicking
[this download link](https://ndownloader.figshare.com/files/21618735). The file is 155.38 MB.

Clicking the download link will automatically download all of the files to your default download directory as a single compressed
(`.zip`) file. To expand this file, double click the folder icon in your file navigator application (for Macs, this is the Finder application).

## Installation Step 1. Installing Python Using Anaconda

[Python][python] is a popular language for scientific computing, and great for
general-purpose programming as well. Installing all of its scientific packages
individually can be a bit difficult, however, so we recommend the all-in-one
installer [Anaconda][anaconda].

Regardless of how you choose to install it, please make sure you install Python
version 3.x (e.g., 3.7 is fine). Also, please set up your python environment at 
least a day in advance of the workshop.  If you encounter problems with the 
installation procedure, ask your workshop organizers via e-mail for assistance so
you are ready to go as soon as the workshop begins.

### Windows - [Video tutorial][video-windows]

1. Open [https://www.anaconda.com/distribution/][anaconda-windows] with your web browser.

2. Download the Python 3 installer for Windows.

3. Double-click the executable and install Python 3 using the recommended settings. Make sure that **Register Anaconda as my default Python 3.x** option is checked - it should be in the latest version of Anaconda

### Mac OS X - [Video tutorial][video-mac]

1. Visit [https://www.anaconda.com/distribution/][anaconda-mac] with your web browser.

2. Download the Python 3 installer for OS X. These instructions assume that you use the graphical installer `.pkg` file.

3. Follow the Python 3 installation instructions. Make sure that the install location is set to "Install only for me" so Anaconda will install its files locally, relative to your home directory. Installing the software for all users tends to create problems in the long run and should be avoided.


### Linux

Note that the following installation steps require you to work from the shell. 
If you run into any difficulties, please request help before the workshop begins.

1.  Open [https://www.anaconda.com/distribution/][anaconda-linux] with your web browser.

2.  Download the Python 3 installer for Linux.

3.  Install Python 3 using all of the defaults for installation.

    a.  Open a terminal window.

    b.  Navigate to the folder where you downloaded the installer

    c.  Type

    ~~~
    $ bash Anaconda3-
    ~~~
    {: .bash}

    and press tab.  The name of the file you just downloaded should appear.

    d.  Press enter.

    e.  Follow the text-only prompts.  When the license agreement appears (a colon
        will be present at the bottom of the screen) press the space bar until you see the 
        bottom of the text. Type `yes` and press enter to approve the license. Press 
        enter again to approve the default location for the files. Type `yes` and 
        press enter to prepend Anaconda to your `PATH` (this makes the Anaconda 
        distribution your user's default Python).

## Installation Step 2. Setting up the workshop environment with conda

Once you have installed Anaconda, you should have access to the `conda` command in your terminal. Right-click and Save As this [`environment.yml`](files/environment.yaml) file in your `geospatial-python` folder. It contains the following names of python libraries that are required to run the lesson:

```
name: geospatial
channels:
  - conda-forge
dependencies:
# Jupyter Lab
  - jupyterlab
# Python scientific libraries
  - numpy
  - scipy
  - scikit-image
  - matplotlib
  - xarray
# Geospatial libraries
  - rasterio
  - gdal
  - geopandas
  - rioxarray
  - geocube
  - earthpy
  - ipyleaflet
```

Save the file and exit your text editor. In the terminal, navigate to the directory where you saved the environment.yml file using the `cd` command.
Then run
`conda env create -f environment.yml`

This will install the minimal set of packages that you need to complete the workshop. This environment includes a separate python installation and set 
of packages that is completely independent from your Anaconda installation (we installed Anaconda to get the `conda` package manager).

When installation completes, run `conda activate geospatial` to activate your environment. Now, when you call `python` or `jupyter`, you will be using 
these programs from your geospatial environment rather than your default Anaconda python installation. If you close the terminal, you will need to 
reactivate this environment with `conda activate geospatial` to use the python libraries required for the lesson and to start a jupyter notebook that can access these libraries.

## Starting Jupyterlab

In order to follow the lessons on using Python (episode 5 and onward), you should launch JupyterLab 
after activating the geospatial conda environment in your working directory that contains the data you downloaded. 
See [Starting JupyterLab](https://swcarpentry.github.io/python-novice-gapminder/01-run-quit/#starting-jupyterlab) for guidance.

[anaconda]: https://www.anaconda.com/
[anaconda-mac]: https://www.anaconda.com/download/#macos
[anaconda-linux]: https://www.anaconda.com/download/#linux
[anaconda-windows]: https://www.anaconda.com/download/#windows
[gapminder]: https://en.wikipedia.org/wiki/Gapminder_Foundation
[jupyter]: http://jupyter.org/
[python]: https://python.org
[video-mac]: https://www.youtube.com/watch?v=TcSAln46u9U
[video-windows]: https://www.youtube.com/watch?v=xxQ0mzZ8UvA

{% include links.md %}
