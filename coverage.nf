#!/usr/bin/env nextflow

params.reads = "$baseDir/data"
params.bowtie_index = "$baseDir/data/db/FN433596"
params.cpus = 3
params.results="$baseDir/results"

fasta = Channel.fromFilePairs("${params.reads}/*{1,2}.fastq.gz")



process mapping {
    input:
        set pair_id, file(reads) from fasta

    output :
        set pair_id, file("*.sam") into mappingChannel

    script:
        """
        bowtie2 -q -1 ${reads[0]}-2 ${reads[1]} -x ${params.bowtie_index} -S ${pair_id}.sam -p ${params.cpus}
        """
}


process samtool_view {
    input :
        set pair_id, file(map) from mappingChannel

    output :
        set pair_id, file("*.bam" ) into bamChannel

    script:
        """
        samtools view -S -@ ${params.cpus} -b -o ${pair_id}.bam ${map}
        """

}


process samtool_sort {
    input :
        set pair_id, file(sort) from bamChannel
    
    output :
        set pair_id, file("sorted_*.bam") into sortbamChannel

    script :
        """
        samtools sort -@ nb_cpus -o sorted_${pair_id}.bam ${sort}
        """

}

process bedtools {

    input :
        set pair_id, file(coverage) from sortbamChannel

    output :
        set pair_id, file("*.gcbout") into coverageChannel

    script :
        """
        bedtools genomecov -ibam ${coverage} -d > ${pair_id}.gcbout
        """

 }

process coverageStats {
    publishDir "${params.results}", mode: 'copy'
    input :
        set pair_id, file(covStat) from coverageChannel

    output :
        set pair_id, file("*.txt") into cov_result

    script :
        """
        bed2coverage ${covStat} > ${pair_id}.txt
        """

}



