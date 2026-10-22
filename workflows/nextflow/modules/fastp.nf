process FASTP {
    conda "${projectDir}/../../envs/fastp.yaml"
    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta),
        path('*_fastp_*_trimmed.fastq.gz', arity: '1..2'),
        path('*_fastp_report.html'), 
        emit: trimmed

    script:
    if (meta.single_end) {
        """
       fastp \
            -i $fastq[0] \
            -o ${meta.id}_fastp_1_trimmed.fastq.gz \
            -h ${meta.id}_fastp_report.html   
    """
    } else {
        """
       fastp \
            -i ${fastq[0]} \
            -I ${fastq[1]} \
            -o ${meta.id}_fastp_1_trimmed.fastq.gz \
            -O ${meta.id}_fastp_2_trimmed.fastq.gz \
            -h ${meta.id}_fastp_report.html   
    """
    }
}