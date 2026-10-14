process FASTQC {
    conda "${projectDir}/../../envs/fastqc.yaml"
    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path('*_fastqc.html'), emit: html
    tuple val(meta), path('*_fastqc.zip'), emit: zip

    script:
    """
       fastqc -o . $fastq
    """
}
