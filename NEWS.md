## leafpop 0.1.0 (2021-05-22)

new features:

  * popupImages & popupGraphs have gained argument 'tooltip' to show images/graphs on hover. https://twitter.com/TimSalabim3/status/1347865160074072064
  * popupImages will now append to already existing popup content. #14
  
bugfixes:

  * in markdown mode widths of popupImages is now respected. #15

## leafpop 0.0.6

new features:

  * popupTable has gained argument 'className' to append a CSS class name to the table. #9 See ?popupTable for an example.

## leafpop 0.0.5

changes:

  * image/graph popup container background color now white.
  * popupTable now drops geometry column if zcol is set and it is not explicitly included. #2
  * new functions addPopupImages & addPopupGraphs register images properly so that they are now included if a map is rendered in markdown or saved locally. #1
  * dropped Rcpp dependency with next to no speed loss. Thanks to @fdetsch!

## leafpop 0.0.1

initial commit
