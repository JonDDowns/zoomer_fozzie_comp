# Zoomerjoin and Fuzzyjoin: Performance Tradeoffs

A repo with code examples for some comparative benchmarking between `zoomerjoin`
and `fozziejoin`. Goal is to identify use cases for each.

## Getting Started

Requires a functioning Rust toolchain and R version 4.5.

### Clone repo

```sh
git clone https://github.com/JonDDowns/zoomer_fozzie_comp
cd ./zoomer_fozzie_comp
```

### Use `renv` to install other packages

```r
# install.packages('renv')
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
