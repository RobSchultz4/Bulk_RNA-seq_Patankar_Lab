# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 1.1 -- FastQC. Run this script first of all to determine the quality of the sequencing reads. 

### Before Running the Script:
# Put the fastqs into fastQ_path
# Make sure for each fastq that there is the forward and reverse pair in the folder
# Make sure the Forward Reads have a 1 at the end of their names and the Reverse reads have a 2 at the end of their names for example:
# D_1_1.fq.gz and D_1_2.fq.gz are the forward and reverse reads for the D_1_ sample with the extension .fq.gz
# Please update the username, setwd, project_name, fastQ_path, and extension
# Set the working directory--determine the folder on your computer that R is working from
# The default is the user's documents, so, enter the path to the desired folder from there

#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))

username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/rna-seq",sep = ""))

# Set file and folder naming parameters
# After trimming, change fastQ_folder_name to "trimmed_fastqs"
# Do not include a trailing /
project_name <- "ovcar3_ato" # folder name for the present project
fastQ_folder_name <- "fastqs" # folder name containing fastq files trimmed with trimmomatic
extension <- '.fq.gz' # file extension of fastq files
output_folder_name <- "fastqc_results" # folder where results will be stored


###The Script is Automated from here

# Load Libraries
library(sys) # for system2

# Define Paths
fastQ_path <- paste("projects", project_name, fastQ_folder_name, sep = "/")
output_path <- paste("projects", project_name, output_folder_name, sep = "/")

# Create the command to Run FastQC on all files with extension in fastQ_path
fileNames <- ""
for (file1 in dir(fastQ_path)){
  print(file1)
  if (grepl(extension,file1, fixed = TRUE)){ 
    fileNames <- paste(fileNames,paste(fastQ_path,file1,sep = "/"), sep = " ")
  }
}
fileNames <- substr(fileNames,2,nchar(fileNames))



command_Fastqc <- paste("java  -Xmx250m -classpath fastqc/.;fastqc/./sam-1.103.jar;fastqc/./jbzip2-0.9.jar -Dfastqc.output_dir=",output_path," uk.ac.babraham.FastQC.FastQCApplication",sep = "")
command <- paste(command_Fastqc,fileNames,sep = " ")

# Run FastQC -- with exec_wait, R will wait for the process to finish before continuing...
# If the process is taking too long press Esc to exit the process

res_fastqc <- exec_wait(command, std_out = TRUE, std_err = TRUE)

# Check fastQC output Folder

dir(output_path)










