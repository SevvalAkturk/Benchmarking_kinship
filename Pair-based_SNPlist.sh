#!/bin/bash -l
#SBATCH -p partititon
#SBATCH -n node
#SBATCH -t time
#SBATCH -J lcMLkin
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

vcftools=/path/to/vcftools   #vcftools version 0.1.16
bcftools=/path/to/bcftools   #bcftools version 1.9
DIRvcf=/path/to/target       #output directory


#Prepare unique SNP list for each simulated pair 
for target in $(cat /path/to/targets.list)
do
targetbase=$(basename $target .2.vcf.gz)
tabix -s1 -b2 -e2 $DIRvcf/$target
$bcftools query -f '%CHROM\t%POS\n' $DIRvcf/$target > $DIRvcf/${targetbase}_snp.list
done