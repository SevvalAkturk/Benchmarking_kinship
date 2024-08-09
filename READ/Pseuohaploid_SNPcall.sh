#bin/bash -l
#SBATCH -p partition
#SBATCH -n node  
#SBATCH -t time                 
#SBATCH -J SNPcall
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err


DIRout=/path/to/output                  #output directory
snpbed=/path/to/snpcall_200K.bed        #bed file with 200K SNPs
ref=/path/to/hs37d5.fa                  #human reference fasta file
samtools=/path/to/samtools              #samtools version 1.9
sequenceTools=/path/to/sequenceTools    #sequenceTools version 1.4.0
filename=xxx                            #name of the output file
snpfile=/path/to/eigenstrat.snp         #snp file with eigenstrat format

cd $DIRout

#Genotype calling (minimum mapping quality:30 and minimum base quality:30)
$samtools mpileup -R -B -q30 -Q30 -l ${snpbed} -f ${ref} -b $DIRout/bam.list > $DIRout/${filename}.txt
$sequenceTools/pileupCaller --randomHaploid --sampleNameFile $DIRout/pairs -f $DIRout/${snpfile} -e $DIRout/{filename} < $DIRout/${filename}.txt 

