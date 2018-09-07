#!/bin/bash -ue
bowtie2 -q -1 ERR036019samp_1.fastq.gz-2 ERR036019samp_2.fastq.gz -x /home/sdv/m2bi/ileroy/Documents/nextflow/nextflow-intro/data/db/FN433596 -S ERR036019samp.sam -p 3
