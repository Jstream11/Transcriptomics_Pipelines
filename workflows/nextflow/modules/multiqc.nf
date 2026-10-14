process MULTIQC {
    conda "${projectDir}/../../envs/mutliqc.yaml"
    input:
    tuple val(meta), path(qc)

    output:
    tuple val(meta), path('multiqc_report.html'), emit: html

    script:
    """
       multiqc --force --outdir . --filename $qc
    """
}