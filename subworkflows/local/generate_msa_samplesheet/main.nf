include { FILTER_FASTA as FILTER_FASTA_FOR_MSA } from '../../../modules/local/filter_fasta/main'

workflow GENERATE_MSA_SAMPLESHEET {
    take:
    ch_fasta
    ch_filtered_ids
    outdir

    main:
    FILTER_FASTA_FOR_MSA(
        ch_fasta
            .join(ch_filtered_ids)
            .map { meta, fasta, filtered_ids -> [meta, fasta, filtered_ids] }
    )

    def outdir_abs = file(outdir).toAbsolutePath().toString()

    def ch_samplesheet = FILTER_FASTA_FOR_MSA.out.fasta
        .map { meta, _fasta -> "${meta.id},${outdir_abs}/samplesheets/${meta.id}/${meta.id}_filtered.fa" }
        .collect()
        .map { rows -> (["id,fasta"] + rows.sort()).join('\n') }
        .collectFile(
            storeDir: "${outdir}/samplesheets",
            name: 'multiplesequencealign_samplesheet.csv',
            newLine: true
        )

    emit:
    filtered_fasta  = FILTER_FASTA_FOR_MSA.out.fasta
    msa_samplesheet = ch_samplesheet
}
