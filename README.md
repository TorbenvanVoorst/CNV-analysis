# CNV-analysis

A quick matlab file to make plots of CNVs detected by the FGA Quality Control pipeline

This script works on excel tables and CSVs.

Your table or CSV needs to contain the following columns (with headers that contain these exact names):
Coordinates, Length, CN, Sample, Confidence

To use the script, collect the QC data from your samples and/or controls you want to compare, and put them in a single table or CSV. The script will ask you to open this file for analysis when you run it.
In the first few lines, there are some values you can change to suit your needs (e.g. minimal confidence score, minimal length, whether to save the output plots as pictures or not).

CNV areas will be plotted as lines. Above each line, the copy number value will be plotted.
If the CNV is smaller then the minimal length, it will be plotted as a dashed line.
If the confidence score is below you threshold, the line will be opaque.
Too short and too low confidence regions will be dashed and opaque.
The number above each line denotes the type of CNV (duplication = 3, deletion = 1)

If multiple CNV area's are present in one chromosome they may become quite small. For now, best to just use the matlab plots to zoom in manually, but this isn't possible on the exported plots.
