#'An example backbone dataset of standardized name list
#'
#' A data frame with 9 columns and 6 variables. Multiple backbone databases for plants and animals that can be directly used by U.Taxonstand are available online \code{\link[https://github.com/nameMatch/Data_backbone]{https://github.com/nameMatch/Data_backbone}}. They include global taxonomic databases for vascular plants, amphibians, birds, fishes, mammals, and reptiles. Global backbone databases for other groups of organisms may be placed on the website in future.
#'
#' @format A data frame with 6 variables: \itemize{
#'    \item{\emph{ID}}{: ID of the specific epithet.}
#'    \item{\emph{Name}}{: Specific epithet.}
#'    \item{\emph{Author}}{: Author name.}
#'    \item{\emph{Genus}}{: Optional. Genus name.}
#'    \item{\emph{Rank}}{: Optional. Taxonomic rank.}
#'    \item{\emph{ACCEPTED_ID}}{: Accepted ID of the specific epithet.}
#'    \item{\emph{FAMILY}}{: Family name}
#'    \item{\emph{NameClean}}{: Optional. The formatted name using for the name matching. If missing, the function \code{\link[U.Taxonstand:nameMatch]{nameMatch}} will automatically generate one new column, or you can use the function \code{\link[U.Taxonstand:nameClean]{nameClean}} to generate a new dataframe for further uses.}
#' }
#'
#'@examples
#'data(databaseExample)
#'head(databaseExample)
#'
"databaseExample"
