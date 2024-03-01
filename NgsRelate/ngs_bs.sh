#!/bin/bash -l
#SBATCH -p partition-name
#SBATCH -n 1
#SBATCH -t time
#SBATCH -J job-name
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

# Running ngsRelate for each pair in the dataset

bs=$1   # bootstrap number
DIRout=$2  # output path

DIRang=/path/to/angsd
DIRngs=/path/to/ngsRelate

angsd_all_file_snpID=/path/to/angsd_all_snpID.mafs
snpID=/path/to/snp_IDs
pair_name=/path/to/pairnames_file


cd ${DIRout}


for pair in $(cat ${pair_name})
do 

pairbase=$(basename $pair)

cat $DIRout/data_${pairbase}.beagle | cut -f1 | sed 1d | sed 1d > $DIRout/${pairbase}_${bs}_snp.list

for N in 1000 5000 10000 20000 50000
do

    # Preparing downsampled SNP list
    cat $DIRout/${pairbase}_${bs}_snp.list | shuf -n ${N} | sort -V  > $DIRout/snps_${pairbase}_${bs}_${N}

    # Preparing frequency file for ngsRelate accordingly
	grep -w -f $DIRout/snps_${pairbase}_${bs}_${N} $DIRout/freq | cat | cut -f2  > $DIRout/freq_${pairbase}_${bs}_${N}.file

    # Preparing GLFs for ngsRelate accordingly
    awk -v n=1 -v s="marker" 'NR == n {print s} {print}' $DIRout/snps_${pairbase}_${bs}_${N} > $DIRout/snps_${pairbase}_${bs}_${N}_header
    grep -w -f $DIRout/snps_${pairbase}_${bs}_${N}_header $DIRout/data_${pairbase}.beagle | sed 2d > $DIRout/${pairbase}_${bs}_${N}.beagle
    gzip $DIRout/${pairbase}_${bs}_${N}.beagle 

    # Converting GLFs into binary GLFs
    zcat $DIRout/${pairbase}_${bs}_${N}.beagle.gz | tail -n +2 | perl -an -e 'for($i=3; $i<=$#F; $i++){print(pack("d",($F[$i]==0 ? -inf : log($F[$i]))))}' > $DIRout/${pairbase}_${bs}_${N}.glf.gz

    # Executing ngsRelate
    $DIRngs -g $DIRout/${pairbase}_${bs}_${N}.glf.gz -n 2 -f $DIRout/freq_${pairbase}_${bs}_${N}.file -l 0 -O $DIRout/ngs_results/${pairbase}_${bs}_${N}_ngs.out.res 

# Removing unnecessary files
rm $DIRout/snps_${pairbase}_${bs}_${N}
rm $DIRout/snps_${pairbase}_${bs}_${N}_header
rm $DIRout/freq_${pairbase}_${bs}_${N}.file
rm $DIRout/${pairbase}_${bs}_${N}.beagle.gz
rm $DIRout/${pairbase}_${bs}_${N}.glf.gz


done

rm $DIRout/${pairbase}_${bs}_snp.list

done
