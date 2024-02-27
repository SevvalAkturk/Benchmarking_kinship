

setwd("/path/to/output/directory") #Same with the mafs_glfs.sh script

data = read.table("./angsd_all.beagle", header=FALSE, stringsAsFactors = FALSE, check.names = FALSE)
colnames(data)[1] <- "marker" 
colnames(data)[2] <-"alelle1"
colnames(data)[3] <-"alelle2"


#Changing column names according to the pair names 
names = read.table("path/to/sample_names_file",header= FALSE,stringsAsFactors = FALSE)

for (i in 1:72){
  colnames(data)[3*i+1] <- namesi[,1]
  colnames(data)[3*i+2] <- names[i,1]
  colnames(data)[3*i+3] <- names[i,1]
} 


#Subsetting ANGSD GLF output according to the pair names 
for (i in seq(1,nrow(names)-1)) {
  for (j in seq(i+1,nrow(names))){
    temp <- NULL
    temp <- rbind(temp, data.frame(data$marker, data$alelle1, data$alelle2, check.names = FALSE))
    colnames(temp)[1] <- "marker"
    indv1 <- names[i,1]
    indv2 <- names[j,1]
    temp <- cbind(temp, data[,grep(indv1,colnames(data))])
    temp <- cbind(temp, data[,grep(indv2,colnames(data))])
    temp = temp[!(temp[,4] == "0.333333" &temp[,5] == "0.333333" &temp[,6] == "0.333333"),]
    temp = temp[!(temp[,7] == "0.333333" &temp[,8] == "0.333333" &temp[,9] == "0.333333"),]
    colnames(temp)[2] <- "alelle1"
    colnames(temp)[3] <- "allele2"
    colnames(temp)[4:6] <- "Ind0"
    colnames(temp)[7:9] <- "Ind1"
    #Writing GLF files for each pair in the dataset
    write.table(temp, file = paste("data_",indv1,"_",indv2,".beagle",sep=""), sep="\t", row.names = FALSE, quote = FALSE)
  }
}
