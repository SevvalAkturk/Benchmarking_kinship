#!/bin/bash -l
#SBATCH -p partition-name
#SBATCH -n 1
#SBATCH -t time
#SBATCH -J job-name
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err


# Adjusting paths for portability
DIRang=/path/to/angsd
working_path=/path/to/bams/directory #where bams are located
bam_list=/path/to/bam.list #bamlist
angsd_file=/path/to/angsd.file #angsd file
DIRout=/path/to/output/directory
maf_file=/path/to/maf.frq #maf file



# Executing ANGSD command
$DIRang -b ${bam_list} -gl 2 -domajorminor 1 -domaf 1 -doGlf 2 -sites ${angsd_file} -out $DIRout/angsd_all

# Change directory to the output directory
cd ${DIRout}

# Unzipping the beagle.gz file and perform GLF subsetting for each sample with an Rscript
gunzip $DIRout/angsd_all.beagle.gz
Rscript ${DIRout}/GLF_subset.R 

# Retrieving the MAFs from Tuscany population instead of using the MAFs calculated by ANGSD
gunzip $DIRout/angsd_all.mafs.gz
awk '{print $1"_"$2,$1,$2,$3,$4,$5,$6}' $DIRout/angsd_all.mafs | cat | tr ' ' '\t' > $DIRout/angsd_all_snpID.mafs
awk '{print $1"_"$2}' $DIRout/angsd_all.mafs | cat | tr ' ' '\t' | sed 1d > $DIRout/snp_IDs
awk '{print $1,$1"_"$2,$2,$3,$4,$5,$6}' ${maf_file} | cat | tr ' ' '\t' > $DIRout/Tuscan_MAFs_w_unique_pos
grep -w -f $DIRout/snp_IDs $DIRout/Tuscan_MAFs_w_unique_pos | cat | tr ' ' '\t' | cut -f2,7 > $DIRout/freq

# Preparing pair names
Rscript ${DIRout}/pairnames_script.R
sed 1d ${DIRout}/pair_names > ${DIRout}/pairnames_file
rm ${DIRout}/pair_names

echo DONE
