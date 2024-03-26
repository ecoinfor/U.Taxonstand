#'Split the names with or without author names into the required format
#'
#' This function is used to format the input taxon names before running the function \code{\link[U.Taxonstand:nameMatch]{nameMatch}}.
#'
#' @param genuslist A character vector of the input genus names.
#'
#' @param splist A character vector of the input speices names.
#' 
#' @param taxon Select one specific taxon group to match. Currently, 'plant','fern','bird','mammal','amphibian','fish'.
#' 
#' @return A data frame with three or four columns: "sorter", "sp", "genus" and "family".
#'
#'@author Jian Zhang
#'
#'@examples
#'# genus names
#'familyMatch(genuslist=c("Aa","Pinus","Humbertodendron"), taxon="plant")
#'familyMatch(genuslist = c("Acanthocharax","Agosia","Alticorpus"),taxon="fish")
#'
#'# species names
#'familyMatch(splist=c("Aa xyz","Pinus xyz","Humbertodendron xyz"), taxon="plant")
#'familyMatch(splist = c("Acanthocharax xyz","Agosia xyz","Alticorpus xyz"),taxon="fish")
#'
#'@export
familyMatch <- function(genuslist=NULL, splist=NULL, taxon=c('plant','fern','bird','mammal','amphibian','fish')){
  
  if(!is.null(genuslist)){
    list01 <- data.frame(sorter=1:length(genuslist), genus=genuslist)
    if(taxon=='plant'){
      utils::data(genusFamily_Plants)
      res <- merge(list01, genusFamily_Plants, by="genus", all.x=TRUE)
    }
    
    if(taxon=='fern'){
      utils::data(genusFamily_Ferns)
      res <- merge(list01, genusFamily_Ferns, by="genus", all.x=TRUE)
    }
    
    if(taxon=='bird'){
      utils::data(genusFamily_Birds)
      res <- merge(list01, genusFamily_Birds, by="genus", all.x=TRUE)
    }
    
    if(taxon=='mammal'){
      utils::data(genusFamily_Mammals)
      res <- merge(list01, genusFamily_Mammals, by="genus", all.x=TRUE)
    }

    if(taxon=='amphibian'){
      utils::data(genusFamily_Amphibians)
      res <- merge(list01, genusFamily_Amphibians, by="genus", all.x=TRUE)
    }
    
    if(taxon=='fish'){
      utils::data(genusFamily_Fishes)
      res <- merge(list01, genusFamily_Fishes, by="genus", all.x=TRUE)
    }
    
    rm(list01)
    res <- res[order(res$sorter),]
    res <- res[,c(2,1,3)]
  }
  
  ## for species list
  if(!is.null(splist)){
    # add the column genus
    datTemp <- nameClean(splist)
  
    list01 <- data.frame(sorter=1:length(splist), sp=splist, genus=datTemp$GENUS)
    
    if(taxon=='plant'){
      utils::data(genusFamily_Plants)
      res <- merge(list01, genusFamily_Plants, by="genus", all.x=TRUE)
    }
    
    if(taxon=='fern'){
      utils::data(genusFamily_Ferns)
      res <- merge(list01, genusFamily_Ferns, by="genus", all.x=TRUE)
    }
    
    if(taxon=='bird'){
      utils::data(genusFamily_Birds)
      res <- merge(list01, genusFamily_Birds, by="genus", all.x=TRUE)
    }
    
    if(taxon=='mammal'){
      utils::data(genusFamily_Mammals)
      res <- merge(list01, genusFamily_Mammals, by="genus", all.x=TRUE)
    }
    
    if(taxon=='amphibian'){
      utils::data(genusFamily_Amphibians)
      res <- merge(list01, genusFamily_Amphibians, by="genus", all.x=TRUE)
    }
    
    if(taxon=='fish'){
      utils::data(genusFamily_Fishes)
      res <- merge(list01, genusFamily_Fishes, by="genus", all.x=TRUE)
    }
    
    rm(datTemp)
    rm(list01)
    res <- res[order(res$sorter),]
    res <- res[,c(2,3,4,1)]
  }

  return(res)
}
