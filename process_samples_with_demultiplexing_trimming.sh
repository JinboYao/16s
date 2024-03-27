#!/bin/bash

# Input files
R1_INPUT="CG14_S36_R1_001.fastq.gz"
R2_INPUT="CG14_S36_R2_001.fastq.gz"
BARCODES="barcodes.fasta"
PRIMER_FILE="CG14-primer.tsv"

# Output directories
DEMUX_OUTPUT_DIR="demultiplexing_output"
TRIMMING_OUTPUT_DIR="trimming_output"

# Create output directories if they do not exist
mkdir -p "$DEMUX_OUTPUT_DIR"
mkdir -p "$TRIMMING_OUTPUT_DIR"

# Demultiplexing: place the results in the specified folder
cutadapt -g file:$BARCODES --pair-filter=any -o "$DEMUX_OUTPUT_DIR/{name}.R1.fastq.gz" -p "$DEMUX_OUTPUT_DIR/{name}.R2.fastq.gz" $R1_INPUT $R2_INPUT

# Read the TSV file and perform Trimming
while IFS=$'\t' read -r sample_id barcode primerF primerR
do
    if [ "$sample_id" != "样品编号" ]; then  # Skip the header row
        echo "Processing $sample_id..."
        
        # Define input file names (from the Demultiplexing_output folder)
        R1="$DEMUX_OUTPUT_DIR/${sample_id}.R1.fastq.gz"
        R2="$DEMUX_OUTPUT_DIR/${sample_id}.R2.fastq.gz"
        
        # Define output file names (to be placed in the Trimming_output folder)
        trimmed_R1="$TRIMMING_OUTPUT_DIR/trimmed.${sample_id}.R1.fastq.gz"
        trimmed_R2="$TRIMMING_OUTPUT_DIR/trimmed.${sample_id}.R2.fastq.gz"
        
        # Execute cutadapt command for Trimming
        cutadapt -g "$primerF" -G "$primerR" -o "$trimmed_R1" -p "$trimmed_R2" "$R1" "$R2"
    fi
done < "$PRIMER_FILE"

echo "All processes have been completed."
