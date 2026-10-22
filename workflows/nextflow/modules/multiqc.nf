process MULTIQC {
    conda "${projectDir}/../../envs/multiqc.yaml"
    input:
    path(qc)

    output:
    path('multiqc_report.html'), emit: html

    script:
    """
       multiqc --force --outdir . --filename multiqc_report.html $qc
    """
}