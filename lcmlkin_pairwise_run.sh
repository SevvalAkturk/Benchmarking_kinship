#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J lcMLkin
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

b=$1  #replicate number

bcftools=/path/to/bcftools               #bcftools version 1.16
DIRvcf=/path/to/output   
DIRlcmlkin=/path/to/output_lcmlkin       #output directory


#Prepare downsampled unique SNP list for each simulated pairs and run lcMLkin 
for N in 1000 5000 10000 20000 50000
do
mkdir -p $DIRlcmlkin/${b}/${N}
for target in $(cat /path/to/targets.list)
do
targetbase=$(basename $target .2.vcf.gz)
mkdir -p $DIRlcmlkin/${b}/${N}/${targetbase}
cat $DIRvcf/${targetbase}_snp.list | shuf -n ${N} | sort -V  > $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.txt
cd $DIRlcmlkin/${b}/${N}/${targetbase}
$bcftools view -R $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.txt $DIRvcf/$target | bgzip > $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.vcf.gz
tabix -s1 -b2 -e2 $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.vcf.gz
python3 /path/to/lcmlkinv2.py -v $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.vcf.gz -p /path/to/tsi_200K -t 4 -o $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_lcm.out
rm -f $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.txt
rm -f $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.vcf.gz
rm -f $DIRlcmlkin/${b}/${N}/${targetbase}/${targetbase}_${b}_${N}.vcf.gz.tbi
	echo ${targetbase} ${b} ${N} DONE

done
done