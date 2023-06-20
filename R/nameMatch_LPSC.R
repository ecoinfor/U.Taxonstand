#'The function for standardizing a list of input plant names using the Checklist of Plant Species in China (version 2023)
#'
#' Replacing synonyms by accepted names and removing orthographical errors in the raw names. This function is used to match with the Checklist of Plant Species in China (version 2023). The function was developed based on three databases of the R package LPSC.
#'
#' @param spList A data frame or a character vector specifying the input taxon. An example of data frame could be found in the example data 'spExample'.A character vector specifying the input taxa, each element including genus and specific epithet and, potentially, author name and infraspecific abbreviation and epithet.
#'
#' @param author Logical. If TRUE (default), the function tries to match author names from the input taxon and calculate the author distance.
#'
#' @param max.distance A number indicating the maximum distance allows for a match in \code{\link[base:agrep]{agrep}} when performing corrections of spelling errors in specific epithets.
#'
#' @param genusPairs Some genera have one or more variants in spelling (e.g. Euodia versus Evodia, Eccremis versus Excremis, Ziziphus versus Zizyphus). When a list of such genera is available, U.Taxonstand can use the information in the list as additional data to match names between the user’s species list and the taxonomic database. The data file should a dataframe with two columns (Genus01 and Genus02).
#'
#' @param Append Logical. If TRUE, the function will add other columns (e.g., geographic distribution and common names in different language) in the database into the final result.
#'
#' @return A data frame with the following columns: \itemize{
#'    \item{\emph{Submitted_Name}}{: Original taxon name as provided in input.}
#'    \item{\emph{Submitted_Author}}{: Original author name as provided in input.}
#'    \item{\emph{Submitted_Genus}}{: Original genus name as provided in input.}
#'    \item{\emph{Submitted_Rank}}{: Original taxonomic rank as provied in input.}
#'    \item{\emph{Name_in_database}}{: Matched latin name, extracted from the spSource.}
#'    \item{\emph{Author_in_database}}{: Matched author name, extracted from the spSource.}
#'    \item{\emph{Genus_in_database}}{: Matched genus name, extracted from the spSource.}
#'    \item{\emph{Rank_in_database}}{: Matched taxonomic rank of specific epithet.}
#'    \item{\emph{ID_in_database}}{: Matched ID, extracted from the spSource.}
#'    \item{\emph{Name_set}}{: Gives a rank based on the column Score. If you select the rows with Name_set = 1, only one of the 'best' matched names for each input taxon includes.}
#'    \item{\emph{Fuzzy}}{: ‘TRUE’ means the matching result is fully or partially based on fuzzy matching algorithm; ‘FALSE’ means the matching result is not based on fuzzy matching algorithm.}
#'    \item{\emph{Score}}{: Matching score (ranging from 1 to 0, when author of a scientific name is provided in user’s species list, or ranging from 0 to 0.8 when author of a scientific name is not provided). A larger value represents a better matching.}
#'    \item{\emph{name.dist}}{: The distance between Submitted_Name and Name_in_database.}
#'    \item{\emph{author.dist}}{: The distance between Submitted_Author and Author_in_database.}
#'    \item{\emph{New_name}}{: The accepted name in the spSource.In the case that this column is empty and the column Score has a value > 0, the matched name is treated as an accepted name in the database. In the case that the matched name is treated as a synonym in the database, the name shown in this column is the accepted name of the synonym based on the database. For a name treated as an unresolved name or as a synonym whose accepted name cannot be identified on the database, the text “[Accepted name needs to be determined]” is shown in this column.}
#'    \item{\emph{New_author}}{: Authority of the name in the column New_name based on the database.}
#'    \item{\emph{New_ID}}{: ID of the name in the column New_name based on the database.}
#'    \item{\emph{Family}}{: Family name, extracted from the spSource.}
#'    \item{\emph{Name_spLev}}{: If the input taxon name cannot be matched at the same rank level, the species-level matching name shows here.}
#'    \item{\emph{Accepted_SPNAME}}{: If the name in the column “Submitted_Name” is matched with a name in the database, either as an accepted name or a synonym, the species name of the accepted name of the matched name will be listed here.}
#'    \item{\emph{NOTE}}{: This column contains some notes, e.g. no matching or multiple matching results for a given name, or only matching at species level for a trinomial name.}
#'}
#'
#'@references Zhang, J. (2023). LPSC: Tools for searching List of plant species in China. R package version 0.8.1, https://github.com/helixcn/LPSC.
#'
#'@import magrittr
#'@import plyr
#'
#'@examples
#'## load the database
#'data(databaseExample)
#'
#'## The input names as a character vector
#'nameMatch_LPSC(spList="Cyclobalanopsis myrsinifolia (Blume) Oerst.", Append=FALSE)
#'nameMatch_LPSC(spList=c("Cyclobalanopsis myrsinifolia (Blume) Oerst.","Cyclobalanopsis myrsinifolium","Cyclobalanopsis mrrsinifolia","Cyclobalamopsis mrrsinifolia"), Append=TRUE)
#'
#'## Using the additional data of genus pairs for fuzzy matching of genus names
#'data(genusPairs_Plants)
#'nameMatch_LPSC(spList=c("Cyclobalanopsis myrsinifolia (Blume) Oerst.","Cyclobalanopsis myrsinifolium","Cyclobalanopsis mrrsinifolia","Cyclobalamopsis myrsinifolia","Evodia chaffanjonii","Evodia lyi","Euodia lyi"),genusPairs=genusPairs_Plants, Append=TRUE)
#'
#'
#'@export
nameMatch_LPSC <- function(spList=NULL, author = TRUE, max.distance= 1, genusPairs=NULL, Append=TRUE)
{
  ################################################
  ################  The main  function for name matching
  
  ################################################
  if(!is.data.frame(spList)) spList <- nameSplit(splist=spList)
  
  ## to standize the colunm names. For example, change "name" to "Name", "sorter" to "Sorter"
  colnames(spList) <- toupper(colnames(spList))
  
  ## add the column "SORTER" if missing
  if(!"SORTER"%in%colnames(spList)) spList$SORTER <- 1:nrow(spList)
  
  ##------------	convert the data from R package LPSC into the required data format for spSource
  if (!require("LPSC")) devtools::install_github("helixcn/LPSC")
  spSource <- dat_all_sp2023[,c(3,5,16,6,2,23,7,9)]
  
  # add the FAMILY for all species and other information for accepted species names
  spSource <- merge(spSource, unique(dat_all_accepted_sp2023[,c("family_id","family","family_c","kingdom","kingdom_c","phylum","phylum_c","class","class_c","order","order_c")]), by="family_id", all.x=TRUE)
  
  # add IUCN status and the China Biodiversity Red List (2020)
  colnames(dat_CBRL2020_higher_plants)[5] <- "canonical_name"
  spSource <- merge(spSource, dat_CBRL2020_higher_plants[,5:9], by="canonical_name", all.x=TRUE)
  
  spSource <- spSource[,c(3,1,4,5,6,9,7,8,10:22)]
  colnames(spSource)[1:6] <- c("ID", "Name", "Author", "Genus", "ACCEPTED_ID","FAMILY")
  colnames(spSource) <- toupper(colnames(spSource))
  spSource$ACCEPTED_ID[which(spSource$ID==spSource$ACCEPTED_ID)] <- NA
    
  ##------------	check the data formats
  if(!is.data.frame(spSource)) stop("The source database is not a data frame")
  if(!"NAME"%in%colnames(spSource)) stop("Please check if the source database has the column 'NAME'")
  if(author==TRUE & !"AUTHOR"%in%colnames(spSource))stop("Please check if the source database has the column 'AUTHOR'")
  
  if(!"NAME"%in%colnames(spList)) stop("Please check if your spList has the column 'NAME'")
  if(author==TRUE & !"AUTHOR"%in%colnames(spList))stop("Please check if your spList has the column 'AUTHOR'")
  
  if(!"ID"%in%colnames(spSource)) spSource$ID <- NA
  if(!"ACCEPTED_ID"%in%colnames(spSource)) spSource$ACCEPTED_ID <- NA
  if(!"FAMILY"%in%colnames(spSource)) spSource$FAMILY <- NA
  if(author==TRUE & length(unique(spList$AUTHOR))==1){
    if(is.na(unique(spList$AUTHOR))|unique(spList$AUTHOR)=="") author=FALSE	
  }
  
  ##------------	using the R function nameMatch for name matching
  res <- nameMatch(spList=spList, spSource=spSource, author = author, max.distance= max.distance, genusPairs=genusPairs, Append=Append)
  
  ## return the result
  return(res)
}
