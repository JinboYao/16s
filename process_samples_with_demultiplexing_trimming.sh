#!/bin/bash

# Input files
R1_INPUT="/gpfssan1/home/biogroup/20240401/data/CG14_S36_R1_001.fastq.gz"
R2_INPUT="/gpfssan1/home/biogroup/20240401/data/CG14_S36_R2_001.fastq.gz"
BARCODES="/gpfssan1/home/biogroup/20240401/data/barcodes.fasta"
PRIMER_FILE="/gpfssan1/home/biogroup/20240401/data/CG14-primer.tsv"

# Output directories
DEMUX_OUTPUT_DIR="/gpfssan1/home/biogroup/20240401/demultiplexing_output"
TRIMMING_OUTPUT_DIR="/gpfssan1/home/biogroup/20240401/trimming_output"

# Create output directories if they do not exist
mkdir -p "$DEMUX_OUTPUT_DIR"
mkdir -p "$TRIMMING_OUTPUT_DIR"

# Demultiplexing: place the results in the specified folder
cutadapt -g file:$BARCODES --pair-filter=any -o "$DEMUX_OUTPUT_DIR/{name}.R1.fastq.gz" -p "$DEMUX_OUTPUT_DIR/{name}.R2.fastq.gz" $R1_INPUT $R2_INPUT

# Read the TSV file and perform Trimming
tail -n +2 "$PRIMER_FILE" | while IFS=$'\t' read -r sample_id barcode forward_primer reverse_primer
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
        echo "$primerF and $primerR"
        cutadapt -a "$primerF" -A "$primerR" -o "$trimmed_R1" -p "$trimmed_R2" "$R1" "$R2"
        #cutadapt -a CAGCCGCCGCGGTAA -A GTGCTCCCCCGCCAATTCCT -o ./trimming_output/trimmed_R1.fastq.gz -p ./trimming_output/trimmed_R2.fastq.gz /home/root1/jinbo/16s/cutadaptProject/demultiplexing_output/C1.R1.fastq.gz /home/root1/jinbo/16s/cutadaptProject/demultiplexing_output/C1.R2.fastq.gz
    fi
done < "$PRIMER_FILE"

echo "All processes have been completed."
