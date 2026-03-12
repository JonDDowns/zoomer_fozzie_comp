#!/usr/bin/env bash
# Run all memory profiling and benchmarks

set -euo pipefail
bash ./profile_memory.sh
bash ./bench_and_plot.sh
