process STAR {
    conda "${projectDir}/../../envs/star.yaml"
    input:
    path index 
    tuple val(meta), path(fastqs, arity: '1..2')
    
    output:
    tuple val(meta), path("Aligned.sortedByCoord.out.bam"), emit:bam
    tuple val(meta), path("Log.final.out"), emit:log

    script:
    if (meta.single_end) {
        """
        STAR --runThreadN 4 \
            --genomeDir "${index}" \
            --readFilesIn "${fastqs[0]}" \
            --readFilesCommand zcat \
            --outSAMtype BAM SortedByCoordinate
        """
    } else {
        """
        STAR --runThreadN 4 \
            --genomeDir "${index}" \
            --readFilesIn "${fastqs[0]}" "${fastqs[1]}" \
            --readFilesCommand zcat \
            --outSAMtype BAM SortedByCoordinate
        """
    }
}