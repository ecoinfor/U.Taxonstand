#'Format the taxon names of the database into the required format
#'
#' This function is used to format the input taxon names before running the function \code{\link[U.Taxonstand:nameMatch]{nameMatch}}. The function will add a new column "NameClean" by removing some epithets such as "var.", "f.", "X ", " x ", "×" and more, and a new column "GENUS" is missing.
#' #'
#' @param dataSource A data frame with at least one column of the Latin name.
#'
#' @param author Logical. Will change "fil." to "f." and change "Linn." to "L.".
#'
#' @return A data frame with a new column "NameClean" and a new column "GENUS" if the column "GENUS" is missing in the datasource.
#'
#'@author Jian Zhang & Hong Qian
#'
#'@examples
#'data(databaseExample)
#'dat <- databaseExample[,1:3]
#'
#'# For the database you will use in the future, you can save the result
#'# to save some time in the name matching
#'datClean <- nameClean(dat)
#'head(datClean)
#'
#'@export
nameClean <- function(dataSource=NULL, author=TRUE){
  ## Add one new column "NameClean" for the data source used to match with.
  ## I suggest you to save the result as a R datafile.
  ## Then, you can use it directly for further name matching.
  ## It will save some time to prepare the data.

  if(!is.data.frame(dataSource)) dataSource <- data.frame(Name=dataSource)
  colnames(dataSource) <- toupper(colnames(dataSource))
  
  ##-------------- preparing the datasets
  epithets <- c("var.","f.","ssp.","grex","nothossp.","prol.","gama","lus.","monstr.","race","nm","subvar.","subf.", "X", "\u00d7", "subprol.","cv.", "-", "var", "f", "fo", "fo.", "form", "forma", "forma.", "x", "ssp", "subsp.", "subsp", "cv", "cultivar.", "cultivar", "nothossp", "nothosubsp.", "nothosubsp", "prol", "proles.", "proles", "grex.", "gama.", "lusus", "lusus.", "lus","monstr","race.","nm.","subvar","subf","subfo","subfo.","subform.","subform","subprol","subproles.","subproles")
  
  dataSource$NameClean <- dataSource$NAME
  dataSource$NameClean <- gsub(paste0("\\s+|", intToUtf8(160)), " ", as.character(dataSource$NameClean))
  dataSource$NameClean <- gsub("(?! )\\(", " \\(", dataSource$NameClean, perl = TRUE)
  dataSource$NameClean <- gsub("-", "", dataSource$NameClean, ignore.case=TRUE)
  dataSource$NameClean <- gsub("\\+ ", "", dataSource$NameClean, ignore.case=TRUE)
  dataSource$NameClean <- gsub("\\+", "", dataSource$NameClean, ignore.case=TRUE)
  dataSource$NameClean <- gsub("  ", " ", dataSource$NameClean, ignore.case=TRUE)
  dataSource$NameClean <- gsub(paste(paste(" ", epithets," ",sep=""), collapse="|"), " ", dataSource$NameClean)
  
  ## Change the content in the Name and Author columns to uppercase. If there a hybrid sign (X) and space before a genus name, remove them.
  whichs <- which(grepl("^X ", dataSource$NameClean, ignore.case=TRUE))
  if(length(whichs)>0) dataSource$NameClean[whichs] <- gsub("^X ", "" , dataSource$NameClean[whichs])
  rm(whichs)
  whichs <- which(grepl("^x ", dataSource$NameClean, ignore.case=TRUE))
  if(length(whichs)>0) dataSource$NameClean[whichs] <- gsub("^x ", "" , dataSource$NameClean[whichs])
  rm(whichs)
  whichs <- which(grepl("\u00d7 ", dataSource$NameClean, ignore.case=TRUE))
  if(length(whichs)>0) dataSource$NameClean[whichs] <- gsub("\u00d7 ", "" , dataSource$NameClean[whichs])
  rm(whichs)
  whichs <- which(grepl("\u00d7", dataSource$NameClean, ignore.case=TRUE))
  if(length(whichs)>0) dataSource$NameClean[whichs] <- gsub("\u00d7", "" , dataSource$NameClean[whichs])
  rm(whichs)
  
  ##-------------- captial only the first word of genus names
  dataSource$NameClean <- tolower(dataSource$NameClean)
  substr(dataSource$NameClean, 1, 1) <- toupper(substr(dataSource$NameClean, 1, 1))
  
  ## In the Author column of both file, "fil." to "f." and change "Linn." to "L.".
  if(author==TRUE){
    whichs <- which(grepl(" fil\\.", dataSource$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>1) dataSource$AUTHOR[whichs] <- gsub(" fil\\.", " f." , dataSource$AUTHOR[whichs])
    rm(whichs)
    
    whichs <- which(grepl("Linn\\.", dataSource$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>1) dataSource$AUTHOR[whichs] <- gsub("Linn\\.", "L." , dataSource$AUTHOR[whichs])
    rm(whichs)
  }
  
  ## if the column "Genus" is missing, add one column "Genus"
  if(!"GENUS"%in%colnames(dataSource)){
    dataSource$NameClean[which(dataSource$NameClean=="")] <- "NONE"
    dataSource$NameClean[which(is.na(dataSource$NameClean==""))] <- "NONE"
    dataSource$GENUS <- strsplit(dataSource$NameClean, " ")%>%sapply(extract2, 1)
    dataSource$GENUS <- tolower(dataSource$GENUS)
    substr(dataSource$GENUS, 1, 1) <- toupper(substr(dataSource$GENUS, 1, 1))
    dataSource$GENUS[which(dataSource$GENUS%in%c("NONE","None"))] <- ""
    dataSource$NameClean[which(dataSource$GENUS=="")] <- ""
  }
  
  return(dataSource)
}
