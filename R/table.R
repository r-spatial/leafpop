#' Create HTML strings for popups
#'
#' @description
#' Create HTML strings for \code{popup} tables used as input for
#' \code{mapview} or \code{leaflet}.
#' This optionally allows the user to include only a subset of feature attributes.
#'
#' @param x A \code{data.frame}, \code{sf}, \code{SpatVector} or \code{Spatial*} object.
#' @param zcol \code{numeric} or \code{character} vector indicating the columns
#' included in the output popup table. If missing, all columns are displayed.
#' @param row.numbers \code{logical} whether to include row numbers in the popup table.
#' @param feature.id \code{logical} whether to add 'Feature ID' entry to popup table.
#' @param className CSS class name(s) that can be used to style the table through
#'   additional css dependencies (see \link[htmltools]{attachDependencies}).
#'
#' @return
#' A \code{list} of HTML strings required to create feature popup tables.
#'
#' @examples
#' library(leaflet)
#'
#' leaflet() %>% addTiles() %>% addCircleMarkers(data = breweries91)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = breweries91,
#'                    popup = popupTable(breweries91))
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = breweries91,
#'                    popup = popupTable(breweries91,
#'                                       zcol = c("brewery", "zipcode", "village"),
#'                                       feature.id = FALSE,
#'                                       row.numbers = FALSE))
#'
#' ## using a custom css to style the table
#' className = "my-popup"
#'
#' css = list(
#'   "background" = "#ff00ff"
#' )
#'
#' css = list(css)
#' names(css) = sprintf("table.%s", className)
#'
#' evenodd = list("#ffff00", "#00ffff")
#' names(evenodd) = rep("background", 2)
#'
#' evenodd = lapply(evenodd, function(i) {
#'   list("background" = i)
#' })
#'
#' names(evenodd) = c(
#'   sprintf("table.%s tr:nth-child(even)", className)
#'   , sprintf("table.%s tr:nth-child(odd)", className)
#' )
#'
#' lst = append(css, evenodd)
#'
#' jnk = Map(function(...) do.call(htmltools::css, ...), lst)
#'
#' dir = tempfile()
#' dir.create(dir)
#' fl = file.path(dir, "myCSS.css")
#'
#' cat(
#'   sprintf(
#'     "%s{ \n  %s\n}\n\n"
#'     , names(jnk)
#'     , jnk
#'   )
#'   , sep = ""
#'   , file = fl
#' )
#'
#' mymap = leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = breweries91,
#'                    popup = popupTable(breweries91, className = className))
#'
#' addMyCSSDependency = function() {
#'   list(
#'     htmltools::htmlDependency(
#'       name = "mycss"
#'       , version = "0.0.1"
#'       , src = dir
#'       , stylesheet = basename(fl)
#'     )
#'   )
#' }
#'
#' mymap$dependencies = c(
#'   mymap$dependencies
#'   , addMyCSSDependency()
#' )
#'
#' mymap
#'
#'
#' @export popupTable
#' @name popupTable
#' @rdname popup
popupTable = function(x,
                      zcol,
                      row.numbers = TRUE,
                      feature.id = TRUE,
                      className = NULL) {

  if (inherits(x, "sfc")) return(NULL)

  brewPopupTable(
    x
    , zcol
    , row.numbers = row.numbers
    , feature.id = feature.id
    , className = className
  )
}


# create popup table of attributes
brewPopupTable = function(x,
                          zcol,
                          width = 300,
                          height = 300,
                          row.numbers = TRUE,
                          feature.id = TRUE,
                          className = NULL) {

  if (inherits(x, "Spatial")) x = x@data
  if (inherits(x, "sf") || inherits(x, "SpatVector")) x = as.data.frame(x)

  if (!missing(zcol)) x = x[, zcol, drop = FALSE]

  # ensure utf-8 for column names (column content is handled on C++ side)
  colnames(x) = enc2utf8(colnames(x))

  if (inherits(x, "SpatialPoints")) {
    mat = NULL
  } else {

    sf_col = attr(x, "sf_column")
    # data.frame with 1 column
    if (ncol(x) == 1 && !is.null(sf_col) && names(x) == sf_col) {
      mat = as.matrix(class(x[, 1])[1])
    } else if (ncol(x) == 1) {
      mat = matrix(as.character(x[, 1]))
      # data.frame with multiple columns
    } else {

      # check for list columns, if found format it
      ids = which(sapply(x, is.list))

      if (any(ids)) {
        # nms = attr(ids, "names")[ids]
        x[, ids] = sapply(sapply(x, class)[ids], "[[", 1) #format(x[, ids])
        # #
        # # for (i in nms) {
        # #   x[[i]] = format(x[[i]])
        # }
      }

      # data to character matrix
      mat = as.matrix(x)
      attr(mat, "dimnames") = NULL
      if (!inherits(mat[1], "character")) {
        mat[1, 1] = as.character(mat[1, 1])
      }
    }

    colnames(mat) = names(x)
    # if (nrow(x) == 1) mat = t(mat)
  }

  if (feature.id) {
    fid = rownames(x)
    mat = cbind("Feature ID" = fid, mat)
  }

  ## create list with row-specific html code
  lst_html = listPopupTemplates(
    mat
    , row_index = row.numbers
    , className = className
  )
  attr(lst_html, "popup") = "leafpop"
  return(lst_html)
}
