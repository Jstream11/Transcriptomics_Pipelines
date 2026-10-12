import gzip
from pathlib import Path
import pandas as pd
import logging
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--samplesheet", required=True)
parser.add_argument("--output", required=True)
args = parser.parse_args()

samplesheet_path = Path(args.samplesheet)
samplesheet_validated_path = Path(args.output)

LOG = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


required_columns = ['sample', 'fastq_1', 'fastq_2', 'strandedness']
allowed_strandedness = ['auto', 'unstranded', 'forward', 'reverse']

def read_fastq(path):
    if path.endswith('.gz'):
        with gzip.open(path, 'rt') as fastq:
            header = fastq.readline().strip()
            LOG.info(f"Reading gzipped FASTQ file: {path}")
    else:
        with open(path, 'r') as fastq:
            header = fastq.readline().strip()
            LOG.info(f"Reading FASTQ file: {path}")
    if not header.startswith('@'):
        raise ValueError(f"Error: The file {path} does not appear to be a valid FASTQ file.")
    read_id = header[1:].split()[0]
    return read_id.removesuffix("/1").removesuffix("/2")

try:
    Path(samplesheet_path).exists
except FileNotFoundError:
    raise ValueError("Error: The file does not exist.")

samplesheet = pd.read_csv(samplesheet_path)

found_columns = samplesheet.columns.tolist()
if found_columns != required_columns:
    raise ValueError(f"Error: The samplesheet is missing required columns. Found columns: {found_columns}. Required columns: {required_columns}.")
if not samplesheet['strandedness'].isin(allowed_strandedness).all():
    raise ValueError(f"Error: The samplesheet contains invalid values for 'strandedness'. Allowed values: {allowed_strandedness}.")

for _, row in samplesheet.iterrows():
    read1 = row["fastq_1"]
    read2 = row["fastq_2"]
    sample = row["sample"]

    if not Path(read1).is_file():
        raise FileNotFoundError(f"FASTQ not found: {read1}")

    if pd.notna(read2) and read2:
        if not Path(read2).is_file():
            raise FileNotFoundError(f"FASTQ not found: {read2}")

        if read_fastq(read1) != read_fastq(read2):
            raise ValueError(f"First read IDs do not match for sample {sample}")

LOG.info("Samplesheet validation completed successfully.")
samplesheet.to_csv(samplesheet_validated_path, index=False)