

setwd("/path/to/output/directory/") #Same with the mafs_glfs.sh script

names = read.table("path/to/sample_names_file")

names = as.character(names$V1)

pairs = c()

for (i in seq(1, length(names)-1)) {
    for (j in seq(i+1, length(names))){ 
        pairs = rbind(pairs, (paste(names[i],"_",names[j], sep = "")))
      }
}

write.csv(pairs, file = "pair_names", row.names = F, quote = FALSE)


