#'An example data of the genus pairs of plants with different spellings
#'
#' A data frame with 355 rows and 2 variables. The file with the information of genus variants is optional to U.Taxonstand, but the rate of matching success may increase when such information is provided.
#'
#' @format A data frame with 3 variables: \itemize{
#'    \item{\emph{Genus01}}{: The genus name with high possibility to misspell as the name of the same row in the column Genus02.}
#'    \item{\emph{Genus02}}{: The genus name with high possibility to misspell as the name of the same row in the column Genus01.}
#' }
#'
#'@usage data(genusPairs_Plants)
#'
#'@examples
#'data(genusPairs_Plants)
#'head(genusPairs_Plants)
#'
"genusPairs_Plants"
