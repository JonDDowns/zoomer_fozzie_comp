dir.create("./results", showWarnings = FALSE)
dir.create("./data", showWarnings = FALSE)

# Define the logging function
log_message <- function(message) {
  log_file <- "log.txt"
  timestamp <- Sys.time()
  formatted_time <- format(timestamp, "%Y-%m-%d %H:%M:%S")
  log_entry <- paste(formatted_time, "-", message)

  # Write to log file and console
  cat(log_entry, file = log_file, append = TRUE, sep = "\n")
  cat(log_entry, "\n")
}

load_dime <- function() {
    # Retrieve from https://data.stanford.edu/dime
    orig_fn <- './data/dime_contributors_1979_2024.rdata'
    if (!file.exists(orig_fn)) {
        log_message(sprintf("WARNING: %s not found", orig_fn))
        stop("Must download dime data from https://data.stanford.edu/dime")
    }

    # Create or load the subset data for faster loads
    fast_fn <- './data/dime_contributors.Rds'
    if(!file.exists(fast_fn)) {
        log_message("No fast file...creating")
        load(orig_fn)
        keep_cols <- c('bonica.cid', 'most.recent.contributor.name')
        out <- na.omit(contribs[, keep_cols])

        set.seed(42)
        samp_idx <- sample(nrow(contribs), 1e6)
        dimedat <- out[samp_idx, ]

        saveRDS(dimedat, fast_fn, compress=FALSE)
    } else {
        log_message("Loading fast file")
        dimedat <- readRDS(fast_fn)
        names(dimedat) <- c("id_1", "name")
    }

    return(dimedat)
}

# Check if the file exists
archive_file <- function(filename) {
    if (file.exists(filename)) {
        # Create "archive" subfolder if it doesn't exist
        archive_folder <- file.path(dirname(filename), "archive")
        dir.create(archive_folder, showWarnings = FALSE)

        # Get the file creation time
        creation_time <- file.info(filename)$ctime
        timestamp <- format(creation_time, "%Y%m%d_%H%M%S")

        # Construct the new file name
        file_name <- basename(filename)
        file_sans_ext <- tools::file_path_sans_ext(file_name)
        ext <- tools::file_ext(file_name)
        new_file_name <- paste0(file_sans_ext, "_", timestamp, ".", ext)
        new_file_path <- file.path(archive_folder, new_file_name)

        # Move the file to the archive folder
        file.rename(filename, new_file_path)
        log_message(sprintf("File moved to %s:", new_file_path))
    } else {
        log_message(sprintf("No file to archive at %s", filename))
    }
}

load_config <- function() {
    require(yaml)
    config <- read_yaml('config.yaml')
    config$PLOT_NAME <- sprintf('results/benchmark_plot_nband_%s.png', config$N_BANDS)
    config$BENCH_CSV_FN <- sprintf("results/jaccard_benches_nband_%s.csv", config$N_BANDS)
    return(config)
}

