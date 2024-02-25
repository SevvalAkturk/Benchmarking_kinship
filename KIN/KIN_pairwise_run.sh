#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J KIN
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err


DIRout=/path/to/output    #output directory

for b in 1 2 3 4 5
do
for N in 5000 10000 20000 50000
do
for target in $(cat /path/to/targets.list)
do
cd $DIRout/${b}/${N}/${target}

#Run KIN with updated p_0.txt 
/path/to/KIN -I $DIRout/${b}/${N}/${target}/ -O $DIRout/${b}/${N}/${target}/analysis/ -c [node] 
	echo ${target} ${N} ${b} KIN DONE
done
done
done