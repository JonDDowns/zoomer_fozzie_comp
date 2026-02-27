# Zoomerjoin and Fuzzyjoin: Performance Tradeoffs

A repo with code examples for some comparative benchmarking between `zoomerjoin`
and `fozziejoin`. Goal is to identify use cases for each.

## Getting Started

### Clone repo

```sh
git clone https://github.com/JonDDowns/zoomer_fozzie_comp
cd ./zoomer_cozzie_comp
```

### Install fozziejoin

Open an R session to install `remotes`, then `fozziejoin`

```
install.packages('remotes')
remotes::install_github('fozzieverse/fozziejoin/fozziejoin-r')
```

### Use `renv` to install other packages

```r
library(renv)
renv::restore()
```

### Download Dime contributors .Rdata file

https://data.stanford.edu/dime

Place in root folder of project.

### Run it!

The main benchmarking occurs here:

```sh
Rscript compare_large.R
```

And a demonstration of creating joined dataframes of arbitrary size is
here:

```sh
Rscript joinrandom.R
```
