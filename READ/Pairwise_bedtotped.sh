#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J bed2tped
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

file=xxxx               #plink bed file name
plink=/path/to/plink    #plink version 1.9
DIRout=/path/to/output  #output directory 

#Make a list of pairwise simualated pair names
cd $DIRout
ls keep_r* > keep.list

#Prepare pairwise tped files and remove the missing sites
for keep in $(cat $DIRout/keep.list)
do
grep -w -f ${keep} ${file}.fam > ${keep}.fam
$plink --bfile ${file} --keep ${keep}.fam --make-bed --out ${keep}
$plink --bfile ${keep} --geno 0 --recode transpose --out ${keep}
rm -f ${keep}.fam
rm -f ${keep}
rm -f ${keep}.bim
rm -f ${keep}.bed
rm -f ${keep}.nosex
done
