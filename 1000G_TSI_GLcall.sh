#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J bcftools
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

vcftools=/path/to/vcftools   #vcftools version 0.1.16
bcftools=/path/to/bcftools   #bcftools version 1.9 
reffa=/path/to/hs37d5.fa     #reference fasta file
out=tsi_200K                 #name of vcf file with 200K SNPs of TSI from 1000 Genomes Project phase3
name=xxxx                    #name of vcf file with GL calls
bamlist=/path/to/bam.list    #list of simulated bam files
DIRlcm=/path/to/lcmlkin  

#Prepare tsv file for GL calling
$vcftools --gzvcf /path/to/1000genome.phase3.v5a.ALL.beagle.vcf.gz --keep tsi_ID.txt --positions /path/to/tsi_200K.pos --remove-indels --min-alleles 2 --max-alleles 2 --recode-INFO-all --recode --stdout | bgzip -c > ${out}.vcf.gz 
$bcftools index -f ${out}.vcf.gz --threads 3 
$bcftools query -f'%CHROM\t%POS\t%REF,%ALT\n' ${out}.vcf.gz | bgzip -c > ${out}.tsv.gz 
tabix -s1 -b2 -e2 ${out}.tsv.gz

#GL calling
$bcftools mpileup -f ${reffa} -B -q10 -Q13 -I -a 'FORMAT/DP' -T $DIRlcm/${out}.vcf.gz -b ${bamlist} -Ou | \
$bcftools call -Am -C alleles -f GP,GQ -T $DIRlcm/${out}.tsv.gz -Oz -o $DIRlcm/av/${name}.vcf.gz

#Prepare pair-based vcf files and remove missing sites
for target in $(cat /path/to/targets.list)
do 
$bcftools view -S /path/to/$target $DIRlcm/av/${name}.vcf.gz -Oz -o /path/to/${target}.vcf.gz
$bcftools view -e 'GT[*]="./."' /path/to/${target}.vcf.gz -Oz -o /path/to/${target}.2.vcf.gz
rm -f /path/to/${target}.vcf.gz
	echo ${target} done
done