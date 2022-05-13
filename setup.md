---
layout: page
title: Setup
---

## Setting up your Lesson Directory and Getting the Data

  1. Open the terminal/shell:
     * On **Windows**, open **Git Bash**. 
     * On **Mac OS** or **Linux**, open the **Terminal** app.

  2. Change your working directory to your **Desktop** :

      ```bash
      cd ~/Desktop
      ```

  3. Create a new directory on your Desktop called `geospatial-python` and change into it:

      ```bash
      mkdir geospatial-python
      cd geospatial-python
      ```

  4. Create a subdirectory within `geospatial-python` called `data` and change into it:

      ```bash
      mkdir data
      cd data
      ```

  5. Download the data that will be used in this lesson. There are two ways you can do this:

     * **Web browser:** [**Click here**](https://figshare.com/ndownloader/files/33848834) to download the zip file. When it finishes, move the zip file into the `geospatial-python` directory we created above and unzip the file.
     * **Terminal:**

      ```bash
      curl -L --output NEON-GEO-PYTHON-DATASETS.zip https://figshare.com/ndownloader/files/33848834
      ```

     The file should begin to download. When it is complete, unzip it by entering the following command:

      ```bash
      unzip NEON-GEO-PYTHON-DATASETS.zip
      ```

     You should now have a directory named `data` within `geospatial-python`. Use the `ls` command to confirm.

  6. Change directories from `data` back into `geospatial-python`:

      ```bash
      cd ..
      ```

## Installing Python Using Anaconda

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

3. Double-click the executable and install Python 3 using the recommended settings. Make sure that **Register Anaconda
   as my default Python 3.x** option is checked - it should be in the latest version of Anaconda

### Mac OS X - [Video tutorial][video-mac]

1. Visit [https://www.anaconda.com/distribution/][anaconda-mac] with your web browser.

2. Download the Python 3 installer for OS X. These instructions assume that you use the graphical installer `.pkg` file.

3. Follow the Python 3 installation instructions. Make sure that the install location is set to "Install only for me" so
   Anaconda will install its files locally, relative to your home directory. Installing the software for all users tends
   to create problems in the long run and should be avoided.


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

## Setting up the workshop environment with conda

Once you have installed Anaconda, you should have access to the `conda` command in your terminal. 

1. Test that this is so by running the `conda` command in the terminal. You should get an output that looks like this:

    ```bash
    → conda                    
    usage: conda [-h] [-V] command ...

    conda is a tool for managing and deploying applications, environments and packages.

    Options:

    positional arguments:
      command
        clean        Remove unused packages and caches.
        compare      Compare packages between conda environments.
        config       Modify configuration values in .condarc. This is modeled
                    after the git config command. Writes to the user .condarc
                    file (/home/rave/.condarc) by default.
        create       Create a new conda environment from a list of specified
                    packages.
        help         Displays a list of available conda commands and their help
                    strings.
        info         Display information about current conda install.
        init         Initialize conda for shell interaction. [Experimental]
        install      Installs a list of packages into a specified conda
                    environment.
        list         List linked packages in a conda environment.
        package      Low-level conda package utility. (EXPERIMENTAL)
        remove       Remove a list of packages from a specified conda environment.
        uninstall    Alias for conda remove.
        run          Run an executable in a conda environment. [Experimental]
        search       Search for packages and display associated information. The
                    input is a MatchSpec, a query language for conda packages.
                    See examples below.
        update       Updates conda packages to the latest compatible version.
        upgrade      Alias for conda update.

    optional arguments:
      -h, --help     Show this help message and exit.
      -V, --version  Show the conda version number and exit.

    conda commands available from other packages:
      env
    ```

2. Create the environment using the `conda create` command. It's possible to paste the following
code on the Terminal:
   
    ```bash
    conda create -n geospatial -c conda-forge -y \
      jupyterlab numpy matplotlib \
      xarray rasterio geopandas rioxarray earthpy descartes xarray-spatial pystac-client==0.3.2

    ```
   
   _Please note that this step may take several minutes to complete. If it takes more than a few minutes, see below for another method._

   In this command, the `-n` argument specifies the environment name, the `-c` argument specifies the Conda channel
   where the libraries are hosted, and the `-y` argument spares the need for confirmation. The following arguments are
   the names of the libraries we are going to use. As you can see, geospatial analysis requires many libraries!
   Luckily, package managers like `conda` facilitate the process of installing and managing them.
    
   If the above command does not work, it's also possible to create the environment from a file:
    
   Right-click and "Save Link As..." on this link:
   
   [https://carpentries-incubator.github.io/geospatial-python/files/environment.yaml](files/environment.yaml)
   
   Name it `environment.yaml` and save it to your `geospatial-python` folder.
   The `environment.yaml` contains the names of Python libraries that are required to run the lesson:

    ```
    name: geospatial
    channels:
      - conda-forge
    dependencies:
    # JupyterLab
      - jupyterlab
    # Python scientific libraries
      - numpy
      - matplotlib
      - xarray
    # Geospatial libraries
      - rasterio
      - geopandas
      - rioxarray
      - xarray-spatial
      - earthpy
      - descartes # necessary for geopandas plotting
      - pystac-client==0.3.2 # pin version to work with earth-search STAC API
    ```
   
    In the terminal, navigate to the directory where you saved the `environment.yaml` file using the `cd` command.
    Then run:

    ```bash
    conda env create -f environment.yaml
    ```

    `conda` should begin to locate, download, and install the Python libraries listed in the `environment.yaml` file.
   
    > ## Faster Environment Install With One Extra Step
    > If you see a spinning `/` for more than a few minutes, you may want to try the following to speed up the environment installation. 
    > 1. Cancel the currently running `conda create` process with CTRL+C
    > 2. Run `conda install -c conda-forge mamba`
    > 3. Run `mamba env create -f environment.yaml`
    {: .callout}

    When installation has finished you should see the following message in the terminal:

    ```bash
    # To activate this environment, use
    #    $ conda activate geospatial
    #
    # To deactivate an active environment, use
    #    $ conda deactivate
    ```

    > ## IMPORTANT
    > If your terminal responds to the above command with `conda: command not found` see the > <<troubleshooting>> section.
    {: .callout}

3. Activate the `geospatial` virtual environment:
    ```bash
    conda activate geospatial
    ```

    If successful, the text `(base)` in your terminal prompt will now read `(geospatial)` indicating that you are now in
    the Anaconda virtual environment named `geospatial`. The command `which python` should confirm that we're using the
    Python installation in the `geospatial` virtual environment. For example:

    ```bash
    % which python
    > /Users/your-username/anaconda3/envs/geospatial/bin/python
                                          ^^^^^^^^^^
    ```

    > ## IMPORTANT
    > If you close the terminal, you will need to 
    reactivate this environment with `conda activate geospatial` to use the Python libraries required for the lesson and
   > to start JupyterLab, which is also installed in the `geospatial` environment.
    {: .callout}


## Starting JupyterLab

In order to follow the lessons on using Python (episode 5 and onward), you should launch JupyterLab 
after activating the geospatial conda environment in your working directory that contains the data you downloaded. 
See [Starting JupyterLab][starting-jupyterlab] for guidance.

If all of the steps above completed successfully you are ready to follow along with the lesson!

## Troubleshooting `conda: command not found`

* **Windows users:** use the _Start Menu_ to
  [**open the _Anaconda Prompt_**](https://docs.anaconda.com/anaconda/install/verify-install/#conda) and
  [continue from the beginning of step 3](#env-create-anchor) in the section *Setting up the workshop environment with conda*.
* **Mac OS and Linux users:**

1. First, find out where Anaconda is installed.

    The typical install location is in your `$HOME` directory (i.e., `/Users/your-username/`) so use `ls ~` to check
   whether an `anaconda3` directory is present in your home directory:

    ```bash
    % ls ~
    > Applications      Downloads       Pictures
      anaconda3         Library         Public
      Desktop           Movies      
      Documents         Music
    ```

    If, like above, you see a directory called `anaconda3` in the output we're in good shape. If not, **contact the instructor for help**.

2. Activate the `conda` command-line program by entering the following command:

    ```bash
    source ~/anaconda3/bin/activate
    ```
    If all goes well, nothing will print to the terminal and your prompt will now have `(base)` floating around somewhere
    on the left. This is an indication that you are in the base Anaconda environment.

    [Continue from the beginning of step 3](#env-create-anchor) to complete the creation of the `geospatial` virtual environment.

[anaconda]: https://www.anaconda.com/
[anaconda-mac]: https://www.anaconda.com/download/#macos
[anaconda-linux]: https://www.anaconda.com/download/#linux
[anaconda-windows]: https://www.anaconda.com/download/#windows
[gapminder]: https://en.wikipedia.org/wiki/Gapminder_Foundation
[jupyter]: http://jupyter.org/
[starting-jupyterlab]: https://swcarpentry.github.io/python-novice-gapminder/01-run-quit/#starting-jupyterlab
[python]: https://python.org
[video-mac]: https://www.youtube.com/watch?v=TcSAln46u9U
[video-windows]: https://www.youtube.com/watch?v=xxQ0mzZ8UvA

{% include links.md %}
