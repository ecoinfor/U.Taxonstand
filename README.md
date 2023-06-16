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


## Publications Citing `U.Taxonstand`

- Schellenberger Costa, D., Boehnisch, G., Freiberg, M., Govaerts, R., Grenié, M., Hassler, M., ... & Wirth, C. (2023). "The big four of plant taxonomy–a comparison of global checklists of vascular plant names." New Phytologist. https://doi.org/10.1111/nph.18961

- Qian, Hong, Michael Kessler, and Yi Jin. "Spatial patterns and climatic drivers of phylogenetic structure for ferns along the longest elevational gradient in the world." Ecography (2022): e06516.

- Zhou, Ya-Dong, et al. "Geographic patterns of taxonomic and phylogenetic β-diversity of aquatic angiosperms in China." Plant Diversity (2022).

- Qian, Hong. "Patterns of phylogenetic relatedness of non-native plants across the introduction–naturalization–invasion continuum in China." Plant Diversity (2022).

- Huang, Xing-Zhao, et al. "Are allometric model parameters of aboveground biomass for trees phylogenetically constrained?" Plant Diversity (2022).

- Qian, Hong, et al. "Effects of non‐native species on phylogenetic dispersion of freshwater fish communities in North America." Diversity and Distributions (2022).

- Jin, Yi, and Hong Qian. "Drivers of the differentiation between broad-leaved trees and shrubs in the shift from evergreen to deciduous leaf habit in forests of eastern Asian subtropics." Plant Diversity (2023).

- Qian, Hong, and Tao Deng. "Species invasion and phylogenetic relatedness of vascular plants on the Qinghai-Tibetan Plateau, the roof of the world." Plant Diversity (2023).

- etc.
