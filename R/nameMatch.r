#'The main function for standardizing a list of input taxon
#'
#' Replacing synonyms by accepted names and removing orthographical errors in the raw names
#'
#' @param spList A data frame or a character vector specifying the input taxon. An example of data frame could be found in the example data 'spExample'.A character vector specifying the input taxa, each element including genus and specific epithet and, potentially, author name and infraspecific abbreviation and epithet.
#'
#' @param spSource A data frame of the database with standarized taxon names. An example of data frame could be found in the example data 'databaseExample'. Multiple databases for plants and animals that can be directly used by U.Taxonstand are available online (https://github.com/nameMatch/Database). They include global taxonomic databases for bryophytes, vascular plants, amphibians, birds, fishes, mammals, and reptiles. Global databases for other taxon groups of organisms may be placed on the website in future.
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
#'@author Jian Zhang & Hong Qian
#'
#'@references Zhang, J. & Qian, H. (2022). U.Taxonstand: An R package for standardizing scientific names of plants and animals. Plant Ecology, in press.
#'
#'@import magrittr
#'@import plyr
#'
#'@examples
#'## load the database
#'data(databaseExample)
#'
#'## The input names as a character vector
#'sps <- c("Syntoma comosum (L.) Dalla Torre & Sarnth.", "Turczaninowia fastigiata (Fisch.) DC.",
#'"Zizyphora abd-el-asisii Hand.-Mazz.")
#'nameMatch(spList=sps, spSource=databaseExample, author = TRUE, max.distance= 1)
#'
#'## The input names as a data frame
#'data(spExample)
#'res <- nameMatch(spList=spExample, spSource=databaseExample, author = TRUE, max.distance= 1)
#'head(res)
#'
#'## Using the additional data of genus pairs for fuzzy matching of genus names
#'data(spExample)
#'data(genusPairs_Plants)
#'res <- nameMatch(spList=spExample, spSource=databaseExample, author = TRUE, max.distance= 1, 
#'genusPairs=genusPairs_Plants)
#'head(res)
#'
#'## Species name matching for bird species (Not run)
#'# load the formatted ITIS Aves database; the formatted database can be downloaded here:
#'# https://github.com/nameMatch/Database
#'# require(openxlsx)
#'# databaseAves <- read.xlsx("Birds_ITIS_database.xlsx")
#'# nameMatch(spList=c("Hieraaetus fasciata","Merops leschenaultia","Egretta sacra",
#'# "Sturnia philippensis","Phoenicurus caeruleocephala","Enicurus maculates",
#'# "Orthotomus cucullatus","Phalacrocorax carbo"),
#'# spSource=databaseAves, author = FALSE, max.distance= 1)
#'
#'## Adding other information in the database into the final result (Not run)
#'# sps <- c("Syntoma comosum (L.) Dalla Torre & Sarnth.", "Turczaninowia fastigiata (Fisch.) DC.",
#'# "Zizyphora abd-el-asisii Hand.-Mazz.")
#'# nameMatch(spList=sps, spSource=China_Plants_SP2000_2022Edition, author = TRUE, max.distance= 1,
#'# genusPairs=genusPairs_Plants, Append=TRUE)
#'# NOTE: The raw data "China_Plants_SP2000_2022Edition" can be downloaded here:
#'# https://www.plantplus.cn/doi/10.12282/plantdata.0061;
#'# the formatted database "Plants_SP2000_2022Edition_China" can be downloaded here:
#'# https://github.com/nameMatch/Database
#'
#'@export
nameMatch <- function(spList=NULL, spSource=NULL, author = TRUE, max.distance= 1, genusPairs=NULL, Append=FALSE)
{
  ################################################
  ################  The main  function for name matching
  
  ################################################
  if(!is.data.frame(spList)) spList <- nameSplit(splist=spList)
  
  ## to standize the colunm names. For example, change "name" to "Name", "sorter" to "Sorter"
  colnames(spList) <- toupper(colnames(spList))
  colnames(spSource) <- toupper(colnames(spSource))
  
  ## add the column "SORTER" if missing
  if(!"SORTER"%in%colnames(spList)) spList$SORTER <- 1:nrow(spList)
  
  ##------------	check the data formats
  if(!is.data.frame(spSource)) stop("The source database is not a data frame")
  if(!"NAME"%in%colnames(spSource)) stop("Please check if the source database has the column 'NAME'")
  if(author==TRUE & !"AUTHOR"%in%colnames(spSource))stop("Please check if the source database has the column 'AUTHOR'")
  
  if(!"NAME"%in%colnames(spList)) stop("Please check if your spList has the column 'NAME'")
  if(author==TRUE & !"AUTHOR"%in%colnames(spList))stop("Please check if your spList has the column 'AUTHOR'")
  
  if(!"ID"%in%colnames(spSource)) spSource$ID <- NA
  if(!"ACCEPTED_ID"%in%colnames(spSource)) spSource$ACCEPTED_ID <- NA
  if(!"FAMILY"%in%colnames(spSource)) spSource$FAMILY <- NA
  
  ##------------	
  epithets <- c("var.","f.","ssp.","grex","nothossp.","prol.","gama","lus.","monstr.","race","nm","subvar.","subf.", "X", "\u00d7", "subprol.","cv.", "-", "var", "f", "fo", "fo.", "form", "forma", "forma.", "x", "ssp", "subsp.", "subsp", "cv", "cultivar.", "cultivar", "nothossp", "nothosubsp.", "nothosubsp", "prol", "proles.", "proles", "grex.", "gama.", "lusus", "lusus.", "lus","monstr","race.","nm.","subvar","subf","subfo","subfo.","subform.","subform","subprol","subproles.","subproles")
  
  ##------------
  print("Loading and processing the database...")
  
  if(!"NAMECLEAN"%in%colnames(spSource)){
    spSource$NAMECLEAN <- spSource$NAME
    spSource$NAMECLEAN <- gsub(paste0("\\s+|", intToUtf8(160)), " ", as.character(spSource$NAMECLEAN))
    spSource$NAMECLEAN <- gsub("(?! )\\(", " \\(", spSource$NAMECLEAN, perl = TRUE)
    spSource$NAMECLEAN <- gsub("\\-", "", spSource$NAMECLEAN, ignore.case=TRUE)
    spSource$NAMECLEAN <- gsub("\\+ ", "", spSource$NAMECLEAN, ignore.case=TRUE)
    spSource$NAMECLEAN <- gsub("\\+", "", spSource$NAMECLEAN, ignore.case=TRUE)
    spSource$NAMECLEAN <- gsub("  ", " ", spSource$NAMECLEAN, ignore.case=TRUE)
    spSource$NAMECLEAN <- gsub(paste(paste(" ", epithets," ",sep=""), collapse="|"), " ", spSource$NAMECLEAN, ignore.case=TRUE)
    
    # do it agagin to deal with this kind of case "Rubus gothicus var. X gratiformis"
    spSource$NAMECLEAN <- gsub(paste(paste(" ", epithets," ",sep=""), collapse="|"), " ", spSource$NAMECLEAN, ignore.case=TRUE)
    
    ## If there a hybrid sign (X / x / "\u00d7") and space before a genus name, remove them.
    whichs <- which(grepl("^X ", spSource$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spSource$NAMECLEAN[whichs] <- gsub("^X ", "" , spSource$NAMECLEAN[whichs])
    rm(whichs)	
    whichs <- which(grepl("^x ", spSource$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spSource$NAMECLEAN[whichs] <- gsub("^x ", "" , spSource$NAMECLEAN[whichs])
    rm(whichs)
    whichs <- which(grepl("\u00d7 ", spSource$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spSource$NAMECLEAN[whichs] <- gsub("\u00d7 ", "" , spSource$NAMECLEAN[whichs])
    rm(whichs)
    whichs <- which(grepl("\u00d7", spSource$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spSource$NAMECLEAN[whichs] <- gsub("\u00d7", "" , spSource$NAMECLEAN[whichs])
    rm(whichs)
    
    ## Remove some non-letter symbols at the beginning
    for(j in 1:100){
      whichs <- which(grepl("^[^A-Za-z]", spSource$NAMECLEAN, ignore.case=TRUE))
      if(length(whichs)>0) spSource$NAMECLEAN[whichs] <- gsub("^[^A-Za-z]", "", spSource$NAMECLEAN[whichs])
      whichs <- which(grepl("^[^A-Za-z]", spSource$NAMECLEAN, ignore.case=TRUE))
      if(length(whichs)==0) break
    }
    rm(whichs,j)
    
    ## format the NAMECLEAN
    spSource$NAMECLEAN <- tolower(spSource$NAMECLEAN)
    substr(spSource$NAMECLEAN, 1, 1) <- toupper(substr(spSource$NAMECLEAN, 1, 1))
  }
  
  if(!"NAMECLEAN"%in%colnames(spList)){
    spList$NAMECLEAN <- spList$NAME
    spList$NAMECLEAN <- gsub(paste0("\\s+|", intToUtf8(160)), " ", as.character(spList$NAMECLEAN))
    spList$NAMECLEAN <- gsub("(?! )\\(", " \\(", spList$NAMECLEAN, perl = TRUE)
    spList$NAMECLEAN <- gsub("-", "", spList$NAMECLEAN, ignore.case=TRUE)
    spList$NAMECLEAN <- gsub("\\+ ", "", spList$NAMECLEAN, ignore.case=TRUE)
    spList$NAMECLEAN <- gsub("\\+", "", spList$NAMECLEAN, ignore.case=TRUE)
    spList$NAMECLEAN <- gsub("  ", " ", spList$NAMECLEAN, ignore.case=TRUE)
    spList$NAMECLEAN <- gsub(paste(paste(" ", epithets," ",sep=""), collapse="|"), " ", spList$NAMECLEAN, ignore.case=TRUE)
    
    # do it agagin to deal with this kind of case "Rubus gothicus var. X gratiformis"
    spList$NAMECLEAN <- gsub(paste(paste(" ", epithets," ",sep=""), collapse="|"), " ", spList$NAMECLEAN, ignore.case=TRUE)
    
    ## If there a hybrid sign (X) and space before a genus name, remove them.
    whichs <- which(grepl("^X ", spList$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spList$NAMECLEAN[whichs] <- gsub("^X ", "", spList$NAMECLEAN[whichs])
    rm(whichs)
    whichs <- which(grepl("^x ", spList$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spList$NAMECLEAN[whichs] <- gsub("^x ", "", spList$NAMECLEAN[whichs])
    rm(whichs)
    whichs <- which(grepl("\u00d7 ", spList$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spList$NAMECLEAN[whichs] <- gsub("\u00d7 ", "", spList$NAMECLEAN[whichs])
    rm(whichs)
    whichs <- which(grepl("\u00d7", spList$NAMECLEAN, ignore.case=TRUE))
    if(length(whichs)>0) spList$NAMECLEAN[whichs] <- gsub("\u00d7", "", spList$NAMECLEAN[whichs])
    rm(whichs)
    
    ## Remove some non-letter symbols at the beginning
    for(j in 1:100){
      whichs <- which(grepl("^[^A-Za-z]", spList$NAMECLEAN, ignore.case=TRUE))
      if(length(whichs)>0) spList$NAMECLEAN[whichs] <- gsub("^[^A-Za-z]", "", spList$NAMECLEAN[whichs])
      whichs <- which(grepl("^[^A-Za-z]", spList$NAMECLEAN, ignore.case=TRUE))
      if(length(whichs)==0) break
    }
    rm(whichs,j)
    
    ## format the NAMECLEAN
    spList$NAMECLEAN <- tolower(spList$NAMECLEAN)
    substr(spList$NAMECLEAN, 1, 1) <- toupper(substr(spList$NAMECLEAN, 1, 1))
  }
  
  ## In the AUTHOR column of both file, change “fil.” to “f.” and change “Linn.” to “L.”.
  if(author==TRUE){
    whichs <- which(grepl(" fil\\.", spSource$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>0) spSource$AUTHOR[whichs] <- gsub(" fil\\.", " f." , spSource$AUTHOR[whichs])
    rm(whichs)
    
    whichs <- which(grepl("Linn\\.", spSource$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>0) spSource$AUTHOR[whichs] <- gsub("Linn\\.", "L." , spSource$AUTHOR[whichs])
    rm(whichs)
    
    whichs <- which(grepl(" fil\\.", spList$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>0) spList$AUTHOR[whichs] <- gsub(" fil\\.", " f." , spList$AUTHOR[whichs])
    rm(whichs)
    
    whichs <- which(grepl("Linn\\.", spList$AUTHOR, ignore.case=TRUE))
    if(length(whichs)>0) spList$AUTHOR[whichs] <- gsub("Linn\\.", "L." , spList$AUTHOR[whichs])
    rm(whichs)
  }
  
  
  ## add the column "Genus" if missing
  if(!"GENUS"%in%colnames(spSource)){
    splitName_spSource <- strsplit(spSource$NAMECLEAN, " ")
    spSource$GENUS <- suppressWarnings(splitName_spSource %>% sapply(magrittr::extract2, 1))
  }
  
  if(!"GENUS"%in%colnames(spList)){
    splitName_spList <- strsplit(spList$NAMECLEAN, " ")
    spList$GENUS <- suppressWarnings(strsplit(spList$NAMECLEAN, " ") %>% sapply(magrittr::extract2, 1))
  }
  
  ## add the column "Rank" if missing
  if(!"RANK"%in%colnames(spSource)){
    if(!exists("splitName_spSource")) splitName_spSource <- strsplit(spSource$NAMECLEAN, " ")
    spSource$RANK <- unlist(lapply(splitName_spSource, length))
  }
  
  if(!"RANK"%in%colnames(spList)){
    if(!exists("splitName_spList")) splitName_spList <- strsplit(spList$NAMECLEAN, " ")
    spList$RANK <- unlist(lapply(splitName_spList, length))
  }
  
  ## some minor corrections in the column "ACCEPTED_ID"
  if(!"ACCEPTED_ID"%in%colnames(spSource)) spSource$ACCEPTED_ID <- NA
  spSource$ACCEPTED_ID[which(spSource$ACCEPTED_ID==0)] <- NA
  spSource$ACCEPTED_ID[which(spSource$ACCEPTED_ID=="")] <- NA
  
  ##------------	To directly match "NAME" including in "spSource"
  # the species to directly match with spSource
  spList00 <- spList[which(spList$NAME%in%spSource$NAME),]
  if(nrow(spList00)>0){
    spList00 <- spList00[,which(colnames(spList00)%in%c("NAME","AUTHOR","RANK","NAMECLEAN","GENUS","SORTER"))]
    colnames(spList00)[which(colnames(spList00)=="NAME")] <- "Submitted_Name"
    colnames(spList00)[which(colnames(spList00)=="AUTHOR")] <- "Submitted_Author"
    colnames(spList00)[which(colnames(spList00)=="RANK")] <- "Submitted_Rank"
    colnames(spList00)[which(colnames(spList00)=="GENUS")] <- "Submitted_Genus"
    
    spSource00 <- spSource[which(spSource$NAME%in%spList00$Submitted_Name),]
    colnames(spSource00)[which(colnames(spSource00)=="NAME")] <- "Name_in_database"
    colnames(spSource00)[which(colnames(spSource00)=="AUTHOR")] <- "Author_in_database"
    colnames(spSource00)[which(colnames(spSource00)=="GENUS")] <- "Genus_in_database"
    colnames(spSource00)[which(colnames(spSource00)=="RANK")] <- "Rank_in_database"
    colnames(spSource00)[which(colnames(spSource00)=="ID")] <- "ID_in_database"
    
    res00 <- merge(spList00, spSource00, by="NAMECLEAN",all.x=TRUE)
    rm(spSource00)
    
    res00$Fuzzy <- FALSE
    res00$NOTE <- NA
    res00$Name_spLev <- NA
    
    res00 <- res00[,c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")]
  }
  rm(spList00)
  
  ##------------	To directly match the NAMECLEAN including in "spSource"
  # the species to directly match with spSource
  spList01 <- spList[which(spList$NAMECLEAN%in%spSource$NAMECLEAN & !spList$NAME%in%spSource$NAME),]
  if(nrow(spList01)>0){
    spList01 <- spList01[,which(colnames(spList01)%in%c("NAME","AUTHOR","RANK","NAMECLEAN","GENUS","SORTER"))]
    colnames(spList01)[which(colnames(spList01)=="NAME")] <- "Submitted_Name"
    colnames(spList01)[which(colnames(spList01)=="AUTHOR")] <- "Submitted_Author"
    colnames(spList01)[which(colnames(spList01)=="RANK")] <- "Submitted_Rank"
    colnames(spList01)[which(colnames(spList01)=="GENUS")] <- "Submitted_Genus"
    
    spSource01 <- spSource[which(spSource$NAMECLEAN%in%spList01$NAMECLEAN),]
    colnames(spSource01)[which(colnames(spSource01)=="NAME")] <- "Name_in_database"
    colnames(spSource01)[which(colnames(spSource01)=="AUTHOR")] <- "Author_in_database"
    colnames(spSource01)[which(colnames(spSource01)=="GENUS")] <- "Genus_in_database"
    colnames(spSource01)[which(colnames(spSource01)=="RANK")] <- "Rank_in_database"
    colnames(spSource01)[which(colnames(spSource01)=="ID")] <- "ID_in_database"
    
    res01 <- merge(spList01, spSource01, by="NAMECLEAN",all.x=TRUE)
    rm(spSource01)
    
    res01$Fuzzy <- FALSE
    res01$NOTE <- NA
    res01$Name_spLev <- NA
    
    res01 <- res01[,c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")]
  }
  rm(spList01)
  
  if(exists("res00") & exists("res01")) res01 <- rbind(res00, res01)
  if(exists("res00") & !exists("res01")) res01 <- res00
  if(exists("res00")) rm(res00)
  
  ##------------------------------------------------
  ##------------------------------------------------
  # the species that cannot be directly matched with spSource
  spSource$GENUS00 <- toupper(gsub("-", "", spSource$GENUS, ignore.case=TRUE))
  
  whichs <- unique(c(which(spList$NAMECLEAN%in%spSource$NAMECLEAN),which(spList$NAME%in%spSource$NAME)))
  if(length(whichs)>0) spList02 <- spList[-whichs,]
  if(length(whichs)==0) spList02 <- spList
  rm(whichs)
  
  print(paste(nrow(spList02), ifelse(nrow(spList02)>1," names (", " name ("), round(nrow(spList02)/nrow(spList)*100,2), "%) that need to do fuzzy matching", sep=""))
  
  if(nrow(spList02)>0){
    spList02$GENUS00 <- toupper(gsub("-", "", spList02$GENUS, ignore.case=TRUE))
    
    ##------------------------------------------------
    ##------------------------------------------------
    ##--- If the genus names don't match or have some similar genus names, try to make some corrections first
    genusList <- unique(spList02$GENUS00)
    genusRepl <- setdiff(unique(genusList), spSource$GENUS00)
    
    ## This part only works for plants.
    if(length(genusRepl)>0){
      #--- To match with the data file "lista", which is from the R package Taxonstand
      utils::data(lista)
      
      #--- This function is from the R package Taxonstand
      row.fn <- function(columna, error, key, lista){
        for (i in 1:length(lista[, columna])) {
          dat = utils::adist(key, trimws(lista[i, columna])) <= 
            error
          if ((lista[i, columna]) == "") 
            break
          if (dat == TRUE) 
            return(paste(lista[i, columna]))
        }
        return("")
      }
      
      genusSim <- c()
      for(i in 1:length(genusRepl)){
        # print(i)
        genero <- paste(genusRepl[i])
        letra1 <- toupper(substr(genero, 1, 1))
        letra2 <- tolower(substr(genero, 2, 2))
        genero <- paste(toupper(substr(genero, 1, 1)), tolower(substr(genero, 2, nchar(genero))), sep = "")
        resultado <- tryCatch(trimws(row.fn(letra1, 0, genero, lista)), error = function(e) NULL)
        
        if(!is.null(resultado)){
          if (resultado[1] == "" && sum(utils::adist(genero, trimws(lista[, letra1])) <= 1) > 1 || sum(utils::adist(genero, trimws(lista[, letra2])) <= 1) > 1) {
            resultado <- genusRepl[i]
          }
          
          if (resultado[1] == "") {
            resultado <- row.fn(letra1, 1, genero, lista)
          }
          
          if (resultado[1] == "") {
            resultado <- row.fn(letra2, 1, genero, lista)
          }
          
          if(length(resultado)==1) genusSim[i] <- resultado
          rm(letra1, genero,letra2)
        }
        
        if(is.null(resultado)) genusSim[i] <- NA
        rm(resultado)
      }
      
      genusPairsFinal <- data.frame(GENUS01=genusRepl, GENUS02=genusSim)
      rm(row.fn, genusRepl,genusSim)
    }
    
    ##--------------------------------
    ## This part uses to add some similar genus pairs for further matching. It works for any taxon group, if there is a data file "genusPairs" provided.
    if(!is.null(genusPairs)){
      ## merge genusPairsFinal with the genusPairs
      colnames(genusPairs) <- toupper(colnames(genusPairs))
      genusPairs$GENUS01 <- toupper(genusPairs$GENUS01)
      genusPairs$GENUS02 <- toupper(genusPairs$GENUS02)
      
      if(exists("genusPairsFinal")) genusPairsFinal <- rbind(genusPairsFinal, genusPairs)
      
      if(!exists("genusPairsFinal")) genusPairsFinal <- genusPairs
      
      if(exists("genusPairsFinal")){
        genusPairsFinal$GENUS01 <- trimws(toupper(genusPairsFinal$GENUS01))
        genusPairsFinal$GENUS02 <- trimws(toupper(genusPairsFinal$GENUS02))
        genusPairsFinal$GENUS01 <- gsub("-", "", genusPairsFinal$GENUS01, ignore.case=TRUE)
        genusPairsFinal$GENUS02 <- gsub("-", "", genusPairsFinal$GENUS02, ignore.case=TRUE)
        
        whichs <- unique(c(which(genusPairsFinal$GENUS01==""),which(genusPairsFinal$GENUS02==""), which(genusPairsFinal$GENUS01==genusPairsFinal$GENUS02)))
        
        if(length(whichs)>0) genusPairsFinal <- genusPairsFinal[-whichs,]
        rm(whichs)
        
        genusPairsFinal <- unique(genusPairsFinal)
        
        whichs <- unique(c(which(genusPairsFinal$GENUS01%in%spList02$GENUS00), which(genusPairsFinal$GENUS02%in%spList02$GENUS00)))
        if(length(whichs)>0) genusPairsFinal <- genusPairsFinal[whichs,]
        rm(whichs)	
        
        ##-----------------------------
        spList02 <- merge(spList02, genusPairsFinal, by.x="GENUS00",by.y="GENUS01", all.x=TRUE)
        spList02 <- merge(spList02, genusPairsFinal, by.x="GENUS00",by.y="GENUS02", all.x=TRUE)
        
        whichs <- which(!is.na(spList02$GENUS02))
        if(length(whichs)>0){
          temp01 <- spList02[whichs,]
          temp01$GENUS00 <- temp01$GENUS02
        }
        rm(whichs)
        
        whichs <- which(!is.na(spList02$GENUS01))
        if(length(whichs)>0){
          temp02 <- spList02[whichs,]
          temp02$GENUS00 <- temp02$GENUS01
        }
        rm(whichs)
        
        if(exists("temp01")) spList02 <- rbind(spList02, temp01)
        if(exists("temp02")) spList02 <- rbind(spList02, temp02)
        spList02 <- unique(spList02[,-which(colnames(spList02)%in%c("GENUS01","GENUS02"))])
      }
    }
    
    ## 
    spList02$GENUS00 <- tolower(spList02$GENUS00)
    substr(spList02$GENUS00, 1, 1) <- toupper(substr(spList02$GENUS00, 1, 1))
    whichs <- which(spList02$GENUS00!=spList02$GENUS)
    if(length(whichs)>0){
      for(i in 1:length(whichs)){
        spList02$NAMECLEAN[whichs[i]] <- gsub(spList02$GENUS[whichs[i]], spList02$GENUS00[whichs[i]], spList02$NAMECLEAN[whichs[i]])
      }
    }
    rm(whichs)
  }
  
  spList02 <- spList02[order(spList02$SORTER),]
  
  ##------------------------------------------------
  ##------------	The function for using lapply or pblapply
  nameMatch_ck2 <- function(d){
    a <- NULL
    counter <- 0
    a <- try(nameMatch_ck(spData=d, spSource=spSource, author=author, max.distance=max.distance), silent = FALSE)
    while (class(a) == "try-error" && counter < 6) {
      a <- try(nameMatch_ck(spData=d, spSource=spSource, author=author,max.distance = max.distance), silent = TRUE)
      counter <- counter + 1
    }
    while (class(a) == "try-error") {
      a <- data.frame(
        Submitted_Name_Author=d,
        Name_in_database=NA,
        Author_in_database=NA,
        Genus_in_database=NA,
        Rank_in_database=NA,
        ID_in_database=NA,
        NOTE=NA,
        Name_spLev=NA,
        ACCEPTED_ID=NA,
        FAMILY=NA,
        NAMECLEAN=NA,
        stringsAsFactors = FALSE)
    }
    invisible(a)
  }
  
  ##------------------------------------------------
  if(nrow(spList02)>0){
    if(author==TRUE) spData_New <- unique(paste(spList02$NAMECLEAN, spList02$AUTHOR, sep="#"))
    if(author==FALSE) spData_New <- unique(spList02$NAMECLEAN)
    
    if(length(spData_New) < 10){
      res02 <- do.call("rbind", lapply(spData_New, nameMatch_ck2))
    }
    else {
      if(!requireNamespace("pbapply")) utils::install.packages("pbapply")
      op <- pbapply::pboptions()
      pbapply::pboptions(type = "txt")
      res02 <- do.call("rbind", pbapply::pblapply(spData_New, 
                                                  nameMatch_ck2))
      pbapply::pboptions(op)
    }
    
    ##------------------------------------------
    ##-------------- merge the results into one file
    if(author==TRUE) spList02$Submitted_Name_Author <- paste(spList02$NAMECLEAN, spList02$AUTHOR, sep="#")
    if(author==FALSE) spList02$Submitted_Name_Author <- spList02$NAMECLEAN
    spList02 <- spList02[,which(colnames(spList02)%in%c("Submitted_Name_Author","NAME","AUTHOR","RANK","GENUS","SORTER"))]
    res02 <- merge(res02, spList02, by="Submitted_Name_Author", all.x=TRUE)
    rm(spList02)
  }
  
  ##------------------------------------------------
  if(exists("res01") & exists("res02")){
    res02$Fuzzy <- TRUE
    res02 <- res02[,c("SORTER","NAME","AUTHOR","GENUS","RANK","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")]
    colnames(res02) <- c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")
    res02 <- unique(res02)
    res <- rbind(res01,res02)
  }
  
  if(!exists("res02")) res <- res01
  if(!exists("res01")){
    res02$Fuzzy <- TRUE
    res02 <- res02[,c("SORTER","NAME","AUTHOR","GENUS","RANK","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")]
    colnames(res02) <- c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","ACCEPTED_ID","FAMILY")
    res <- unique(res02)
  }
  
  # if(exists("res01")) rm(res01)
  # if(exists("res02")) rm(res02)
  
  res <- unique(res)
  res$Fuzzy[which(res$Name_in_database==res$Submitted_Name & !is.na(res$Name_in_database))] <- FALSE
  
  ## for some special case like "Davallia friederici et pauli", its matching name is "Davallia friderici-et-pauli"
  whichs <- which(res$Submitted_Rank==2 & res$NOTE=="Matching at species level")
  if(length(whichs)>0){
    res$NOTE[whichs] <- NA
    res$Name_in_database[whichs] <- res$Name_spLev[whichs]
    res$Name_spLev[whichs] <- NA
    for(i in 1:length(whichs)){
      res$Author_in_database[whichs[i]] <- unique(spSource$AUTHOR[which(spSource$NAME==res$Name_in_database[whichs[i]])])[1]
      res$Genus_in_database[whichs[i]] <- unique(spSource$GENUS[which(spSource$NAME==res$Name_in_database[whichs[i]])])[1]
      res$Rank_in_database[whichs[i]] <- unique(spSource$RANK[which(spSource$NAME==res$Name_in_database[whichs[i]])])[1]
      res$ID_in_database[whichs[i]] <- unique(spSource$ID[which(spSource$NAME==res$Name_in_database[whichs[i]])])[1]
      res$FAMILY[whichs[i]] <- unique(spSource$FAMILY[which(spSource$NAME==res$Name_in_database[whichs[i]])])[1]
    }
    rm(i, whichs)
  }
  
  ## calculate the distance of the Author names and the distance of the names
  res$name.dist <- NA
  res$author.dist <- NA
  for(i in 1:nrow(res)){
    res$name.dist[i] <- as.numeric(utils::adist(res$Submitted_Name[i], y = res$Name_in_database[i]))
    
    if(author==TRUE) res$author.dist[i] <- as.numeric(utils::adist(res$Submitted_Author[i], y = res$Author_in_database[i]))
  }
  rm(i)
  
  ## give a matching score based on name.dist and author.dist
  ## give a weight of 80% for name.dist and 20% for author.dist
  res$Score <- NA
  score01 <- 80-res$name.dist*5
  score01[which(score01<0)] <- 0
  if(author==TRUE){
    score02 <- 20-res$author.dist*1
    score02[which(score02<0)] <- 0
    score02[which(res$Submitted_Author=="" | is.na(res$Submitted_Author) | is.na(res$Author_in_database) | res$Author_in_database=="")] <- 0
  }
  if(author==FALSE) score02 <- 0
  res$Score <- (score01 + score02)/100
  rm(score01, score02)
  
  ## remove multiple results but with the ones with no Score
  tst01 <- table(res$SORTER)
  tst01 <- data.frame(SORTER=names(tst01), val1=as.numeric(tst01))
  tst02 <- table(res$SORTER[!is.na(res$Score)])
  tst02 <- data.frame(SORTER=names(tst02), val2=as.numeric(tst02))
  if(nrow(tst02)>0){
    tst <- merge(tst01,tst02, by="SORTER", all.xy=TRUE)
    tst$val1[is.na(tst$val1)] <- 0
    tst$val2[is.na(tst$val2)] <- 0
    tst$dif <- abs(tst$val1-tst$val2)
    tst <- tst$SORTER[which(tst$dif>0)]
    if(length(tst)>0) res <- res[-which(res$SORTER%in%tst & is.na(res$Score)),]
    rm(tst)
  }
  rm(tst01,tst02)
  
  ## remove multiple results with name.dist=0, but different author.dist (only keep the one with short distance)
  tst <- table(res$SORTER)
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0) coco <- unique(res$SORTER[which(res$name.dist==0 & res$SORTER%in%tst)])
  rm(tst)
  if(exists("coco")){
    if(length(coco)>0){
      for(i in 1:length(coco)){
        which_i <- which(res$SORTER==coco[i] & res$author.dist>min(res$author.dist[which(res$SORTER==coco[i])]))
        if(length(which_i)>0) res <- res[-which_i,]
        rm(which_i)
      }
    }
    rm(coco)
  }
  
  ## remove multiple results with name.dist>2, if name.dist<=2 exists
  tst <- table(res$SORTER)
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0) coco <- unique(res$SORTER[which(res$name.dist>0 & res$name.dist<=2 & res$SORTER%in%tst)])
  rm(tst)
  if(exists("coco")){
    if(length(coco)>0){
      res_1 <- res[which(res$SORTER%in%coco),]
      res_2 <- res[-which(res$SORTER%in%coco),]
      res_1 <- res_1[which(res_1$name.dist<=2),]
      res <- rbind(res_1, res_2)
      rm(res_1, res_2)
    }
    rm(coco)
  }
  
  ## remove multiple results with name.dist>1, if name.dist==1 exists
  tst <- table(res$SORTER)
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0) coco <- unique(res$SORTER[which(res$name.dist==1 & res$SORTER%in%tst)])
  rm(tst)
  if(exists("coco")){
    if(length(coco)>0){
      res_1 <- res[which(res$SORTER%in%coco),]
      res_2 <- res[-which(res$SORTER%in%coco),]
      res_1 <- res_1[which(res_1$name.dist==1),]
      res <- rbind(res_1, res_2)
      rm(res_1, res_2)
    }
    rm(coco)
  }
  
  ## if the column Fuzzy == FALSE, only one column keeps
  tst <- tapply(res$Fuzzy, res$SORTER, function(x)length(unique(x)))
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0) res <- res[-which(res$SORTER%in%tst & res$Fuzzy==TRUE),]
  rm(tst)
  tst <- table(res$SORTER[which(res$Fuzzy==FALSE)])
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0){
    for(i in 1:length(tst)){
      res_1 <- res[which(res$SORTER==tst[i]),]
      res_2 <- res[-which(res$SORTER==tst[i]),]
      res_1 <- res_1[which(res_1$name.dist==min(res_1$name.dist)),]
      if(nrow(res_1)>1) res_1 <- res_1[which(res_1$author.dist==min(res_1$author.dist)),]
      res <- rbind(res_1, res_2)
      rm(res_1, res_2)
    }
  }
  
  ## add new columns
  res$Name_set <- NA
  tst <- table(res$SORTER)
  res$Name_set[which(res$SORTER%in%as.numeric(names(tst[tst==1])))] <- 1
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0){
    for(i in 1:length(tst)){
      res$Name_set[which(res$SORTER==tst[i])] <- rank(-res$Score[which(res$SORTER==tst[i])],ties.method = "random")
    }
    rm(i,tst)
  }
  
  ## add the final accepted names in the result
  res$New_name <- NA
  res$New_author <- NA
  ids <- unique(res$ACCEPTED_ID[!is.na(res$ACCEPTED_ID)])
  if(length(ids)>0){
    for(i in 1:length(ids)){
      which_i <- which(spSource$ID==ids[i])
      if(length(which_i)>0){
        res$New_name[which(res$ACCEPTED_ID==ids[i])] <- ifelse(is.na(spSource$ACCEPTED_ID[which_i])|spSource$ACCEPTED_ID[which_i]==""|spSource$ACCEPTED_ID[which_i]==0, spSource$NAME[which_i],"[Accepted name needs to be determined]")
        res$New_author[which(res$ACCEPTED_ID==ids[i])] <- ifelse(is.na(spSource$ACCEPTED_ID[which_i])|spSource$ACCEPTED_ID[which_i]==""|spSource$ACCEPTED_ID[which_i]==0, spSource$AUTHOR[which_i], NA)
        res$FAMILY[which(res$ACCEPTED_ID==ids[i])] <- ifelse(is.na(spSource$ACCEPTED_ID[which_i])|spSource$ACCEPTED_ID[which_i]==""|spSource$ACCEPTED_ID[which_i]==0, spSource$FAMILY[which_i], NA)
      }
      rm(which_i)
    }
    rm(i)
  }
  rm(ids)
  
  ####################
  colnames(res)[which(colnames(res)=="FAMILY")] <- "Family"
  colnames(res)[which(colnames(res)=="ACCEPTED_ID")] <- "New_ID"
  res <- res[,c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Fuzzy","NOTE","Name_spLev","New_ID","name.dist","author.dist","Score","Name_set","New_name","New_author","Family")]
  
  whichs <- which(is.na(res$NOTE) & is.na(res$Name_in_database))
  if(length(whichs)>0) res <- res[-whichs,]
  rm(whichs)
  
  ##------- add the accepted species-level into the new column "Accepted_SPNAME"
  res$Accepted_SPNAME <- NA
  
  epithets2 <- c("var.","f.","ssp.","grex","nothossp.","prol.","gama","lus.","monstr.","race","nm","subvar.","subf.", "subprol.","cv.", "var", "f", "fo", "fo.", "form", "forma", "forma.", "ssp", "subsp.", "subsp", "cv", "cultivar.", "cultivar", "nothossp", "nothosubsp.", "nothosubsp", "prol", "proles.", "proles", "grex.", "gama.", "lusus", "lusus.", "lus","monstr","race.","nm.","subvar","subf","subfo","subfo.","subform.","subform","subprol","subproles.","subproles")
  
  spMerge <- res$Name_in_database
  spMerge[!is.na(res$New_name)] <- res$New_name[!is.na(res$New_name)]
  if(length(spMerge)==1) spMerge <- spMerge[!is.na(spMerge)]
  if(length(spMerge)>0){
    whichs <- which(!is.na(spMerge))
    if(length(whichs)>0){
      spMerge[whichs] <- paste(plyr::ldply(strsplit(spMerge[whichs], paste(paste(" ", epithets2," ",sep=""), collapse="|")), rbind)[,1])
      res$Accepted_SPNAME[whichs] <- spMerge[whichs]
    }
  }
  rm(spMerge)
  
  ##------- Check if the family names have changed between the original genus and new genus
  genusRaw01 <- res$Genus_in_database
  genusRaw01[is.na(genusRaw01)] <- res$Submitted_Genus[is.na(genusRaw01)]
  Submitted_Family <- genusRaw01
  genusRaw <- unique(Submitted_Family)
  genusRaw <- genusRaw[which(genusRaw%in%spSource$Genus)]
  for(i in 1:length(genusRaw)){
    fami_i <- unique(spSource$FAMILY[which(spSource$Genus==genusRaw[i] & is.na(spSource$ACCEPTED_ID))])
    fami_i <- fami_i[!is.na(fami_i)]
    
    if(length(fami_i)==0){
      fami_i <- unique(spSource$FAMILY[which(spSource$Genus==genusRaw[i])])
      fami_i <- fami_i[!is.na(fami_i)]
    }
    
    if(length(fami_i)==1) res$Family[which(is.na(res$Family) & res$Genus_in_database==genusRaw[i])] <- fami_i
    
    if(length(intersect(unique(res$Family[which(res$Genus_in_database==genusRaw[i])]), fami_i))==0){
      res$NOTE[which(res$Genus_in_database==genusRaw[i] & is.na(res$NOTE))] <- "Unmatched family name"
      res$NOTE[which(res$Genus_in_database==genusRaw[i] & !is.na(res$NOTE) & res$NOTE!="Unmatched family name")] <- paste(res$NOTE[which(res$Genus_in_database==genusRaw[i] & !is.na(res$NOTE))], "Unmatched family name", sep=" & ")	
    }
    
    rm(fami_i)
  }
  
  ##--------------------- 
  tst <- table(res$SORTER)
  tst <- as.numeric(names(tst[tst>1]))
  res$NOTE[which(res$SORTER%in%tst & !is.na(res$NOTE) & !is.na(res$Name_in_database))] <- paste(res$NOTE[which(res$SORTER%in%tst & !is.na(res$NOTE) & !is.na(res$Name_in_database))], "Multiple results", sep=" & ")
  res$NOTE[which(res$SORTER%in%tst & is.na(res$NOTE))] <- "Multiple results"
  rm(tst)
  
  ## remove some results with two different NOTEs
  tst <- tapply(res$NOTE, res$SORTER, function(x)length(unique(x)))
  tst <- as.numeric(names(tst[tst>1]))
  if(length(tst)>0){
    res <- res[-which(res$SORTER%in%tst & res$NOTE=="No matching result"),]
  }
  rm(tst)
  
  ## add missing information for the column Family
  whichs <- which(is.na(res$Family) & !is.na(res$Name_spLev))
  if(length(whichs)>0){
    genus_i <- suppressWarnings(do.call(rbind,strsplit(res$Name_spLev[whichs], " "))[,1])
    for(i in 1:length(genus_i)){
      which_i <- which(spSource$GENUS==genus_i[i] & is.na(spSource$ACCEPTED_ID))
      if(length(which_i)>0){
        fami_i <- spSource$FAMILY[which_i]
        fami_i <- fami_i[!is.na(fami_i)]
        if(length(unique(fami_i))==1) res$Family[which(res$Name_spLev==res$Name_spLev[whichs][i])] <- fami_i[1]
        if(length(unique(fami_i))>1){
          temp <- sort(table(fami_i),decreasing=TRUE)
          res$Family[which(res$Name_spLev==res$Name_spLev[whichs][i])] <- names(temp)[1]
          rm(temp)
        }
      }
      
      rm(which_i)
    }
    rm(genus_i)
  }
  rm(whichs)
  
  whichs <- which(is.na(res$Family) & !is.na(res$Genus_in_database))
  if(length(whichs)>0){
    for(i in 1:length(whichs)){
      fami_i <- spSource$FAMILY[which(spSource$GENUS==res$Genus_in_database[whichs[i]])]
      fami_i <- fami_i[!is.na(fami_i)]
      if(length(unique(fami_i))==1) res$Family[whichs[i]] <- fami_i[1]
      if(length(unique(fami_i))>1){
        temp <- sort(table(fami_i),decreasing=TRUE)
        res$Family[whichs[i]] <- names(temp)[1]
        rm(temp)
      }		
    }
  }
  rm(whichs)
  
  ## If Submitted_Rank==1, remove some matched variables
  whichs <- which(res$Submitted_Rank==1)
  if(length(whichs)>0){
    res$Name_in_database[whichs] <- NA
    res$Author_in_database[whichs] <- NA
    res$Rank_in_database[whichs] <- 1
    res$ID_in_database[whichs] <- NA
    res$Score[whichs] <- NA
    res$name.dist[whichs] <- NA
    res$author.dist[whichs] <- NA
    res$New_ID[whichs] <- NA
    res$Accepted_SPNAME[whichs] <- NA
    res$NOTE[whichs] <- "No matching result"  
  }
  rm(whichs)
  
  ## change the order of the column names, and sort the res by SORTER and Name_set
  res <- res[,c("SORTER","Submitted_Name","Submitted_Author","Submitted_Genus","Submitted_Rank","Name_in_database","Author_in_database","Genus_in_database","Rank_in_database","ID_in_database","Name_set","Fuzzy","Score","name.dist","author.dist","New_name","New_author","New_ID","Family","Name_spLev","Accepted_SPNAME","NOTE")]
  res <- res[!is.na(res$SORTER),]
  res <- unique(res)
  res <- res[order(res$Name_set,res$SORTER),]
  
  ## add other columns in the spSource (e.g., distribution, common names, class, and order) into the result
  if(Append==TRUE){
    res$sorterTemp <- 1:nrow(res)
    res$ID <- res$New_ID
    res$ID[which(is.na(res$New_ID) & !is.na(res$ID_in_database))] <- res$ID_in_database[which(is.na(res$New_ID) & !is.na(res$ID_in_database))]
    colnames(spSource) <- toupper(colnames(spSource))
    whichs <- which(!colnames(spSource)%in%c("ID","NAME","AUTHOR","GENUS","FAMILY","RANK","ACCEPTED_ID","NAMECLEAN"))
    if(length(whichs)>0){
      spSource <- spSource[,which(!colnames(spSource)%in%c("NAME","AUTHOR","GENUS","FAMILY","RANK","ACCEPTED_ID","NAMECLEAN"))]
      res <- merge(res, spSource, by="ID", all.x=TRUE)
      res <- res[order(res$sorterTemp),]
      res <- res[,which(!colnames(res)%in%c("ID","sorterTemp","GENUS00"))]
    }
    rm(whichs)
  }
  
  ## return the result
  return(res)
}
