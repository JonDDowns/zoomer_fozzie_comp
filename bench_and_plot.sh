#!/usr/bin/env bash
# Runs the full benchmark scripts and generates an
# output plot

echo "=== Begin full benchmark ==="
Rscript run_bench.R
Rscript plot_bench.R

echo "=== All tasks complete ==="

