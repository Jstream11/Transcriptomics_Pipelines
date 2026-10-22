process GET_REF_GENOME {
    input:
        val genome_url
        val gtf_url
    output:
        path 'genome.fa', emit: fasta
        path 'genes.gtf', emit: gtf
    script:
        """
        wget -O genome.fa.gz "${genome_url}"
        gunzip genome.fa.gz
        wget -O genes.gtf.gz "${gtf_url}"
        gunzip genes.gtf.gz
        """
}