#'The subfunction for standardizing one input taxon
#'
#' Replacing synonyms by accepted names and removing orthographical errors. This function is used to run the main function "nameMatch", we suggest NOT to use it independently.
#'
#' @param spData A character vector specifying the input taxon. The binominal name and the author name are connected by "#", e.g., "Hieracium aragonense#Scheele" and "Pilosella X subulatissima#(Zahn) Mateo".
#'
#' @param spSource A data frame of the database with standarized taxon names. An example of data frame could be found in the example data 'databaseExample'.
#'
#' @param author Logical. If TRUE (default), the function tries to match author names from the input taxon and calculate the author distance.
#'
#' @param max.distance A number indicating the maximum distance allowed for a match in \code{\link[base:agrep]{agrep}} when performing corrections of spelling errors in specific epithets.
#'
#' @return A data frame with the following columns: \itemize{
#'    \item{\emph{Submitted_Name_Author}}{: The combination of the original taxon name and author name as provided in input.}
#'    \item{\emph{Name_in_database}}{: Matched specific epithet, extracted from the spSource.}
#'    \item{\emph{Author_in_database}}{: Matched author name, extracted from the spSource.}
#'    \item{\emph{Genus_in_database}}{: Matched genus name, extracted from the spSource.}
#'    \item{\emph{Rank_in_database}}{: Matched taxonomic rank of specific epithet.}
#'    \item{\emph{ID_in_database}}{: Matched ID, extracted from the spSource.}
#'    \item{\emph{NOTE}}{: This column contains some notes, e.g. no matching or multiple matching results for a given name, or only matching at species level for a trinomial name.}
#'    \item{\emph{Name_spLev}}{: If the input taxon name cannot be matched at the same rank level, the species-level matching name shows here.}
#'    \item{\emph{ACCEPTED_ID}}{: The accepted ID in the spSource.}
#'    \item{\emph{FAMILY}}{: Family name, extracted from the spSource.}
#'}
#'
#'@author Jian Zhang & Hong Qian
#'
#'@export
nameMatch_ck <- function(spData, spSource=NULL, author=TRUE, max.distance = 1)
{
  ## The subfunction for fuzzy matching of ONE species. This function is used to run the main function "nameMatch", we suggest NOT to use it independently.
  ## The format for spData should like this "Christella acuminata monstr. kuliangensis#(Zahn) Zahn" (using the "#" to seperate species and author names)
  
  ################################################
  ##----------------------
  sp <- unlist(strsplit(spData, "#"))[1]
  
  spparts <- unlist(strsplit(sp, " "))
  genus <- spparts[1]
  species <- tolower(spparts[2])
  if(length(spparts)==3) infrasp <- tolower(spparts[3])
  if(length(spparts)>3) infrasp <- tolower(paste(spparts[-c(1:2)], collapse=" "))
  if(length(spparts)<3) infrasp <- ""
  
  if(author==TRUE) Author <- unlist(strsplit(spData, "#"))[2]
  if(author==FALSE) Author <- ""
  if(is.na(Author)) Author <- ""
  if(Author=="") author=FALSE

  #####################################
  #--- To match with the species names within exactly the same name in the database
  if(length(intersect(sp,spSource$NAMECLEAN))>=1) cck <- intersect(sp,spSource$NAMECLEAN)
  
  #--- for the rarely happened case to merge the species and the infrasp (e.g., "Acrostichum ruta muraria" -> "Acrostichum rutamuraria"; "Davallia friederici et pauli" -> "Davallia friderici-et-pauli")
  if(infrasp!=""){
    sp0 <- paste(genus, " ", species, paste0(unlist(strsplit(infrasp, " ")), collapse=""), sep="")
    if(length(intersect(sp0,spSource$NAMECLEAN))>=1) cck <- intersect(sp0,spSource$NAMECLEAN)
    rm(sp0)
  }
  
  #####################################
  #--- To match with the species names within the same genus, but no exactly the same name in the database
  if(!exists("cck")){
    if(genus%in%spSource$GENUS & !sp%in%spSource$NAMECLEAN){
      spTemp <- ifelse(length(spparts)==2, sp, paste(genus, species, sep=" "))
      
      cckTemp <- c()
      if(spTemp%in%spSource$NAMECLEAN) cckTemp <- intersect(spTemp,spSource$NAMECLEAN)
      
      if(!spTemp%in%spSource$NAMECLEAN){
        nameFuzzy <- spSource$NAMECLEAN[which(spSource$GENUS==genus & spSource$RANK==2)]
        if(length(nameFuzzy)>0){
          distAll <- as.numeric(utils::adist(nameFuzzy, y = spTemp))
          whichs <- which(distAll <= 2)
          if(length(whichs)>0) cckTemp <- nameFuzzy[whichs]
          if(length(whichs)==0){
            whichs <- which(distAll <= 3)
            if(length(whichs)>0) cckTemp <- nameFuzzy[whichs]
            if(length(whichs)==0) cckTemp <- c()
          }
        }
        
        if(exists("nameFuzzy")) rm(nameFuzzy)
        cckTemp <- unique(cckTemp)
      }
      
      if(length(cckTemp)==0) rm(cckTemp)
      if(length(spparts)==2 & exists("cckTemp"))	cck <- cckTemp
      
      if(length(spparts)>2 & exists("cckTemp")){
        cck01 <- unique(paste(cckTemp, infrasp, sep=" "))
        if(length(cck01)>1){
          whichs <- which(cck01%in%spSource$NAMECLEAN)
          if(length(whichs)>0) cck01 <- cck01[whichs]
          rm(whichs)
        }
        if(length(cck01)==1){
          if(cck01%in%spSource$NAMECLEAN) cck <- cck01
        }
        rm(cck01)
      }
    }
  }
  
  if(exists("cck")){
    cck <- cck[!is.na(cck)]
    if(length(cck)==0) rm(cck)
  }
  
  if(exists("cckTemp")){
    cckTemp <- cckTemp[!is.na(cckTemp)]
    if(length(cckTemp)==0) rm(cckTemp)
  }
  
  ## another round of matching for both with and without infrasp
  if(!exists("cck")){
    if(genus%in%spSource$GENUS & !sp%in%spSource$NAMECLEAN){
      cck <- c()
      nameFuzzy <- spSource$NAMECLEAN[which(spSource$GENUS==genus)]
      len_nameFuzzy <- lengths(gregexpr("\\W+", nameFuzzy))+1
      if(length(spparts)==2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy==2)]
      if(length(spparts)>2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy>2)]
      rm(len_nameFuzzy)
      
      if(length(nameFuzzy)>0){
        distAll <- as.numeric(utils::adist(nameFuzzy, y = spTemp))
        whichs <- which(distAll <= 2)
        if(length(whichs)>0) cck <- nameFuzzy[whichs]
        if(length(whichs)==0){
          whichs <- which(distAll <= 3)
          if(length(whichs)>0) cck <- nameFuzzy[whichs]
          if(length(whichs)==0){
            cck <- c()
            ## keep the shortest distance for further uses if needed
            cckTemp2 <- nameFuzzy[which(distAll==min(distAll))]
          }
        }
        rm(distAll)
      }
      if(exists("nameFuzzy")) rm(nameFuzzy)
    }
  }
  
  ##--------------------- if the name.dist >5, delete
  if(exists("cck")){
    if(length(cck)>0){
      dist_w <- as.numeric(utils::adist(cck,sp))
      whichs <- which(dist_w>=5)
      if(length(whichs)>0) cck <- cck[-whichs]
      rm(whichs, dist_w)
    }
  }
  
  ##--------------------- Some replacements to do for "species"
  wordRep <- data.frame(x=c('ei','ae','ai','yi','ii',"ii","ea","se","ides","rr","ii","des","ae","um","ea","um","ia","ius"), y=c('i','i','i','i','i',"ae","ya","sie","des","r","ei","ides","e","ea","um","a","ius","ia"))
  
  ##--------------------- If no matching within the distance, but with the same specific epithets (e.g., for ‘Euodia acronychioides’, the part "acronychioides" are the same)
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(!exists("cck")) cck <- c()
  if(length(cck)==0){
    nameFuzzy <- spSource$NAMECLEAN[which(grepl(species, spSource$NAMECLEAN, fixed = TRUE))]
    len_nameFuzzy <- lengths(gregexpr("\\W+", nameFuzzy))+1
    if(length(spparts)==2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy==2)]
    if(length(spparts)>2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy>2)]
    rm(len_nameFuzzy)
    
    if(length(nameFuzzy)>0 & length(spparts)==2){
      dist_w <- as.numeric(utils::adist(sp, nameFuzzy))
      cck <- unique(nameFuzzy[which(dist_w==min(dist_w))])
      rm(dist_w)
    }
    
    if(length(nameFuzzy)>0 & length(spparts)>2){
      spSplit <- plyr::ldply(strsplit(nameFuzzy," "), rbind)[,2]
      whichs <- which(grepl(species, spSplit, fixed = TRUE))
      if(length(whichs)>0){
        nameFuzzy <- nameFuzzy[whichs]
        dist_w <- as.numeric(utils::adist(sp, nameFuzzy))
        cck <- unique(nameFuzzy[which(dist_w==min(dist_w))])
        rm(dist_w)
      }
      rm(spSplit, whichs)
    }
    
    if(length(cck)!=0){
      if(min(as.numeric(utils::adist(sp,cck)))>=5) cck <- c()}
    
    if(length(cck)==0){
      speciesRep <- c()
      for(i in 1:nrow(wordRep)){
        if(grepl(wordRep$x[i],species)) speciesRep <- c(speciesRep, gsub(wordRep$x[i],wordRep$y[i],species, ignore.case = TRUE))
      }
      
      if(length(speciesRep)>0){
        if(length(spparts)==2) spRep <- paste(genus, speciesRep, sep=" ")
        if(length(spparts)>2) spRep <- paste(genus, speciesRep, infrasp, sep=" ")
        if(length(which(spRep%in%spSource$NAMECLEAN))>0) cck <- spRep[which(spRep%in%spSource$NAMECLEAN)]
        
        if(length(which(spRep%in%spSource$NAMECLEAN))==0){
          
          if(length(speciesRep)==1) nameFuzzy <- spSource$NAMECLEAN[which(grepl(speciesRep, spSource$NAMECLEAN, fixed = TRUE))]
          
          if(length(speciesRep)>1) {
            nameFuzzy <- c()
            for(j in 1:length(speciesRep)){
              nameFuzzy <- c(nameFuzzy, spSource$NAMECLEAN[which(grepl(speciesRep[j], spSource$NAMECLEAN, fixed = TRUE))])
            }
            rm(j)
          }
          
          len_nameFuzzy <- lengths(gregexpr("\\W+", nameFuzzy))+1
          if(length(spparts)==2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy==2)]
          if(length(spparts)>2) nameFuzzy <- nameFuzzy[which(len_nameFuzzy>2)]
          rm(len_nameFuzzy)
          
          if(length(nameFuzzy)>0 & length(spparts)==2){
            dist_w <- as.numeric(utils::adist(sp, nameFuzzy))
            cck <- unique(nameFuzzy[which(dist_w==min(dist_w))])
            rm(dist_w)}
          
          if(length(nameFuzzy)>0 & length(spparts)>2){
            spSplit <- plyr::ldply(strsplit(nameFuzzy," "), rbind)[,2]
            if(length(speciesRep)==1) whichs <- which(grepl(speciesRep, spSplit, fixed = TRUE))
            if(length(speciesRep)>1){
              whichs <- c()
              for(j in 1:length(speciesRep)){
                whichs <- c(whichs, which(grepl(speciesRep[j], spSplit, fixed = TRUE)))
              }
              rm(j)
            }
            
            if(length(whichs)>0){
              nameFuzzy <- nameFuzzy[whichs]
              dist_w <- as.numeric(utils::adist(sp, nameFuzzy))
              cck <- unique(nameFuzzy[which(dist_w==min(dist_w))])
              rm(dist_w)
            }
            
            rm(spSplit, whichs)
          }
          
          if(length(cck)!=0){
            if(min(as.numeric(utils::adist(sp, cck)))>=5) cck <- c()}
        }
      }
    }
  }
  
  if(exists("i")) rm(i)
  if(exists("nameFuzzy")) rm(nameFuzzy)
  if(exists("speciesRep")) rm(speciesRep)
  if(exists("spRep")) rm(spRep)
  if(exists("wordRep")) rm(wordRep)
  
  ##-----------------------------------
  ## if the length of spparts >3 (e.g., "Agropyron caesium caesium caesium"), try to match
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(!exists("cck")) cck <- c()
  if(length(cck)==0){
    if(length(spparts)>3){
      if(paste(spparts[1:3], collapse=" ")%in%spSource$NAMECLEAN){ 	cck <- paste(spparts[1:3], collapse=" ")
      # noteSp <- TRUE
      }
    }
  }
  
  ##-----------------------------------
  ## if the length of spparts >3, try to match again
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(!exists("cck")) cck <- c()
  if(length(cck)==0){
    if(length(spparts)>=3){
      if(paste(spparts[1:2], collapse=" ")%in%spSource$NAMECLEAN){
        cckTemp <- paste(spparts[1:2], collapse=" ")
      }
      
      if(exists("cckTemp")){
        if(length(cckTemp)==1) spTemp <- gsub(paste(spparts[1:2], collapse=" "), cckTemp, sp, ignore.case = TRUE)
        if(length(cckTemp)>1){
          spTemp <- c()
          for(j in 1:length(cckTemp)){
            spTemp[j] <- gsub(paste(spparts[1:2], collapse=" "), cckTemp[j], sp, ignore.case = TRUE)
          }
          rm(j)
        }
        
        cck <- spSource$NAMECLEAN[which(spSource$NAMECLEAN%in%spTemp)]
        
        if(length(cck)==0){
          nameFuzzy <- spSource$NAMECLEAN[which(spSource$GENUS==unlist(strsplit(spTemp, " "))[1] & spSource$RANK>2)]
          if(length(nameFuzzy)>0){
            distAll <- as.numeric(utils::adist(nameFuzzy, y = spTemp))
            whichs <- which(distAll <= 2)
            if(length(whichs)>0) cck <- nameFuzzy[whichs]
            if(length(whichs)==0){
              whichs <- which(distAll <= 3)
              if(length(whichs)>0) cck <- nameFuzzy[whichs]
            }
          }
          
          if(exists("nameFuzzy")) rm(nameFuzzy)
          cck <- unique(cck)
        }
      }
    }
  }
  
  ##-----------------------------------
  ## if the length of spparts >=3 (e.g., "Agropyron caesium abcd"), try to match at species level
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(!exists("cck")) cck <- c()
  
  if(length(cck)==0){
    if(length(spparts)>=3){
      if(paste(spparts[1:2], collapse=" ")%in%spSource$NAMECLEAN){
        cck <- paste(spparts[1:2], collapse=" ")
        noteSp <- TRUE
      }
      
      if(exists("cckTemp")){
        cckTemp <- unique(cckTemp)
        whichs <- which(cckTemp%in%spSource$NAMECLEAN)
        if(length(whichs)>0) cckTemp <- cckTemp[whichs]
        if(length(cck)==0 & length(cckTemp)>0){
          cck <- cckTemp
          noteSp <- TRUE
        }
        rm(whichs)
      }
      
      if(length(cck)==0 & !paste(spparts[1:2], collapse=" ")%in%spSource$NAMECLEAN & spparts[1]%in%spSource$GENUS){
        nameFuzzy <- spSource$NAMECLEAN[which(spSource$GENUS==spparts[1])]
        len_nameFuzzy <- lengths(gregexpr("\\W+", nameFuzzy))+1
        nameFuzzy <- nameFuzzy[which(len_nameFuzzy==2)]
        rm(len_nameFuzzy)
        
        if(length(nameFuzzy)>0) cck <- unique(agrep(paste(spparts[1:2], collapse=" "), nameFuzzy, value = TRUE, max.distance = max.distance, ignore.case=TRUE))
        if(exists("nameFuzzy")) rm(nameFuzzy)
        
        if(length(cck)>0) noteSp <- TRUE
      }
      
      if(length(cck)==0 & !paste(spparts[1:2], collapse=" ")%in%spSource$NAMECLEAN & !spparts[1]%in%spSource$GENUS){
        nameFuzzy <- spSource$NAMECLEAN[which(grepl(spparts[2], spSource$NAMECLEAN, fixed = TRUE))]
        len_nameFuzzy <- lengths(gregexpr("\\W+", nameFuzzy))+1
        nameFuzzy <- nameFuzzy[which(len_nameFuzzy==2)]
        rm(len_nameFuzzy)
        
        if(length(nameFuzzy)>0) cck <- unique(agrep(paste(spparts[1:2], collapse=" "), nameFuzzy, value = TRUE, max.distance = max.distance, ignore.case=TRUE))
        if(exists("nameFuzzy")) rm(nameFuzzy)
        
        if(length(cck)>0) noteSp <- TRUE
      }
    }
  }
  
  if(length(cck)==0 & exists("cckTemp2")){
    cck <- cckTemp2
    rm(cckTemp2)
  }
  
  ##-----------------------------------
  ## return the result
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(exists("cck")){
    if(length(cck)>0){
      tst <- spSource[which(spSource$NAMECLEAN%in%cck),]
      
      # If the author name is the same, keep this one only
      if(author==TRUE & Author!=""){
        if(length(which(tst$name.dist==0 & tst$AUTHOR==Author))>0) tst <- tst[which(tst$name.dist==0 & tst$AUTHOR==Author),]
        if(length(unique(tst$name.dist))==1 & length(which(tst$AUTHOR==Author))>0) tst <- tst[which(tst$AUTHOR==Author),]
      }
      
      if(nrow(tst)>0){
        match.out <- data.frame(
          Submitted_Name_Author=rep(spData,nrow(tst)),
          Name_in_database=tst$NAME,
          Author_in_database=tst$AUTHOR,
          Genus_in_database=tst$GENUS,
          Rank_in_database=tst$RANK,
          ID_in_database=tst$ID,
          NOTE=NA,
          Name_spLev=NA,
          ACCEPTED_ID=tst$ACCEPTED_ID,
          FAMILY=tst$FAMILY,
          stringsAsFactors = FALSE)
      }
      rm(tst)
    }
  }
  
  
  ##-----------------------------------
  ## if cck doesn't exist
  if(exists("cck")){
    if(length(cck)==1){if(is.na(cck)) rm(cck)}
  }
  
  if(!exists("cck")) cck <- c()
  ## if cck exists, but cck is empty
  if(exists("cck")){
    if(length(cck)==0){
      match.out <- data.frame(
        Submitted_Name_Author=spData,
        Name_in_database=NA,
        Author_in_database=NA,
        Genus_in_database=ifelse(genus%in%spSource$GENUS, genus, NA),
        Rank_in_database=NA,
        ID_in_database=NA,
        NOTE="No matching result",
        Name_spLev=NA,
        ACCEPTED_ID=NA,
        FAMILY=NA,
        stringsAsFactors = FALSE)
    }
  }
  
  ## add note for the result only matching at species level
  if(exists("noteSp")){
    match.out$Name_spLev <- match.out$Name_in_database
    match.out$NOTE <- "Matching at species level"
    match.out$ACCEPTED_ID <- NA
    match.out$FAMILY <- NA
    match.out$Name_in_database=NA
    match.out$Author_in_database=NA
    match.out$Genus_in_database=NA
    match.out$Rank_in_database=NA
    match.out$ID_in_database=NA
  }
  
  ## return the result
  return(match.out)
}
