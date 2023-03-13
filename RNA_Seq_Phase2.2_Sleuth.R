# RNA-Seq Pipeline for the Patankar Barroilhet Lab 
# Author: Rob Schultz 1/23/22
# Phase 2 -- Sleuth. Run this script after alignment to a reference genome to analyze the data

### Before Running the Script:
# Please update the username, setwd
# Set the working directory to the RNA-Seq folder
# Create a metadata file for the project named metadata.csv including columns:
# "sample", "cell.line" or "tissue.type", "treatment", "time.point.units", "batch"
# Save metadata.csv in the project folder

#username <- 'betancourtpo' 
#setwd(paste("C:/Users/",username, "/Documents/FastQC",sep = ""))

username <- 'rmschultz3' 
setwd(paste("C:/Users/",username, "/Documents/rna-seq",sep = ""))
# Set file and folder naming parameters
#Do not include a trailing /
project_name <- "ovcar3_ato" # folder name for the present project
metadata_filename <- "metadata_test.csv"



library('cowplot')
library('sleuth')


metadata <- read.table(paste("projects",project_name,metadata_filename,sep ="/"), sep=",", header=TRUE, stringsAsFactors = FALSE)
metadata <- dplyr::mutate(metadata,
                          path = file.path("projects",project_name, "kallisto_results", sample, 'abundance.h5'))

#Connect to Ensemble
mart <- biomaRt::useMart(biomart = "ENSEMBL_MART_ENSEMBL",
                         dataset = "hsapiens_gene_ensembl",
                         host = "https://oct2022.archive.ensembl.org") # Consider updating  

# Make transcript to gene table
ttg <- biomaRt::getBM(
  attributes = c("ensembl_transcript_id", "transcript_version",
                 "ensembl_gene_id", "external_gene_name", "description",
                 "transcript_biotype"),
  mart = mart)
ttg <- dplyr::rename(ttg, target_id = ensembl_transcript_id,
                     ens_gene = ensembl_gene_id, ext_gene = external_gene_name)
ttg <- dplyr::select(ttg, c('target_id', 'ens_gene', 'ext_gene'))



# Preparing the Sleuth Object
so <- sleuth_prep(metadata, target_mapping = ttg,
                  aggregation_column = 'ens_gene') #, extra_bootstrap_summary = TRUE)
# ** If you get the below warning, you can type so$target_mapping into console to make sure the mapping still matches ttg. When I did it, it does, so, Patankar Lab members shouldn't have to worry about it.. 
#2: In check_target_mapping(tmp_names, target_mapping, !is.null(aggregation_column)) :
#intersection between target_id from kallisto runs and the target_mapping is empty. attempted to fix problem by removing .N from target_id, then merging back into target_mapping. please check obj$target_mapping to ensure this new mapping is correct.

reduce_cols = c()
for (col in names(metadata)){
  #print(paste("col:",col))
  #print(paste("unique:",nrow(unique(metadata[col]))))
  #print(paste("not unique:",nrow(metadata[col])))
  if (nrow(unique(metadata[col])) < nrow(metadata[col]) && nrow(unique(metadata[col])) > 1){
    reduce_cols = c(reduce_cols,col)
  }
}



#library(tidyr)
#crossing(reduce_cols,reduce_cols)
#reduce_formulas = c(reduce_formulas, paste("~",paste(reduce_cols,collapse = "+")))
# *******************************************
# Need to continue cleaning this up! trying to get all combos of reduce cols for all possible differentially expressed genes tests...
# But actually that's definitely an overload... Would rather have an easy way the user can input the tests theyre interested in.
# ********************************************
col_combs = list()
for (i in 1:length(reduce_cols)){
  print(i)
  a = combn(reduce_cols,i)
    col_combs = list(col_combs,list(a))
  print(a)
}



# Find Differentially Expressed Genes
so <- sleuth_fit(so, ~time.point.hrs, 'full')
so <- sleuth_fit(so, ~time.point.hrs + treatment, 'practice2')

so <- sleuth_fit(so, ~ index + time.point.hrs, 'practice0' )
so <- sleuth_fit(so, ~ treatment, 'practice1' )
# ** Expected Output:
#fitting measurement error models
#shrinkage estimation
#computing variance of betas



# ** If either of the below Errors comes up:
# Error 1
#fitting measurement error models
#shrinkage estimation
#Error in if (sum(valid) == 0) { : missing value where TRUE/FALSE needed
#
# Error 2
#Error in solve.default(t(X) %*% X) : 
#system is computationally singular: reciprocal condition number = 1.21789e-19
#
# ** Most likely, one of the columns (in your metadata table) you are trying to find differentially expressed genes for has only unique values.
# ** For example Treatments might be reported as ato_1, ato_2, ato_3, control_1, control_2, control_3. Instead use: ato, ato, ato, control,control,control.
# ** Alternatively, it might mean that column has no replicates which is necessary for the analysis
# ** Either fix the column to a uniform naming system, add a new column with the uniform naming system to use in the analysis instead, or add replicates to the analysis
#
# ** If this error come up:
# Error 3
#Error in solve.default(t(X) %*% X) : 
#Lapack routine dgesv: system is exactly singular: U[3,3] = 0
# ** this indicates, one of the columns (in your metadata table) you are trying to find differentially expressed genes for has only one value.
# ** For example time points might be reported as 24,24,24,24 because the only time point you used was 24 hours...
# ** To get differentially expressed genes, you need more than one value to compare... Consider adding another time point.


# Perform the likelihood ratio test for each reduced set
for (reduced in reduce_cols){
  so <- sleuth_lrt(so, reduced, 'full')
}



