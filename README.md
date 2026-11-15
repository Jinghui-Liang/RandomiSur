# About

RandomiSur is a free, open-source platform to design online surveys and collect questionnaire data. This is a prototype of a psychometrics research tool to answer a broader research question: What presentation order of psychometric measurement instruments makes better accessment? RandomiSur is an early-stage project and would be under continual maintainence.

Some key features make RandomiSur an efficient tool to design and administrate your surveys in a "powerful" way.

- RandomiSur uses [jsPsych](https://www.jspsych.org/7.0/) to generate online tests and surveys, providing flexibility to customize your own surveys.
- RandomiSur has a built-in shiny app, `inject-order`, to arrange item sequence with many randomization algorithms, some of within have been validated in lab experiment environments to boost statistical power by up to 45%.
- RandomiSur can collect participants' reaction time for each item, getting ready for dynamic multivariate modelling.
- Most RandomiSur components can be managed by R language, which makes application modification feasible for advanced users.

# Dependencies

## Host requirements

- [Docker Desktop](https://docs.docker.com/compose/install/) with Docker Compose. On Linux, Docker Engine with the Compose plugin also works.
- Git, if you plan to clone the repository.
- A web browser for the survey and the `inject-order` Shiny app.

The first build needs internet access to pull Docker images and download packages from Debian repositories, CRAN, and GitHub.

## Container dependencies

Docker Compose builds the application image from [`server.Dockerfile`](server.Dockerfile) and starts MariaDB as a separate service. The database image tag is set by `MARIADB_VER` in `.env`.

The application image includes:

- PHP 8.2 with Apache and the `mysqli`, `pdo`, and `pdo_mysql` extensions.
- R and Node.js.
- R packages from CRAN: `remotes`, `tidyverse`, `DBI`, `jsonlite`,
  `RMariaDB`, `markdown`, `shiny`, `bslib`, and `zip`.
- The R package `explan`, installed from [dalejbarr/explan](https://github.com/dalejbarr/explan).

See [`server.Dockerfile`](server.Dockerfile) for the full list of system libraries. These dependencies are installed in the image during the build.

# Quick start

## 1. Installation

You can install RandomiSur by cloning this repo 

``` shell
git clone https://github.com/Jinghui-Liang/RandomiSur.git
```

or you can download the zip file.

## 2. Prepare the questionnaire

Prepare a questionnaire like below, and save it as csv file:

| question                          | choices                     | required | label  | demographic |
|-----------------------------------|-----------------------------|----------|--------|-------------|
| What is your age?                 |                             | n        | age    | y           |
| What is your gender?              | male/female                 | n        | gender | y           |
| I am the life of the party.       | Inaccurate/Neutral/Accurate | y        | E      |             |
| I feel little concern for others. |                             | n        | A      |             |
| I am always prepared.             |                             |          | C      |             |
| ...                               | ...                         | ...      | ...    | ...         |


The following column names are required and keep them consistent as below:

- Column `question`, each row only contains one question;
- For column `choices`, separate choices with slashes or leave it blank;
  - For demographic items, blank cell in this column will allow the item to accept textural input;
  - For questionnaire items, blank cells in this column mean corresponding items have the same choices as the first item with specified choices in this column.
- For column `required`, letter `n` means an item can be skipped, while letter `y` or a blank cell make an item unskippable.
- For column `label`, type the variable names for demographic items, and factor labels for scale items (i.e., which subscale an item belongs to).
- Column `demographic` tells if an item is a demographic item or scale item. Only recognizing `y` as symbol of demographic items.

This example questionnaire could be found at `scalepool` directory. When you generated your own questionnaire, save it to the `scalepool` directory too.

## 3. Initialize the container

Change your working directory to the root directory of RandomiSur and build up the image using terminal.

``` shell
cd /path/to/RandomiSur

docker-compose up -d --build
```

This process could take a while, depending on the internet connection quality. Once it is finished, access the terminal of the `survey_php` image by:

``` shell
docker exec -it -w /var survey_php sh
```

The rest of the configuration will be completed within the container.

## 4. Randomize items using `inject-order`

Launch the shiny app `inject-order` by

``` shell
Rscript -e "shiny::runApp('inject-order')"
```

You should be able to access the shiny app by visiting `localhost:4836`. Upload your questionnaire csv file is stored on `scalepool` directory. Successful submission will generate a preview on "data" panel. Head to the "order" panel to start organizing presentation orders and target sample sizes under each methods. Currently, this platform provides eleven methods to arrange presentation order with details of available the [help page](inject-order/description.md) panel. By choosing one (or a combination) of the algorithms on the sidebar, you would see how item numebrs (values of each row on this table) are placed onto the presentation order (column names of the table, `p` stands for "position").

Once the arrangement is finished, users can go to "plan" to inspect selected methods and corresponding sample sizes. For "fixed" collections (e.g., fx, gff, cff), all participants will receive the same presentation order. But for the rest of the methods, participants will receive sequences that are independently randomized. Users should click the download button on the top to download the compressed archive, `df-order.zip` to get the plan files. You should move this zip file to `scalepool` as well. Decompressing is not needed because scripts later on will do so automatically. Click the "Finish and Exit" button to terminate the shiny app.

## 5. Initialize the database and tables

On terminal, execute the `ConfigDB` by 
``` shell
  ./ConfigDB
```
  
You would see this question on terminal:

``` text
  Are you running local test or uploading your platform to a server? (local/server)
```

As we are doing local test here, we type `local` as the answer and hit return. Then you would see the second question:

``` text
  Are you running local test or uploading your platform to a server? (local/server) local
  The name of target questionnaire you would like to use, extension required: 
```

Type the name of the questionnaire you stored in `scalepool`. In this example, it is `fullScale.csv`.

``` text
  Are you running local test or uploading your platform to a server? (local/server) local
  The name of target questionnaire you would like to use, extension required: fullScale.csv
```

Now `ConfigDB` will automatically configure the database and the survey. 

## 6. Inspect the generated online survey

When you see "Initialization done", access `127.0.0.1:8080` or `localhost:8080` using a web browser and you will see the client of the survey (i.e., joining as a participant). At this point you would not know which presentation order you received. You should see a welcome page, demographic items, and a "start again" page displaying first, then scale item follows. At the end of this survey, you will see the ending page with a "submit" button. Click it will submit your response to the database and terminate the survey, and you could exit this webpage. Notice that responses and all other data will ***NOT*** be saved to database unless they click "submit".

## 7. Download data

To download and inspect the data, users can execute `download_rawdat.R` by the following command line.

``` shell
  Rscript R/download-rawdat.R
```

Again, three questions help you to efficiently download the data you need.

``` text
  Are you running local test or uploading your platform to a server? (local/server)
```

we type `local`, then hit return

``` text
  Are you running local test or uploading your platform to a server? (local/server) local
  Which database you would like to down data from?
```

The database name is your questionnaire name but without the extension. So we put `fullScale` and hit return

``` text
  Are you running local test or uploading your platform to a server? (local/server)
  Which database you would like to down data from? fullScale
  Do you want to download (f)ull data or just the (r)esposne data? (f/r)
```

If only the response dataset is of interest, use `r` as the answer. Alternatively, using `f` to additionally downloads the randomized presentation order table, demographic table, and participant-order combination list.

## 8. Exit RandomiSur

Type `exit` or press `Ctrl + d` on terminal to disconnect from the container. Then on the local terminal, execute

``` shell
docker-compose down
```

To shut down the container. If everything goes fine so far, we have finished the testing section.

# Launch a survey (host required)

**Notice: For data protection, this operation should be conducted ONLY ON MONITORED MACHINES!**

To launch a survey, a host is required. You can find the environment file `.env` on the root of RandomiSur. Prepare a back up and contact administrators to change its configurations to suit your host except `{SHINY_PORT}`. Then go through procedures 1-4 to complete randomisation. On procedure 5, replace `local` with `server` as your answer:

``` text
./ConfigDB
Are you running local test or uploading your platform to a server? (local/server) server
```

With everything else remain the same. When downloading the data, also replace `local` with `server` so that RandomiSur retrieve it from the server, not your local machine. Make sure `.env` is properly configured to connect to the database in host server.
