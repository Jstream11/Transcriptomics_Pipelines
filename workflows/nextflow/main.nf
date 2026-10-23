
include { samplesheetToList } from 'plugin/nf-schema'

include { FASTQC as FASTQC_raw } from './modules/fastqc.nf'
include { FASTQC as FASTQC_trimmed } from './modules/fastqc.nf'
include { MULTIQC as MULTIQC_raw } from './modules/multiqc.nf'
include { MULTIQC as MULTIQC_trimmed } from './modules/multiqc.nf'
include { MULTIQC as MULTIQC_all } from './modules/multiqc.nf'
include { FASTP } from './modules/fastp.nf'
include { GET_REF_GENOME } from './modules/get_ref_genome.nf'
include { STAR_INDEX } from './modules/star_index.nf'
include { STAR } from './modules/star.nf'

workflow {
    main:
    ch_samples = Channel.fromList(
        samplesheetToList(params.samplesheet, "assets/schema_input.json")
    ) | map { meta, fq1, fq2 ->
        tuple(meta + [single_end: !fq2], fq2 ? [fq1, fq2] : [fq1])
      }
    ch_samples.view()
    FASTQC_raw = FASTQC_raw(ch_samples)
    fastqc_raw_zips = FASTQC_raw.zip
        .map { meta, zip_files -> zip_files }
    MULTIQC_raw(fastqc_raw_zips)

    fastp = FASTP(ch_samples)
    trimmed_reads_for_fastqc=fastp.fastqs
    fastp_json_reports = fastp.json
        .map { meta, json_file -> json_file }

    fastqc_trimmed = FASTQC_trimmed(trimmed_reads_for_fastqc)
    fastqc_trimmed_zips = fastqc_trimmed.zip
        .map { meta, zip_files -> zip_files }
        .flatten()
    
    multiqc_inputs = fastqc_trimmed_zips
        .mix(fastp_json_reports)
        .collect()
    MULTIQC_trimmed(multiqc_inputs)

    ref = GET_REF_GENOME(
        params.reference_genome_fa,
        params.reference_genes_gtf
    )
    index = STAR_INDEX(ref.fasta, ref.gtf)

    star = STAR(
        index.index, trimmed_reads_for_fastqc
    )
    star_logs = star.log
        .map { meta, log_file -> log_file}

    multiqc_inputs_all = multiqc_inputs
        .mix(star_logs)
        .collect()
    multiqc_inputs_all.view()
    multiqc_all = MULTIQC_all(multiqc_inputs_all)

    publish:
    multiqc_raw_report = MULTIQC_raw.out.html
    trimmed_fastqs = trimmed_reads_for_fastqc
    multiqc_trimmed_report = MULTIQC_trimmed.out.html
    star_bams = star.bam
    multiqc_all_report = MULTIQC_all.out.html

}

output {
        multiqc_raw_report {
            path 'multiqc/raw'
            mode 'copy'
        }
        trimmed_fastqs {
            path 'fastp'
            mode 'copy'
        }
        multiqc_trimmed_report {
            path 'multiqc/trimmed'
            mode 'copy'
        }
        star_bams {
            path 'star'
            mode 'copy'
        }
        multiqc_all_report {
            path 'multiqc/all'
            mode 'copy'
        }
    }