#'List all the synonyms and accepted names for your input names
#'
#'NOTE that this function only works for the matched taxon names. Otherwise, you should use the function \code{\link[U.Taxonstand:nameMatch]{nameMatch}} to do the matching first.
#'
#' @param splist A character vector of the input taxon, e.g., "Hieracium aragonense Scheele" and "Pilosella X subulatissima (Zahn) Mateo".

#' @param spSource A data frame of the database with standarized taxon names. An example of data frame could be found in the example data 'databaseExample'. Multiple databases for plants and animals that can be directly used by U.Taxonstand are available online (https://github.com/nameMatch/Database). They include global taxonomic databases for bryophytes, vascular plants, amphibians, birds, fishes, mammals, reptile and others. You can creat your own database for name matching.
#' 
#' @return A data frame with the columns of all synonyms and accepted names.
#'
#'@author Jian Zhang
#'
#'@examples
#'data(databaseExample)
#'synSearch(splist="Isoetes tenella", spSource=databaseExample)
#'synSearch(splist=c("Isoetes tenella","Isoetes echinospora","Isoetes underwoodii L.F. Hend. Isoetes"), spSource=databaseExample)
#'
#'@export
synSearch <- function(splist, spSource){
  
  ## format the names first
  splist <- nameSplit(splist)
  splist <- nameClean(splist)
  
  ##--- the function for searching all related names for single species
  synSearch_ck <- function(sp){
    id_ck <- unique(c(spSource$ACCEPTED_ID[which(spSource$NameClean==sp)], spSource$ID[which(spSource$NameClean==sp)]))
    id_ck <- id_ck[which(id_ck!="")]
    id_ck <- id_ck[which(id_ck!=0)]
    
    if(length(id_ck)>0){
      sp_ck <- spSource[which(spSource$ID%in%id_ck | spSource$ACCEPTED_ID%in%id_ck),]
      sp_ck <- sp_ck[,-which(colnames(sp_ck)=="NameClean")]
      sp_ck$Submitted_Name <- splist$SUBMITTED_NAME_AUTHOR[which(splist$NameClean==sp)]
    }

    if(length(id_ck)==0){
      sp_ck <- spSource[1,] # randomly select one and change all values into NAs
      sp_ck[1,] <- NA
      sp_ck <- sp_ck[,-which(colnames(sp_ck)=="NameClean")]
      sp_ck$Submitted_Name <- splist$SUBMITTED_NAME_AUTHOR[which(splist$NameClean==sp)]      
    }
    
    return(sp_ck)    
  }
  
  ##--- For all species together
  result <- do.call("rbind", lapply(splist$NameClean, synSearch_ck))
  return(result)
}
