
include { samplesheetToList } from 'plugin/nf-schema'

include { FASTQC as FASTQC_raw } from './modules/fastqc.nf'
include { FASTQC as FASTQC_trimmed } from './modules/fastqc.nf'
include { MULTIQC as MULTIQC_raw} from './modules/multiqc.nf'
include { MULTIQC as MULTIQC_trimmed} from './modules/multiqc.nf'
include { FASTP } from './modules/fastp.nf'

workflow {
    main:
    ch_samples = Channel.fromList(
        samplesheetToList(params.samplesheet, "assets/schema_input.json")
    ) | map { meta, fq1, fq2 ->
        tuple(meta + [single_end: !fq2], fq2 ? [fq1, fq2] : [fq1])
      }
    ch_samples.view()
    FASTQC_raw(ch_samples)
    fastqc_raw_zips = FASTQC_raw.out.zip
        .map { meta, zip_files -> zip_files }
    fastqc_raw_zips.view()
    MULTIQC_raw(fastqc_raw_zips)
    trimmed_fastqs = FASTP(ch_samples)
    trimmed_fastqs.view()
    trimmed_reads_for_fastqc = trimmed_fastqs.trimmed
    .map { meta, fastq_files, fastp_report ->
        tuple(meta, fastq_files)
    }
    fastqc_trimmed = FASTQC_trimmed(trimmed_reads_for_fastqc)
    fastqc_trimmed_zips = FASTQC_trimmed.out.zip
        .map { meta, zip_files -> zip_files }
    fastqc_trimmed_zips.view()
    MULTIQC_trimmed(fastqc_trimmed_zips)

    publish:
    multiqc_raw_report = MULTIQC_raw.out.html
    trimmed_fastqs = trimmed_fastqs.trimmed
    multiqc_trimmed_report = MULTIQC_trimmed.out.html

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
    }