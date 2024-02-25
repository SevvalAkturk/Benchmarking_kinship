#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J depth
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

bed=/path/to/tsi_200K_snp.bed     #bed file containing 200K SNPs of TSI from 1000 Genomes Project phase 3
DIRbam=/path/to/bam.list          #bam list directory
DIR=/path/to/output               #output directory
samtools=/path/to/samtools        #samtools version 1.9

#Prepare unique read depth file for each simulated pair and extra one simulated individual
for keep in $(cat /path/to/targets.list)
do
$samtools depth -f $DIRbam/${keep}_dep -b $bed -q 30 -Q 30 > $DIR/${keep}_q30_samtools.log
done 