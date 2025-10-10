# About

RandomiSur is a free, open-source platform to design online surveys and collect questionnaire data. Some key features make RandomiSur an efficient tool to design and administrate your surveys in a "powerful" way.

- RandomiSur uses [jsPsych](https://www.jspsych.org/7.0/) to generate online tests and surveys, providing flexibility to customize your own surveys.
- RandomiSur has a built-in shiny app, `inject-order`, to arrange item sequence with many randomization algorithms, some of within have been validated in lab experiment environments to boost statistical power by up to 45%.
- RandomiSur can collect participants' reaction time for each item.
- Most RandomiSur components can be managed by R language, which makes application modification feasible for advanced users.

RandomiSur is an early-stage project and would be under continual maintainence. For users who want to programme jsPsych experiments completely in R, I recommand trying two R packages: [`{jaysire}`](https://jaysire.djnavarro.net/index.html) and [`{jspsychr}`](https://www.crumplab.com/jspsychr/index.html). However, neither `{jaysire}` nor `{jspsychr}` integrateed online database configuration. Therefore, they might be more appropriate in lab environments. Future development of RandomiSur might consider including these two packages to create a fully R-based workflow that also sets up a ready-to-go solution for configuring network connation.

# Dependencies

RandomiSur is containerized with [Docker](https://www.docker.com/). This would be the only dependency for basic users if general deployment is the goal. For advanced user who want to customize this platform, the following dependencies should be installed additionally:

- Node.js
- Apache
- PHP
- MariaDB (version 10.4 or greater)
- R version 4.1 or greater, with packages:
 - `{tidyverse}`
 - `{DBI}`
 - `{RMariaDB}`
 - `{jsonlite}`
 - `{shiny}`

# Quick start

## Installation

You can download the development version of RandomiSur using this command. After this, change the working directory to RandomiSur.

``` shell
git clone https://github.com/Jinghui-Liang/RandomiSur.git

cd path/to/RandomiSur
```

Testing how RandomiSur deploys a questionnaire locally would be useful. Therefore, we starting with the local administration of RandomiSur.

## Testing RandomiSur with default settings

### Prepare the questionnaire

There are two ways to prepare a questionnarie file. First, use the provied function `test_template()` to obtain a blank file, then insert questions.

Second, prepare a questionnaire like below, and save it as csv file:

| question                          | choices                     | required | label  | demographic |
|-----------------------------------|-----------------------------|----------|--------|-------------|
| What is your age?                 |                             | n        | age    | y           |
| What is your gender?              | male/female                 | n        | gender | y           |
| I am the life of the party.       | Inaccurate/Neutral/Accurate | y        | E      |             |
| I feel little concern for others. |                             | n        | A      |             |
| I am always prepared.             |                             |          | C      |             |

The following column names are required and keep them consistent as below:

- Column `question`, each row only contains one question;
- For column `choices`, separate choices with slashes or leave it blank;
  - For demographic items, blank cell in this column will allow the item to accept textural input;
  - For scale items, blank cell in this column means corresponding items have the same choices as the first item with specified choices in this column.
- For column `required`, letter `n` means an item can be skipped, while letter `y` or a blank cell make an item unskippable.
- For column `label`, type the variable names for demographic items, and factor labels for scale items (i.e., which subscale an item belongs to).
- Column `demographic` tells if an item is a demographic item or scale item. Only recognizing `y` as symbol of demographic items.

The full template can be also accessed by the following R code.

``` r 
  dat <- readr::read_csv("./scalepool/fullscale.csv")
  
  head(dat, 10)
```

Once finished, save the questionnaire in `scalepool` directory.

### Randomize items with `inject-order`

Launch the shiny app `inject-order` by

``` shell
Rscript -e "shiny::runApp('inject-order')"
```

Users will then be taken to the interface of `inject-order`. If not, type the url from the shell prompt.  Then, users should upload the csv file that is stored on `surveypool` directory. Successful submission will generate a preview on "data" panel. Then users should head to "order" panel to start organizing presentation orders and target sample sizes under each methods. Currently, this platform provides eleven methods to arrange presentation order with details of available [here](file:inject-order/description.md).

Once the arrangement is finished, users can go to "plan" to inspect selected methods and corresponding sample sizes. For "fixed" collections (e.g., fx, gff, cff), all participants will receive the same presentation order. But for the rest of the methods, participants will receive sequences that are independently randomized. Users should click the download button on the top to download the compressed archive, `df-order.zip` to get the plan files. Decompressing is not needed because scripts later on will do so automatically.

NB: If you already have an order list and plan (like the two csv files inside the downloaded `df-order.zip`), compress them and replace the downloaded one. No need to use `inject-order` to do further adjustment.

### Initialize Docker container and database

Next, we should start initialize the container (a virtural development environment that ensures functions working normally). 

``` shell
  docker-compose up -d --build
```

Building this container will take couple minutes for the first time, depending on connection quality. When containers `survey_php` and `survey_db` are built, users can see prompts displayed on the terminal. Then, access the environment and initialize 

Next, take over the "virtual system" inside the container and configure the online database by using

``` shell
  docker exec -it -w /var survey_php sh

```

``` shell
  ./ConfigDB
  
  Are you running local test or uploading your platform to a server? (local/server) local
  The name of target questionnaire you would like to use, extension required: fullscale.csv
```

Now `ConfigDB` will automatically configure the database and the survey. When you see "Initialization done", open a web browser and access `127.0.0.1:8080`, you would join the survey as a participant. At this point you would not know which presentation order you received. You should see a welcome page, demographic items, and a "start again" page displaying first, then scale item follows. The "start again" page is not a duplicate one -- we actually start measuring participant's reaction time at this point and use it as our "baseline", because the only thing participants will do is reading and clicking -- no choosing process are needed for them. Once the survey is finished, you will see the ending page with a "submit" button. Their responses and all other data will not be saved to database unless they click that button.

### Data

To download and inspect datasets, users can execute `download_rawdat.R` by the following command line.

``` shell
  Rscript R/download-rawdat.R
  
  Are you running local test or uploading your platform to a server? (local/server)
  Do you want to download (f)ull data or just (r)esposne data? (f/r)
  Which database you would like to down data from?
```

Use `local`, `f`, `fullscale` as three answers to the prompts, this command downloads demographic dataset, response dataset, and participant-order pairs dataset (recording which participant received which order). If only response dataset is of interest, use `r` as the argument instead of `f`. Alternatively, users can directly access `R/download_rawdat.R` and change the network connection and download the data using `dplyr::tbl()` and `dplyr::collect()` functions.

### Finishing the test

When you finish testing the survey, conduct `exit` or press `Ctrl + d` to disconnect from the docker. Then on Terminal, execute

``` shell
docker-compose down
```

To terminate containers we just created. This returns some storages of the machine.

### Launch a survey

If everything goes fine so far, we have finished the testing section. Now users might want to submit the test to a hosted server (i.e., making this test online). To do so they can change the (hidden) `.env` file on the root directory of RandomiSur. The default configuration of `.env` is:

```
HTTP_PORT=8080
SQL_PORT=3307
USR_NAME=root
SERVER_DB_NAME=test
DB_PASS=example
MARIADB_VER=10.4
COMPOSE_PROJECT=platform
```

Edit and save `.env` in order to match connection environment, including online database name, username, port, and password (contact administrators). Then, enter the container and execute `ConfigDB` again. This time, use `server` as the argument for the first prompt, i.e.

``` shell
  docker exec -it -w /var survey_php sh

  ./ConfigDB
  
  Are you running local test or uploading your platform to a server? (local/server) server
  The name of target questionnaire you would like to use, extension required: fullscale.csv
```

To download datasets from server, follows the same steps in last section, but make sure `.env` is properly configured to connect to the database in host server.
