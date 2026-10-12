process FASTQC {
    conda "${projectDir}/../../envs/python.yaml"
    input:
    tuple val(sample), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample), path('*_fastqc.html'), emit: html
    tuple val(sample), path('*_fastqc.zip'), emit: zip

    script:
    """
        fastqc -o . $fastq_1 $fastq_2
    """
}
