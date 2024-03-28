#!/bin/bash

# 输入文件
R1_INPUT="CG14_S36_R1_001.fastq.gz"
R2_INPUT="CG14_S36_R2_001.fastq.gz"

# 输出目录
OUTPUT_DIR="./trimmed_output"
mkdir -p "${OUTPUT_DIR}"

# TSV 文件路径
PRIMER_TSV="CG14-primer.tsv"

# 从第二行开始读取文件（跳过标题行）
tail -n +2 "${PRIMER_TSV}" | while IFS=$'\t' read -r sample_id barcode primer_f primer_r
do
    echo "Processing ${sample_id} with barcode ${barcode}"

    # 构建输出文件名
    R1_OUT="${OUTPUT_DIR}/${sample_id}_R1_trimmed.fastq.gz"
    R2_OUT="${OUTPUT_DIR}/${sample_id}_R2_trimmed.fastq.gz"

    # 运行 Cutadapt
    cutadapt \
        -g "^${barcode}" -G "^${barcode}" \  # 确保barcode位于reads的起始位置
        -a "${primer_f}" -A "${primer_r}" \  # 使用每个样本特定的引物序列
        -o "${R1_OUT}" -p "${R2_OUT}" \
        "${R1_INPUT}" "${R2_INPUT}"
done

echo "All samples processed."
