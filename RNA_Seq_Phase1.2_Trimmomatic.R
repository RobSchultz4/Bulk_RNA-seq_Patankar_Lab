# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 1.2 -- Trimmomatic. Run this script after running FastQC to Trim reads as needed. 

### Before Running the Script:
# Update the Trimmomatic setting as needed
# Please update the username

#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))

username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/rna-seq",sep = ""))

# Set file and folder naming parameters
#Do not include a trailing /
project_name <- "ovcar3_ato" # folder name for the present project
fastQ_folder_name <- "fastqs" # folder name containing paired fastq files
extension <- '.fq.gz' # file extension of fastq files
output_folder_name <- "trimmed_fastqs" # folder where results will be stored



### Trimmomatic Settings - If you don't want to include a step, type FALSE
# Specify which Illumina sequencer is used (Needed to remove the right adapter sequences)
# Choose from: NexteraPE-PE, TruSeq2-PE, TruSeq2-SE, TruSeq3-PE, TruSeq3-PE-2, or TruSeq3-SE
Illumina_Sequencer <- "TruSeq3-PE" 
# Varies
Trim_From_Front <- 10 #Cut the specified number of bases from the start of the read
#Usually the same
Quality_Leading <- 20 # Cut bases off the start of a read, if below this threshold quality 
Quality_Trailing <- 20 # Cut bases off the end of a read, if below this threshold quality
Minimum_Length <- FALSE #Drop the read if it is below a specified length
Make_Log <- FALSE #if True, trimmomatic will write a log file... They are very big so I dont reccommend
  
###The Script is Automated from here
# Load Libraries
library(sys) # for system2

# Define Paths
fastQ_path <- paste("projects", project_name, fastQ_folder_name, sep = "/")
output_path <- paste("projects", project_name, output_folder_name, sep = "/")


# Create the command to Run Trimmomatic on all files with <extension> in fastQ_path
fileNames <- dir(fastQ_path)

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
  sampleNames <- append(sampleNames,getSampleName(file1))
}
sampleNames <- unique(sampleNames)

#Update Steps with the values given
removeAdapterSettings <- paste("ILLUMINACLIP:trimmomatic-0.39/adapters/",Illumina_Sequencer,".fa:2:30:10:2:True",sep = "")
phredSetting <- "-phred33"
leadingSettings <- ""
if(Quality_Leading){leadingSettings <- paste("LEADING:",Quality_Leading,sep = "")}
trailingSettings <- ""
if(Quality_Trailing){trailingSettings <- paste("TRAILING:" ,Quality_Trailing,sep = "")}
minLenSettings <- ""
if (Minimum_Length){minLenSettings <- paste("MINLEN:",Minimum_Length,sep = "")}
headcropSettings <- ""
if (Trim_From_Front){headcropSettings <- paste("HEADCROP:", Trim_From_Front,sep = "")}



trim_command <- paste("java -jar trimmomatic-0.39/dist/jar/Trimmomatic-0.39.jar PE", phredSetting, sep = " ")
all_outputs <- c()
commands <- c()
count <- 1
for (sn in sampleNames){
  if (Make_Log == TRUE){
    log_info <- paste("-trimlog log",count,".txt", sep = "")
  } else{ log_info = ""}
  in_prefix <- paste(fastQ_path, sn, sep="/")
  out_prefix <- paste(output_path, sn, sep="/")
  inputs <- paste(paste(in_prefix,1,extension, sep = ""),paste(in_prefix,2,extension, sep = ""), sep = " ")
  outputs <- paste(paste(out_prefix,"paired_output_",1,extension,sep = ""), paste(out_prefix,"unpaired_output_",1,extension,sep = ""),paste(out_prefix,"paired_output_",2,extension,sep = ""), paste(out_prefix,"unpaired_output_",2,extension,sep = ""),sep = " ")
  steps <- paste(removeAdapterSettings, leadingSettings, trailingSettings, minLenSettings,sep = " ")
  command <- paste(trim_command,log_info,inputs, outputs,steps, sep = " ")
  commands <- c(commands,command)
  all_outputs <- c(all_outputs,outputs)
  count <- count + 1
  
}

# Create results folder if its not there already:
#if (!output_folder %in% dir()){
# dir.create(output_folder)
#}

#for (output in strsplit(paste(all_outputs,collapse = " "), " ")){
#  print(output)
#  file.create(output)
#}



# Run Trimmomatic -- with exec_wait, R will wait for the process to finish before continuing...
# If the process is taking too long press Esc to exit the process

res_trims <- c()
for(command in commands){
  res_trims <- c(res_trims,exec_wait(command, std_out = TRUE, std_err = TRUE))
}


# Check Trim output Folder

dir(output_path)

