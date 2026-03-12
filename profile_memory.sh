#!/usr/bin/env bash
# Memory profile for single run of zoomerjoin/R
# Also generates plots
set -euo pipefail

echo "=== Begin fozziejoin memory profile ==="

# Run fozzie in background
Rscript ./fozzie_jaccard.R &
FOZZIE_PID=$!

# Monitor memory usage once per second
pidstat -r -p "$FOZZIE_PID" 1 > results/fozzie_memory.txt &
PIDSTAT_FOZZIE_PID=$!

# Wait for fozzie to finish, then stop pidstat
wait "$FOZZIE_PID"
kill "$PIDSTAT_FOZZIE_PID"


echo "=== Begin zoomerjoin memory profile ==="

# perf record only the zoomer run
perf record -F 199 -g --call-graph dwarf -o results/perf_zoomer.data -k mono -- \
bash -c '
    Rscript ./zoomer_jaccard.R &
    ZOOMER_PID=$!

    pidstat -r -p "$ZOOMER_PID" 1 > results/zoomer_memory.txt &
    PIDSTAT_ZOOMER_PID=$!

    wait "$ZOOMER_PID"
    kill "$PIDSTAT_ZOOMER_PID"
'

echo "=== Make memory plot ==="
Rscript plot_memory.R
