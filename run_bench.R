library(zoomerjoin)
library(fozziejoin)
library(dplyr)
library(purrr)
library(tidyr)
library(microbenchmark)
library(ggplot2)

source("helpers.R")
config <- load_config()

# Archive old bench run, if exists
archive_file(config$BENCH_CSV_FN)

# Load dime data
dimedat <- load_dime()

# Get time and memory use statistics for fozziejoin when performing jaccard join
fozzie_jaccard_bench <- function(n) {
    log_message(sprintf("Fozzie jaccard bench with n=%s", format(n, big.mark=",", scientific=FALSE)))
    time <- microbenchmark(
        data <- fozzie_string_join(
            dimedat[1:n, ],
            dimedat[1:n, ],
            method = "jaccard",
            max_dist = config$DIST_THRESH,
            q = config$QGRAM_WIDTH,
            by = 'name',
            nthread = config$NUM_THREADS
        ),
        times = config$NUM_RUNS
    )$time %>%
    mean()

    log_message(sprintf(
        "Median completion time: %s seconds with %s million rows",
        format(time / 1e9, digits=3),
        format(nrow(data) / 1e6, big.mark=",", scientific=FALSE, digits=2)
    ))

    out <- list('Time (seconds)' = time / 1e9, 'Returned Rows (millions)' = nrow(data) / 1e6)
    return(out)
}

log_message("Running fozzie")
fozzie_jaccard_benches <- purrr::map_df(config$SAMPLE_SIZES, fozzie_jaccard_bench, .id = "n")
fozzie_jaccard_benches$package <- "fozziejoin"

# Initialize an empty data frame to store results for zoomerjoin
zoomer_jaccard_benches <- NULL

# Loop over the defined bandwidths for zoomerjoin
for (bandwidth in config$BANDWIDTHS) {
    zoomer_bench <- function(n) {
        log_message(sprintf("Zoomer jaccard bench with n=%s, bandwidth=%s", format(n, big.mark=",", scientific=FALSE), bandwidth))
        time <- microbenchmark(
            data <- jaccard_inner_join(dimedat[1:n, ], dimedat[1:n, ],
                by = "name",
                band_width = bandwidth,
                n_bands = config$N_BANDS,
                threshold = 1 - config$DIST_THRESH,
                n_gram_width = config$QGRAM_WIDTH,
                nthread = config$NUM_THREADS
            ),
            times = config$NUM_RUNS
        )$time %>%
            mean()

      log_message(sprintf(
          "Median completion time: %s seconds with %s million rows",
          format(time / 1e9, digits=3),
          format(nrow(data) / 1e6, big.mark=",", scientific=FALSE, digits=2)
      ))

        out <- list('Time (seconds)' = time / 1e9, 'Returned Rows (millions)' = nrow(data) / 1e6)
        return(out)
    }

    zoomer_results <- purrr::map_df(config$SAMPLE_SIZES, zoomer_bench, .id = "n")
    zoomer_results$package <- sprintf("zoomerjoin (bandwidth=%s)", bandwidth)

    # Combine results
    zoomer_jaccard_benches <- bind_rows(zoomer_jaccard_benches, zoomer_results)
}

# Combine and pivot
cols <- c('n', 'Time (seconds)', 'Returned Rows (millions)', 'package')
jaccard_benches <- bind_rows(fozzie_jaccard_benches, zoomer_jaccard_benches)
colnames(jaccard_benches) <- cols
log_message(sprintf("Writing bench results to %s", config$BENCH_CSV_FN))
write.csv(jaccard_benches, config$BENCH_CSV_FN, row.names = FALSE)

quit("no", 0)
