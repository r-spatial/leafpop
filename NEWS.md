## leafpop 0.0.5

changes:

  * image/graph popup container background color now white.
  * popupTable now drops geometry column if zcol is set and it is not explicitly included. #2
  * new functions addPopupImages & addPopupGraphs register images properly so that they are now included if a map is rendered in markdown or saved locally. #1
  * dropped Rcpp dependency with next to no speed loss. Thanks to @fdetsch!

## leafpop 0.0.1

initial commit
