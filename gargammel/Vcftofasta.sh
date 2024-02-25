#!/bin/bash -l
#SBATCH -p partition
#SBATCH -n node
#SBATCH -t time
#SBATCH -J vcf2gargamel
#SBATCH -o slurm-%j-%N-%u.out
#SBATCH -e slurm-%J-%N-%u.err

file=$1      #vcf file
run=$2       #run number
DIRout=$3    #output directory

filebase=$(basename $file .vcf)
snplist=/path/to/SNP_list_200K         #list of 200K SNPs of TSI from 1000 Genomes Project phase 3
snpbed=/path/to/snp_list_200K.bed      #bed file of 200K SNPs
ref=/path/to/hs37d5.fa                 #reference fasta file
sizedist=/path/to/sizedist.size_1.gz   #read size distribution file for gargammel

mkdir -p ${DIRout}/gargamel_fq

DIRbcf=/path/to/bcftools         #bcftools version 1.11
DIRvcf=/path/to/vcf-consensus    #vcftools version 0.1.16
DIRbed=/path/to/bedtools         #bedtools version 2.25.0
DIRgar=/path/to/gargammel

export PERL5LIB=/path/to/perl/   #vcftools version 0.1.16

cd ${DIRout}

#Select 200K SNPs of TSI from 1000 Genomes Project phase 3 from vcf files of simulated individuals
$DIRbcf view --header-only ${file} > headers_${filebase}
grep -v "#" ${file} | awk '{print $1,$2,$1"_"$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' | sed 's/ /\t/g' > noheaders_cp_t_${filebase}
grep -w -f ${snplist} noheaders_cp_t_${filebase} > noheaders_cp_t_200K_${filebase}
cat noheaders_cp_t_200K_${filebase} >> headers_${filebase}
mv headers_${filebase} ${filebase}_200K.vcf

rm noheaders_cp_t_${filebase}
rm noheaders_cp_t_200K_${filebase}


echo "from ${file} 200K selected"

#Split vcf files of simulated individuals 

bgzip ${filebase}_200K.vcf
$DIRbcf +split ${filebase}_200K.vcf.gz -Oz -o ${DIRout}/${filebase}

rm ${filebase}_200K.vcf.gz


#Prepare endo fasta files and run gargammel

ls ${DIRout}/${filebase}/*.gz > ${DIRout}/${filebase}/filelist.txt

for indv in $(cat ${DIRout}/${filebase}/filelist.txt)
do

  indvbase=$(basename $indv .vcf.gz)

  echo "$indv is running"

  $DIRbcf view $indv -i 'GT="AA" || GT="RA"' > ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf
  $DIRbcf view $indv -i 'GT="AA"' > ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf
  bgzip ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf
  bgzip ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf
  $DIRbcf index ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf.gz
  $DIRbcf index ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf.gz

  mkdir -p ${DIRout}/${filebase}/${indvbase}/data/{endo,bact,cont}

  cat ${ref} | $DIRvcf ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf.gz > ${DIRout}/${filebase}/${indvbase}_endo.1.fa
  cat ${ref} | $DIRvcf ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf.gz > ${DIRout}/${filebase}/${indvbase}_endo.2.fa

  rm ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf.gz
  rm ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf.gz
  rm ${DIRout}/${filebase}/${indvbase}_alt_homs_hets.vcf.gz.csi
  rm ${DIRout}/${filebase}/${indvbase}_alt_homs.vcf.gz.csi

  echo "${indvbase} vcfconsensus done"

  $DIRbed getfasta -fi ${DIRout}/${filebase}/${indvbase}_endo.1.fa -bed ${snpbed} -fo ${DIRout}/${filebase}/${indvbase}/data/endo/endo.1.fa
  $DIRbed getfasta -fi ${DIRout}/${filebase}/${indvbase}_endo.2.fa -bed ${snpbed} -fo ${DIRout}/${filebase}/${indvbase}/data/endo/endo.2.fa

        echo "${indvbase} getfasta done"

  rm ${DIRout}/${filebase}/${indvbase}_endo.1.fa
  rm ${DIRout}/${filebase}/${indvbase}_endo.2.fa
  rm ${DIRout}/${filebase}/${indvbase}_endo.1.fa.fai
  rm ${DIRout}/${filebase}/${indvbase}_endo.2.fa.fai

  export PERL5LIB=/path/to/perl/    #vcftools version 0.1.16
        
  perl $DIRgar/gargammel.pl -c 2.75 --comp 0,0,1 -s ${sizedist} -damage 0.024,0.36,0.0097,0.55 -o ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase} ${DIRout}/${filebase}/${indvbase}/data

  echo "${indvbase} gargammel done"

  rm ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase}_a.fa.gz ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase}.b.fa.gz ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase}.c.fa.gz ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase}_d.fa.gz ${DIRout}/gargamel_fq/cov5x_run${run}_${filebase}_${indvbase}.e.fa.gz 

  rm $indv
done
