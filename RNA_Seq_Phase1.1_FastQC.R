# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 1.1 -- FastQC. Run this script first of all to determine the quality of the sequencing reads. 

### Before Running the Script:
#Please update the username, setwd, fastQ_path, and extension
# Set the working directory--determine the folder on your computer that R is working from
# The default is the user's documents, so, enter the path to the desired folder from there


#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))

username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/OVCAR3_ATO_RNA-seq/FastQC",sep = ""))

# Path to FastQ files with RNA-seq results, this will also be where FastQC results go
# The FastQ files need to all be in one subfolder from the directory where FastQC is
fastQ_path <- "FASTQ_data/"
extension <- '.fq.gz'

###The Script is Automated from here

# Load Libraries
library(sys) # for system2

# Create the command to Run FastQC on all files with extension in fastQ_path

fileNames <- ""
for (file1 in dir(fastQ_path)){
  print(file1)
  if (grepl(extension,file1, fixed = TRUE)){ 
    fileNames <- paste(fileNames,paste(fastQ_path,file1,sep = ""), sep = " ")
  }
}
fileNames <- substr(fileNames,2,nchar(fileNames))

command_Fastqc <- paste("run_fastqc.bat",fileNames,sep = " ")

# Run FastQC -- with exec_wait, R will wait for the process to finish before continuing...
# If the process is taking too long press Esc to exit the process

res_fastqc <- exec_wait(command_Fastqc, std_out = TRUE, std_err = TRUE)

# Check fastQC output Folder

dir(fastQ_path)










