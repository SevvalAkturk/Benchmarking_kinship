#!/bin/bash -l
#SBATCH -p partititon
#SBATCH -n node
#SBATCH -t time
#SBATCH -J READ
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

b=$1           #Bootstrap number
DIRout=$2      #output directory

cd $DIRout

mkdir -p $DIRout/results/meansP0
mkdir -p $DIRout/results/output_ordered

#Make a list of pairwise tped files
ls keep*.tped > tped.list

#Prepare unique downsampled SNP list for each simulated pair and run READ with five different overlapping SNP counts (N)
for file in $(cat $DIRout/tped.list)
do
filebase=$(basename $file .tped)	
for N in 1000 5000 10000 20000 50000
do
cat $file | awk '{print $2}'| shuf -n $N | sort -V > snp_list_${filebase}_${N}_${b}
grep -w -f snp_list_${filebase}_${N}_${b} ${file}> ${filebase}_${N}_${b}.tped
	echo ${filebase}_${N}_${b}.tped DONE
cp $DIRout/${filebase}.tfam ${filebase}_${N}_${b}.tfam
rm snp_list_${filebase}_${N}_${b}	
	echo ${filebase}_${N}_${b}.tfam DONE
python2 READ.py ${filebase}_${N}_${b} --outputVar ${filebase}_${N}_${b}_READ 
	echo ${filebase}_${N}_${b} READ DONE
rm ${filebase}_${N}_${b}.tped 
rm ${filebase}_${N}_${b}.tfam
rm -f Read_intermediate_output${filebase}_${N}_${b}*
rm -f READ_results${filebase}_${N}_${b}*
mv meansP0_AncientDNA_normalized${filebase}_${N}_${b}* $DIRout/results/meansP0
mv READ_output_ordered${filebase}_${N}_${b}* $DIRout/results/output_ordered
done
done
