#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J filter
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

bed=/path/to/tsi_200K_snp.bed      #bed file containing 200K SNPs of TSI from 1000 Genomes Project phase 3
DIRout=/path/to/output             #output directory


#Prepare unique bed file including only shared SNPs between simulated pairs 
for keep in $(cat /path/to/keep_depth.list)
do
keepbase=$(basename $keep _samtools.log)
awk '$4!= "0" && $5!="0"' $keep | awk '{print $1,$2-1,$2}' | tr ' ' '\t' > $DIRout/${keepbase}_filter0.pos
grep -w -f $DIRout/${keepbase}_filter0.pos $bed > $DIRout/${keepbase}_filter0.bed
done