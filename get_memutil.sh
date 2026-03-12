# Get memory utilization of a single fozziejoin run
echo Begin Fozzie
Rscript ./fozzie_jaccard.R &
FOZZIE_PID=$!
pidstat -r -p $FOZZIE_PID 1 > results/fozzie_memory.txt &
PIDSTAT_FOZZIE_PID=$!
wait $FOZZIE_PID
kill $PIDSTAT_FOZZIE_PID

# Zoomerjoin run
echo Begin Zoomer
Rscript ./zoomer_jaccard.R &
ZOOMER_PID=$!
pidstat -r -p $ZOOMER_PID 1 > results/zoomer_memory.txt &
PIDSTAT_ZOOMER_PID=$!  # Capture the PID of the pidstat process
wait $ZOOMER_PID        # Wait for zoomerjoin process to finish
kill $PIDSTAT_ZOOMER_PID  # Kill pidstat after zoomerjoin finishes

Rscript plot_memory.R
