# U.Taxonstand

`U.Taxonstand` is an R Package for Standardizing and Harmonizing Scientific Names of Plants and Animals. This package can standardize and harmonize scientific names in plant and animal species lists at a fast execution speed and at a high rate of matching success. It works with all taxonomic databases, as long as they are properly formatted. 

## Installation

This package can be installed in R as follows,

```r
# github (requires `remotes` or `devtools`)
devtools::install_github("ecoinfor/U.Taxonstand")
```

## Example Usage

```r
library(U.Taxonstand)

# load the example database (you can creat your own database for specific taxomic groups)
data(databaseExample)

# The input names as a character vector
sps <- c("Syntoma comosum (L.) Dalla Torre & Sarnth.", "Turczaninowia fastigiata (Fisch.) DC.",
"Zizyphora abd-el-asisii Hand.-Mazz.")
nameMatch(spList=sps, spSource=databaseExample, author = TRUE, max.distance= 1)

# The input as a dataframe with the columns "SPECIES", "AUTHOR" and/or "RANK"
data(spExample)
res <- nameMatch(spList=spExample, spSource=databaseExample, author = TRUE, max.distance= 1)
head(res)

# The current default only keeps the first 'best' matching result for each taxon name. If you want to check all the matched results, please change the option 'matchFirst=FALSE'.
res <- nameMatch(spList=spExample, spSource=databaseExample, author = TRUE, max.distance= 1, matchFirst=FALSE)
dim(res)

# Using the additional data of genus pairs for fuzzy matching of genus names
data(spExample)
data(genusPairs_Plants)
res <- nameMatch(spList=spExample, spSource=databaseExample, author = TRUE, max.distance= 1, 
genusPairs=genusPairs_Plants)
head(res)

#------------------ The R package also works for other taxomic groups. The below is an exmaple for birds
# load the formatted ITIS Aves database; the formatted database can be downloaded here:
# https://github.com/nameMatch/Database
require(openxlsx)
databaseAves <- read.xlsx("Birds_ITIS_database.xlsx")

spAves <- c("Hieraaetus fasciata","Merops leschenaultia","Egretta sacra","Sturnia philippensis","Phoenicurus caeruleocephala","Enicurus maculates","Orthotomus cucullatus","Phalacrocorax carbo")
nameMatch(spList=spAves,spSource=databaseAves, author = FALSE, max.distance= 1)

#------------------ You can use the function "nameSplit" to format your species name list
sps <- c("Syntoma comosum (L.) Dalla Torre & Sarnth.","Eupatorium betoniciforme f. alternifolium Hicken","Turczaninowia fastigiata (Fisch.) DC.","Zizyphora abd-el-asisii Hand.-Mazz.","Baccharis X paulopolitana I.L.Teodoro & W.Hoehne","Accipiter albogularis woodfordi (Sharpe, 1888)")
(splist <- nameSplit(splist=sps))
```

## Citing This Package

If you use this package, please cite it.

Zhang, J. & Qian, H. (2023). U.Taxonstand: An R package for standardizing scientific names of plants and animals. Plant Diversity, 45(1): 1-5. DOI: [10.1016/j.pld.2022.09.001](https://doi.org/10.1016/j.pld.2022.09.001)


## Selected Publications Citing `U.Taxonstand`

- Qian, H., Qian, S., Zhang, J., & Kessler, M. (2024). Effects of climate and environmental heterogeneity on the phylogenetic structure of regional angiosperm floras worldwide. Nature Communications, 15(1), 1079. https://doi.org/10.1038/s41467-024-45155-9

- Luo, A., Li, Y., Shrestha, N., Xu, X., Su, X., Li, Y., ... & Wang, Z. (2024). Global multifaceted biodiversity patterns, centers, and conservation needs in angiosperms. Science China Life Sciences, 1-12. https://doi.org/10.1007/s11427-023-2430-2

- Ye, Y., Fu, Q., Volis, S., Li, Z., Sun, H., & Deng, T. (2024). Evolutionary correlates of extinction risk in Chinese angiosperm. Biological Conservation, 292, 110549. https://doi.org/10.1016/j.biocon.2024.110549

- Schellenberger Costa, D., Boehnisch, G., Freiberg, M., Govaerts, R., Grenié, M., Hassler, M., ... & Wirth, C. (2023). The big four of plant taxonomy – a comparison of global checklists of vascular plant names. New Phytologist. https://doi.org/10.1111/nph.18961

- Benedicto‐Royuela, J., Costa, J. M., Heleno, R., Silva, J. S., Freitas, H., Lopes, P., ... & Timóteo, S. (2023). What is the value of biotic seed dispersal in post‐fire forest regeneration? Conservation Letters, e12990. https://doi.org/10.1111/conl.12990

- Qian, H., Kessler, M., Zhang, J., Jin, Y., Soltis, D.E., Qian, S., Zhou, Y.D., Soltis, P.S. Angiosperm phylogenetic diversity is lower in Africa than South America . Science Advances, 9(46): eadj1022 https://doi.org/10.1126/sciadv.adj1022

- Vargas, Pablo, Ruben Heleno, and José M. Costa. EuDiS-A comprehensive database of the seed dispersal syndromes of the European flora. Biodiversity Data Journal 11 (2023). https://doi.org/10.3897/BDJ.11.e104079

- Qian, Hong, Michael Kessler, and Yi Jin. Spatial patterns and climatic drivers of phylogenetic structure for ferns along the longest elevational gradient in the world. Ecography (2022): e06516. https://doi.org/10.1111/ecog.06516

- Zhou, Ya-Dong, et al. Geographic patterns of taxonomic and phylogenetic β-diversity of aquatic angiosperms in China. Plant Diversity (2022). https://doi.org/10.1016/j.pld.2022.12.006

- Qian, Hong. Patterns of phylogenetic relatedness of non-native plants across the introduction–naturalization–invasion continuum in China. Plant Diversity (2022). https://doi.org/10.1016/j.pld.2022.12.005

- Huang, Xing-Zhao, et al. Are allometric model parameters of aboveground biomass for trees phylogenetically constrained? Plant Diversity (2022). https://doi.org/10.1016/j.pld.2022.11.005

- Qian, Hong, et al. Effects of non‐native species on phylogenetic dispersion of freshwater fish communities in North America. Diversity and Distributions (2022). https://doi.org/10.1111/ddi.13647

- Jin, Yi, and Hong Qian. Drivers of the differentiation between broad-leaved trees and shrubs in the shift from evergreen to deciduous leaf habit in forests of eastern Asian subtropics. Plant Diversity (2023). https://doi.org/10.1016/j.pld.2022.12.008

- Qian, Hong, and Tao Deng. Species invasion and phylogenetic relatedness of vascular plants on the Qinghai-Tibetan Plateau, the roof of the world. Plant Diversity (2023). https://doi.org/10.1016/j.pld.2023.01.001

- etc.
