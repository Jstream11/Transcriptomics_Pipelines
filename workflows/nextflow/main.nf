
include { validateSamplesheet } from './modules/validateSamplesheet.nf'
include { FASTQC } from './modules/fastqc.nf'

workflow {
    main:
    samplesheet = channel.fromPath(params.samplesheet)
    samplesheet_validated = validateSamplesheet(samplesheet)
    samples= samplesheet_validated
        .splitCsv(header: true)
        .map { row ->
            tuple(row.sample, file(row.fastq_1), file(row.fastq_2))
        }
    FASTQC(samples)

    publish:
    fastqc_html = FASTQC.out.html
    fastqc_zip = FASTQC.out.zip

}

output {
        fastqc_html {
            path 'fastqc'
            mode 'copy'
        }
        fastqc_zip {
            path 'fastqc'
            mode 'copy'
        }
    }