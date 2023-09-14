#!/bin/bash
mkdir -p /work_queue
mkdir -p /work_queue/logs /work_queue/workers
chmod 777 -R /work_queue;
chown -R www-data:www-data /work_queue


mkdir -p /scratch 
mkdir -p /scratch/coge
mkdir -p /scratch/coge/cache /scratch/coge/tmp
mkdir -p /scratch/coge/tmp/downloads /scratch/coge/tmp/results /scratch/coge/tmp/staging /scratch/coge/tmp/uploads
mkdir -p /scratch/coge/tmp/downloads/jobs
mkdir -p /scratch/coge/cache/bed /scratch/coge/cache/blast /scratch/coge/cache/experiments /scratch/coge/cache/fasta /scratch/coge/cache/genomes /scratch/coge/cache/last /scratch/coge/cache/sra 
mkdir -p /scratch/coge/cache/blast/db
chmod 777 -R /scratch;
chown -R www-data:www-data /scratch

mkdir -p /storage
mkdir -p /storage/coge /storage/work_queue
mkdir -p /storage/coge/data
mkdir -p /storage/coge/data/blast /storage/coge/data/genomic_sequence /storage/coge/data/popgen /storage/coge/data/syn3d
mkdir -p /storage/coge/data/blast/matrix
chmod 777 -R /storage;
chown -R coge:coge /storage
