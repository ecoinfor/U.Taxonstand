#'An example database of standardized name list
#'
#' A data frame with 8 variables.
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
#'@usage data(databaseExample)
#'
#'@examples
#'data(databaseExample)
#'head(databaseExample)
#'
"databaseExample"
