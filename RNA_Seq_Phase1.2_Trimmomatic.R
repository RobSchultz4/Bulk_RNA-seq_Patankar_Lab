# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 1.2 -- Trimmomatic. Run this script after running FastQC to Trim reads as needed. 

### Before Running the Script:
# Put the fastqs into the trimmomatic fastQ_folder folder
# Make sure for each fastq that there is the forward and reverse pair in the folder
# Make sure the Forward Reads have a 1 at the end of their names and the Reverse reads have a 2 at the end of their names for example:
# D_1_1.fq.gz and D_1_2.fq.gz are the forward and reverse reads for the D_1_ sample with the extension .fq.gz
# Update the Trimmomatic setting as needed
# Please update the username, setwd, fastQ_folder, and extension if needed.
# Set the working directory--determine the folder on your computer that R is working from
# The default is the user's documents, so, enter the path to the desired folder from there


#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))

username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/OVCAR3_ATO_RNA-seq/Trimmomatic-0.39",sep = ""))

# Path to FastQ files with RNA-seq results, this will also be where FastQC results go
# The FastQ files need to all be in one subfolder from the directory where FastQC is
fastQ_folder <- "FASTQ_data" #Do not include a trailing /
extension <- '.fq.gz'
output_folder <- "results" # Folder where results will be stored

### Trimmomatic Settings - If you don't want to include a step, type FALSE
# Varies
Trim_From_Front <- 10 #Cut the specified number of bases from the start of the read
#Usually the same
Quality_Leading <- 3 # Cut bases off the start of a read, if below this threshold quality 
Quality_Trailing <- 3 # Cut bases off the end of a read, if below this threshold quality
Minimum_Length <- FALSE #Drop the read if it is below a specified length

  
###The Script is Automated from here
# Load Libraries
library(sys) # for system2

# Create the command to Run Trimmomatic on all files with <extension> in fastQ_folder



fileNames <- dir(fastQ_folder)

for (file1 in fileNames){ # remove files that are not fastqs
  print(file1)
  if (!grepl(extension,file1, fixed = TRUE)){ 
    fileNames <- fileNames[fileNames != file1]
  }
}

# I need to extract the unique samples from the file
getSampleName <- function(file1){
  substr(file1,1,nchar(file1)-nchar(extension)-1)
}

sampleNames <- c()
for(file1 in fileNames){
  sampleNames <- append(sampleNames,getSampleName(file1))
}
sampleNames <- unique(sampleNames)

#Update Steps with the values given
removeAdapterSettings <- "ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10:2:True"
phredSetting <- "-phred33"
#TrimLogSetting <- "-trimlog"
TrimLogSetting <- ""
leadingSettings <- ""
if(Quality_Leading){leadingSettings <- paste("LEADING:",Quality_Leading,sep = "")}
trailingSettings <- ""
if(Quality_Trailing){trailingSettings <- paste("TRAILING:" ,Quality_Trailing,sep = "")}
minLenSettings <- ""
if (Minimum_Length){minLenSettings <- paste("MINLEN:",Minimum_Length,sep = "")}
headcropSettings <- ""
if (Trim_From_Front){headcropSettings <- paste("HEADCROP:", Trim_From_Front,sep = "")}
log <- "-trimlog log"


trim_command <- paste("java -jar dist/jar/Trimmomatic-0.39.jar PE", phredSetting,TrimLogSetting, sep = " ")
all_outputs <- c()
commands <- c()
count <- 1
for (sn in sampleNames){
  log_info <- paste("-trimlog log",count,".txt", sep = "")
  in_prefix <- paste(fastQ_folder, sn, sep="/")
  out_prefix <- paste(output_folder, sn, sep="/")
  inputs <- paste(paste(in_prefix,1,extension, sep = ""),paste(in_prefix,2,extension, sep = ""), sep = " ")
  outputs <- paste(paste(out_prefix,1,"_paired_output",extension,sep = ""), paste(out_prefix,1,"_unpaired_output",extension,sep = ""),paste(out_prefix,2,"_paired_output",extension,sep = ""), paste(out_prefix,2,"_unpaired_output",extension,sep = ""),sep = " ")
  steps <- paste(removeAdapterSettings, leadingSettings, trailingSettings, minLenSettings,sep = " ")
  command <- paste(trim_command,log_info,inputs, outputs,steps, sep = " ")
  commands <- c(commands,command)
  all_outputs <- c(all_outputs,outputs)
  count <- count + 1
  
}

# Create results folder if its not there already:
if (!output_folder %in% dir()){
  dir.create(output_folder)
}

#for (output in strsplit(paste(all_outputs,collapse = " "), " ")){
#  print(output)
#  file.create(output)
#}


# Run Trimmomatic -- with exec_wait, R will wait for the process to finish before continuing...
# If the process is taking too long press Esc to exit the process

res_trims <- c()
for(command in commands){
  res_trims <- append(res_trims,exec_wait(command, std_out = TRUE, std_err = TRUE))
}


# Check Trim output Folder

dir(output_folder)

