process STAR_INDEX {
    conda "${projectDir}/../../envs/star.yaml"
    input:
    path genome_fa 
    path genes_gtf

    output:
    path("SAindex"), emit:index

    script:
    """
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir SAindex --genomeFastaFiles "${genome_fa}" --sjdbGTFfile "${genes_gtf}" --sjdbOverhang 100
    """
}