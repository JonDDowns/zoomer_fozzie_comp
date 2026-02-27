library(zoomerjoin)
library(fozziejoin)
library(dplyr)
library(microbenchmark)
library(ggplot2)

# Retrieve from https://data.stanford.edu/dime
orig_fn <- './dime_contributors_1979_2024.rdata'
fast_fn <- './dime_contributors.Rds'

# Load times are long
# Let's do most of the preprocessing and save it in an uncompressed file
if(!file.exists(fast_fn)) {
    print("No fast file...creating")
    load(orig_fn)
    keep_cols <- c('bonica.cid', 'most.recent.contributor.name')
    out <- na.omit(contribs[, keep_cols])

    set.seed(42)
    samp_idx <- sample(nrow(contribs), 1e6)
    dimedat <- out[samp_idx, ]

    saveRDS(dimedat, fast_fn, compress=FALSE)
} else {
    print("Loading fast file")
    dimedat <- readRDS(fast_fn)
}

names(dimedat) <- c("id_1", "name")

join_random <- function(data, idxs) {
    npairs <- length(idxs) / 2
    left <- data[idxs[1:npairs], ]
    right <- data[idxs[(npairs + 1):(npairs * 2)], ]
    colnames(right) <- paste0(colnames(right), '.y')
    return(dplyr::bind_cols(left, right))
}

# At 1.1e5 records, fozziejoin returned ~2.36 mln matches
nrow_fozzie <- 1586803
idxs_fozzie <- sample(nrow(dimedat), nrow_fozzie * 2, replace=TRUE)
print(microbenchmark(join_random(dimedat, idxs_fozzie), times=3, unit='s'))

# At same level, zoomerjoin returned ~0.14 mln matches
nrow_zoomer <- 108571
idxs_zoomer <- sample(nrow(dimedat), nrow_zoomer * 2, replace=TRUE)
print(microbenchmark(join_random(dimedat, idxs_zoomer), times=3, unit='s'))

