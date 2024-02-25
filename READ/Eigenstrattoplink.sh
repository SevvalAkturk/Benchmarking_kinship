#bin/bash -l
#SBATCH -p partition
#SBATCH -n node  
#SBATCH -t time                 
#SBATCH -J convertf
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err


DIRout=/path/to/output            #output directory
filename=xxx                      #name of the output file
admixtools=/path/to/admixtools    #admixtools version 7.0.2

$admixtools/convertf -p $DIRout/{filename}