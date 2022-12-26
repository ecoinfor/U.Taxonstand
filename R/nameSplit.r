#'Split the names with or without author names into the required format
#'
#' This function is used to format the input taxon names before running the function \code{\link[U.Taxonstand:nameMatch]{nameMatch}}.
#'
#' @param splist A character vector of the input taxon, e.g., "Hieracium aragonense Scheele" and "Pilosella X subulatissima (Zahn) Mateo".
#'
#' @return A data frame with three columns: "Name", "Author" and "Rank".
#'
#'@author Jian Zhang & Hong Qian
#'
#'@examples
#'sps <- c("Syntoma comosum (L.) Dalla Torre & Sarnth.",
#'     "Eupatorium betoniciforme f. alternifolium Hicken",
#'     "Turczaninowia fastigiata (Fisch.) DC.",
#'     "Zizyphora abd-el-asisii Hand.-Mazz.",
#'     "Baccharis X paulopolitana I.L.Teodoro & W.Hoehne",
#'     "Accipiter albogularis woodfordi (Sharpe, 1888)")
#'(splist <- nameSplit(splist=sps))
#'
#'@export
nameSplit <- function(splist){
  
  ##--- the function for splitting for single species
  nameSplit_ck <- function(sp){
    sp <- trimws(sp)
    sp_orig <- sp
    sp <- gsub(paste0("\\s+|", intToUtf8(160)), " ", as.character(sp))
    sp <- gsub("(?! )\\(", " \\(", sp, perl = TRUE)
    
    sp <- gsub(paste(paste(" ", c("var")," ",sep=""), collapse="|"), " var. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("f","fo","fo.","form","form.","forma","forma.")," ",sep=""), collapse="|"), " f. ", sp, ignore.case=TRUE)
    sp <- gsub(" x ", " X ", sp, ignore.case=TRUE)
    sp <- gsub(" \u00d7 ", " X ", sp, ignore.case=TRUE)
    sp <- gsub("\\+ ", "", sp, ignore.case=TRUE)
    sp <- gsub("\\+", "", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("ssp","subsp.","subsp")," ",sep=""), collapse="|"), " ssp. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("cv","cultivar.","cultivar")," ",sep=""), collapse="|"), " cv. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("nothossp","nothosubsp.","nothosubsp")," ",sep=""), collapse="|"), " nothossp. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("prol","proles.","proles")," ",sep=""), collapse="|"), " prol. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("grex.", " grex")," ",sep=""), collapse="|"), " grex. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("gama.", "gama")," ",sep=""), collapse="|"), " gama. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("lusus","lusus.","lus")," ",sep=""), collapse="|"), " lus. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("monstr", "monstr.")," ",sep=""), collapse="|"), " monstr. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("race.", "race")," ",sep=""), collapse="|"), " race. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("nm.", "nm")," ",sep=""), collapse="|"), " nm. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("subvar", "subvar.")," ",sep=""), collapse="|"), " subvar. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("subf","subfo","subfo.","subform","subform.","subforma","subforma.")," ",sep=""), collapse="|"), " subf. ", sp, ignore.case=TRUE)
    sp <- gsub(paste(paste(" ", c("subprol","subproles.","subproles")," ",sep=""), collapse="|"), " subprol. ", sp, ignore.case=TRUE)
    sp <- gsub("  ", " ", sp, ignore.case=TRUE)
    
    ## Remove some non-letter symbols at the beginning
    for(j in 1:100){
      whichs <- which(grepl("^[^A-Za-z]", sp, ignore.case=TRUE))
      if(length(whichs)>0) sp[whichs] <- gsub("^[^A-Za-z]", "", sp[whichs])
      whichs <- which(grepl("^[^A-Za-z]", sp, ignore.case=TRUE))
      if(length(whichs)==0) break
    }
    rm(whichs,j)
    
    ## Further revisions
    spparts <- unlist(strsplit(sp, " "))
    
    if(length(spparts)>0){
        epithets <- c("var.","f.","ssp.","grex","nothossp.","prol.","gama","lus.","monstr.","race","nm","subvar.","subf.","subprol.","cv.","var", "f", "fo", "fo.", "form", "forma", "forma.", "x", "\u00d7", "ssp", "subsp.", "subsp", "cv", "cultivar.", "cultivar", "nothossp", "nothosubsp.", "nothosubsp", "prol", "proles.", "proles", "grex.", "gama.", "lusus", "lusus.", "lus","monstr","race.","nm.","subvar","subf","subfo","subfo.","subform.","subform","subprol","subproles.","subproles")
        whichs <- which(spparts%in%c(epithets, toupper(epithets)))
        
        if(length(whichs)>0 & whichs[1]!=1){
          Author <- paste(spparts[-c(1:(max(whichs)+1))], collapse=" ")
          species <- paste(spparts[c(1:(max(whichs)+1))], collapse=" ")
          if(length(whichs)==1 & "X"%in%spparts[whichs]) Rank <- 2
          if(length(whichs)==1 & !"X"%in%spparts[whichs]) Rank <- 3
          if(length(whichs)>1 & "X"%in%spparts[whichs]){
            if(length(which(spparts=="X"))==1) Rank <- length(whichs)+1
            if(length(which(spparts=="X"))>1) Rank <- length(whichs)
          }
          if(length(whichs)>1 & !"X"%in%spparts[whichs]) Rank <- length(whichs)+2
        }
        
        if(length(whichs)==0){
          Author <- paste(spparts[-c(1:2)], collapse=" ")
          if(length(spparts)==1){
            species <- spparts
            Rank <- 1
          }
          if(length(spparts)>1){
            species <- paste(spparts[1:2], collapse=" ")
            Rank <- 2
          }
        }
        
        if(length(whichs)>0 & whichs[1]==1){
          whichsNew <- whichs[-1]
          if(length(whichsNew)>0){
            Author <- paste(spparts[-c(1:(max(whichsNew)+1))], collapse=" ")
            species <- paste(spparts[c(1:(max(whichsNew)+1))], collapse=" ")
            if(length(whichsNew)==1 & "X"%in%spparts[whichsNew]) Rank <- 2
            if(length(whichsNew)==1 & !"X"%in%spparts[whichsNew]) Rank <- 3
            if(length(whichsNew)>1 & "X"%in%spparts[whichsNew]){
              if(length(which(spparts=="X"))==1) Rank <- length(whichsNew)+1
              if(length(which(spparts=="X"))>1) Rank <- length(whichsNew)
            }
            if(length(whichsNew)>1 & !"X"%in%spparts[whichsNew]) Rank <- length(whichsNew)+2
          }
          if(length(whichsNew)==0){
            Author <- paste(spparts[-c(1:3)], collapse=" ")
            species <- paste(spparts[1:3], collapse=" ")
            Rank <- 2
          }
        }
        rm(whichs, spparts)
        
        ## further work for the names without epithets (e.g., Accipiter badius cenchroides (Temminck, 1824))
        if(substr(Author, 1, 1)%in%letters){
          part01 <- unlist(strsplit(Author, " "))
          species <- paste(species, part01[1], collapse=" ")
          Author <- paste(part01[-1], collapse=" ")
          rm(part01)
          if(substr(Author, 1, 1)%in%letters){
            part01 <- unlist(strsplit(Author, " "))
            species <- paste(species, part01[1], collapse=" ")
            Author <- paste(part01[-1], collapse=" ")
            rm(part01)
          }
        }
        
        ##-------------
        res <- data.frame(Submitted_Name_Author=sp_orig, Name = species, Author=Author, Rank=Rank)
        return(res)
      }
  }
  
  ##--- For all species together
  result <- do.call("rbind", lapply(splist, nameSplit_ck))
  return(result)
}
