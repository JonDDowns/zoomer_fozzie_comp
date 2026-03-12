library(zoomerjoin)

# Load helper functions and common parameters
source("helpers.R")
config <- load_config()
n <- max(config$SAMPLE_SIZES)
band_width <- max(config$BANDWIDTHS)

# Load dime data
dimedat <- load_dime()

data <- jaccard_inner_join(dimedat[1:n, ], dimedat[1:n, ],
    by = "name",
    band_width = band_width,
    n_bands = config$N_BANDS,
    threshold = 1 - config$DIST_THRESH,
    n_gram_width = config$QGRAM_WIDTH,
    nthread = config$NUM_THREADS
)
log_message(sprintf("Fozzie run complete with %s rows returned\n", nrow(data)))
quit("no", 0)
