process validateSamplesheet {
    conda "${projectDir}/../../envs/python.yaml"
    input:
    path samplesheet

    output:
    path 'samplesheet.validated.csv'

    script:
    """
        python "${projectDir}/scripts/validate_samplesheet.py" \
        --samplesheet "${samplesheet}" \
        --output samplesheet.validated.csv \
        --base-dir "${launchDir}"
    """
}