#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_ROOT/data/nf-core-test"
REVISION="cad884e7fbe5617dcd55bdd07d9ddf65b54febe4"
BASE_URL="https://raw.githubusercontent.com/nf-core/test-datasets/$REVISION/testdata/GSE110004"

mkdir -p "$DATA_DIR"

read_1="$DATA_DIR/SRR6357070_1.fastq.gz"
read_2="$DATA_DIR/SRR6357070_2.fastq.gz"
samplesheet="$DATA_DIR/samplesheet.csv"
read_1_tmp="$read_1.partial"
read_2_tmp="$read_2.partial"
samplesheet_tmp="$samplesheet.partial"
trap 'rm -f "$read_1_tmp" "$read_2_tmp" "$samplesheet_tmp"' EXIT

curl --fail --location --retry 3 --output "$read_1_tmp" \
    "$BASE_URL/SRR6357070_1.fastq.gz"
curl --fail --location --retry 3 --output "$read_2_tmp" \
    "$BASE_URL/SRR6357070_2.fastq.gz"

mv "$read_1_tmp" "$read_1"
mv "$read_2_tmp" "$read_2"

cat > "$samplesheet_tmp" <<'CSV'
sample,fastq_1,fastq_2,strandedness
SRR6357070,data/nf-core-test/SRR6357070_1.fastq.gz,data/nf-core-test/SRR6357070_2.fastq.gz,reverse
CSV
mv "$samplesheet_tmp" "$samplesheet"

printf 'Downloaded shared test dataset to %s\n' "$DATA_DIR"
