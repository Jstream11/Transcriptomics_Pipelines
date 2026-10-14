
include { samplesheetToList } from 'plugin/nf-schema'

include { FASTQC } from './modules/fastqc.nf'
include { MULTIQC } from './modules/multiqc.nf'

workflow {
    main:
    ch_samples = Channel.fromList(
        samplesheetToList(params.sample_sheet, "assets/schema_input.json")
    ) | map { meta, fq1, fq2 ->
        tuple(meta + [single_end: !fq2], fq2 ? [fq1, fq2] : [fq1])
      }
    ch_samples.view()
    # handles single and paired ends
    ch_fastqc = FASTQC(ch_samples)
    MULTIQC(ch_fastqc)

    publish:
    multiqc_report = MULTIQC.out.html

}

output {
        multiqc_report {
            path 'multiqc'
            mode 'copy'
        }
    }