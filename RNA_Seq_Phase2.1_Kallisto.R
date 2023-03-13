# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 1.3 -- Kallisto. Run this script to align the fastqs to a reference genome. This will return transcript counts

### Before Running the Script:
## Make sure for each fastq that there is the forward and reverse pair in the folder
## Make sure the Forward Reads have a 1 at the end of their names and the Reverse reads have a 2 at the end of their names for example:
## D_1_1.fq.gz and D_1_2.fq.gz are the forward and reverse reads for the D_1_ sample with the extension .fq.gz
# Please update the username, setwd, fastQ_path, and extension if needed.
# Set the working directory to the RNA-Seq folder


#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))


username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/rna-seq",sep = ""))

# Set file and folder naming parameters
#Do not include a trailing /
project_name <- "ovcar3_ato" # folder name for the present project
fastQ_folder_name <- "fastqs" # folder name containing paired fastq files
trimmed_fastQ_folder_name <- "trimmed_fastqs" # folder name containing fastq files trimmed with trimmomatic
extension <- ".fq.gz" # file extension of fastq files

###The Script is Automated from here
# Load Libraries
library(sys) # for system2

# Define Paths
fastQ_path <- paste("projects", project_name, fastQ_folder_name, sep = "/")
trimmed_fastQ_path <- paste("projects", project_name, trimmed_fastQ_folder_name, sep = "/")
output_path <- paste("projects", project_name, "kallisto_results", sep = "/")

### Create the command to Run Kallisto on all files with <extension> in fastQ_path
fileNames <- dir(fastQ_path)
trimmedFileNames <- dir(trimmed_fastQ_path)

for (file1 in fileNames){ # remove files that are not fastqs
  print(file1)
  if (!grepl(extension,file1, fixed = TRUE)){ 
    fileNames <- fileNames[fileNames != file1]
  }
}

# Extract the unique sample names from the file
getSampleName <- function(file1){
  substr(file1,1,nchar(file1)-nchar(extension)-1)
}

sampleNames <- c()
for(file1 in fileNames){
  if(grepl("unpaired",file1)){
    print(paste("skip unpaired output:",file1,sep = " "))
  }else{
      sampleNames <- c(sampleNames,getSampleName(file1))
  }
}
sampleNames <- unique(sampleNames)

trimmedSampleNames <- c()
for(file1 in trimmedFileNames){
  if(grepl("unpaired",file1)){
    print(paste("skip unpaired output:",file1,sep = " "))
  }else{
    trimmedSampleNames <- c(trimmedSampleNames,getSampleName(file1))
  }
}
trimmedSampleNames <- unique(trimmedSampleNames)



inputs = c()
commands = c()
outputs = c()
for (sn in sampleNames){
  in_prefix <- paste(trimmed_fastQ_path, paste(sn,"paired_output_",sep = ""), sep="/")
  output <- paste(output_path,substr(sn,1,nchar(sn)-1),sep="/")
  outputs <- c(outputs,output)
  input <-paste(paste(in_prefix,1,extension, sep = ""),paste(in_prefix,2,extension, sep = ""), sep = " ")
  inputs <- c(inputs,input)
  command <- paste("kallisto/kallisto quant -i kallisto/homo_sapiens/transcriptome.idx -o", output,"-b","100",input,sep = " ")
  commands <- c(commands,command)
  }

# Run Kallisto -- with exec_wait, R will wait for the process to finish before continuing...
# If the process is taking too long press Esc to exit the process
res_trims = c()
for(command in commands){
  print(paste('Running: ',command))
  res_trims <- c(res_trims,exec_wait(command, std_out = TRUE, std_err = TRUE))
}


dir(output_path)





















