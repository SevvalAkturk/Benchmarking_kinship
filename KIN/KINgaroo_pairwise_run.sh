#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J KINgaroo
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

b=$1                            #bootstrap number
N=$2                            #SNP number
bed=/path/to/tsi_200K_snp.bed   #bed file of 200K SNPs 
DIRout=/path/to/output          #output directory
DIRbam=/path/to/bam             #bam files directory
DIRtarget=/path/to/target       #target files directory



for target in $(cat /path/to/targets.list)
do
mkdir -p $DIRout/${b}/${N}/${target}/analysis
mkdir -p /path/to/splitbams/${target}

cd $DIRout/${b}/${N}/${target}

#Downsample SNPs ( N : SNP Number)
cat /path/to/${target}_q30_filter0.bed | shuf -n ${N} | sort -V > $DIRout/${target}_${b}_${N}.bed    

#Move splitbams folder to target directories (making KINgaroo run faster)
mv /path/to/splitbams/${target}/splitbams $DIRout/${b}/${N}/${target}/ 
 
#Run KINgaroo (ROH estimation and no contamination)
/path/to/KINgaroo -bam $DIRbam -bed $DIRout/${target}_${b}_${N}.bed -T $DIRtarget/$target -cnt 0 -c [node] -s 0
 
rm -f $DIRout/${target}_${b}_${N}.bed
rm -rf $DIRout/${b}/${N}/${target}/bedfiles/
mv $DIRout/${b}/${N}/${target}/splitbams /path/to/splitbams/${target}/
rm -rf $DIRout/${b}/${N}/${target}/hapProbs/
rm -f $DIRout/${b}/${N}/${target}/filtered_windows.txt
rm -f $DIRout/${b}/${N}/${target}/good*.csv
rm -f $DIRout/${b}/${N}/${target}/chrm_list.csv
	echo ${target} ${N} ${b} KINg DONE
done


#R script to calculate median p0 for simulated pairs 
#Rscript $DIRout/p0_median.R

