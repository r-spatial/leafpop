#' Create HTML strings for popups
#'
#' @description
#' Create HTML strings for \code{popup} graphs used as input for
#' \code{mapview} or \code{leaflet}.
#'
#' @details
#' Type \code{svg} uses native \code{svg} encoding via \code{\link{readLines}}.
#' \code{height} and \code{width} are set via \code{...} and passed on to
#' \code{\link{svg}} \cr
#' Type \code{png} embeds via \code{"<img src = ..."}.
#' \code{height} and \code{width} are set via \code{...} and passed on to
#' \code{\link{png}} \cr
#' Type \code{html} embeds via \code{"<iframe src = ..."}.
#' \code{height} and \code{width} are set directly in pixels. \cr
#'
#' @param graphs A \code{list} of figures associated with \code{x}.
#' @param type Output filetype, one of "png" (default), "svg" or "html".
#' @param width popup width in pixels.
#' @param height popup height in pixels.
#'
#' @return
#' A \code{list} of HTML strings required to create popup graphs.
#'
#' @examples
#' if (interactive()) {
#' ### example: svg -----
#'
#' library(sp)
#' library(lattice)
#'
#' data(meuse)
#' coordinates(meuse) = ~ x + y
#' proj4string(meuse) = CRS("+init=epsg:28992")
#' meuse = spTransform(meuse, CRS("+init=epsg:4326"))
#'
#' ## create plots with points colored according to feature id
#' library(lattice)
#' p = xyplot(copper ~ cadmium, data = meuse@data, col = "grey")
#' p = mget(rep("p", length(meuse)))
#'
#' clr = rep("grey", length(meuse))
#' p = lapply(1:length(p), function(i) {
#'   clr[i] = "red"
#'   update(p[[i]], col = clr)
#' })
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = meuse, popup = popupGraph(p, type = "svg"))
#'
#' ### example: png -----
#' pt = data.frame(x = 174.764474, y = -36.877245)
#'
#' coordinates(pt) = ~ x + y
#' proj4string(pt) = "+init=epsg:4326"
#'
#' p2 = levelplot(t(volcano), col.regions = terrain.colors(100))
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = pt, popup = popupGraph(p2, width = 300, height = 400))
#'
#' ### example: html -----
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(
#'     data = breweries91[1, ],
#'     popup = popupGraph(
#'       leaflet() %>%
#'         addProviderTiles("Esri.WorldImagery") %>%
#'         addMarkers(data = breweries91[1, ],
#'                    popup = popupTable(breweries91[1, ])),
#'      type = "html"
#'     )
#'   )
#'
#' }
#'
#' @export popupGraph
#' @name popupGraph
#' @rdname popup
#' @importFrom grDevices dev.off png
#' @importFrom utils glob2rx
popupGraph = function(graphs, type = c("png", "svg", "html"),
                      width = 300, height = 300, ...) {

  ## if a single feature is provided, convert 'graphs' to list
  if (class(graphs)[1] != "list")
    graphs = list(graphs)

  ## create target folder and filename
  drs = file.path(tempdir(), "popup_graphs")
  if (!dir.exists(drs)) dir.create(drs)

  # type = type[1]
  if (inherits(graphs[[1]], c("htmlwidget"))) {
    type = "html"
  } else type = type[1]

  pop = switch(type,
               png = popupPNGraph(graphs = graphs, dsn = drs,
                                  width = width, height = height, ...),
               svg = popupSVGraph(graphs = graphs, dsn = drs,
                                  width = width, height = height, ...),
               html = popupHTMLGraph(graphs = graphs, dsn = drs,
                                     width = width, height = height, ...))

  # attr(pop, "popup") = "mapview"
  return(pop)
}


### svg -----
popupSVGraph = function(graphs, #dsn = tempdir(),
                        width = 300, height = 300, ...) {
  lapply(1:length(graphs), function(i) {
    #nm = paste0("tmp_", i, ".svg")
    #fls = file.path(dsn, nm)

    inch_wdth = width / 72
    inch_hght = height  / 72

    #svg(filename = fls, width = inch_wdth, height = inch_hght, ...)
    #print(graphs[[i]])
    #dev.off()
    lns <- svglite::svgstring(
      width = inch_wdth,
      height = inch_hght,
      standalone = FALSE
    )
    print(graphs[[i]])
    dev.off()

    svg_str <- lns()

    # this is a temporary solution to work around svglite
    #   non-specific CSS styles
    #   perhaps we should separate out into its own function/utility
    #   also adds uuid dependency
    svg_id <- paste0("x",uuid::UUIDgenerate())
    svg_str <- gsub(
      x = svg_str,
      pattern = "<svg ",
      replacement = sprintf("<svg id='%s'", svg_id)
    )
    # this style gets appended as defaults in all svglite
    #    but might change if svglite changes
    svg_css_rule <- sprintf(
      "#%1$s line, #%1$s polyline, #%1$s polygon, #%1$s path, #%1$s rect, #%1$s circle {",
      svg_id
    )
    svg_str <- gsub(
      x = svg_str,
      pattern = "line, polyline, polygon, path, rect, circle \\{",
      replacement = svg_css_rule
    )

    #lns = paste(readLines(fls), collapse = "")
    # file.remove(fls)
    #     return(
    # sprintf(
    # "
    # <div style='width: %dpx; height: %dpx;'>
    # %s
    # </div>
    # " ,
    #   width,
    #   height,
    #   svg_str
    # )
    # )
    pop = sprintf(
      "<div style='width: %dpx; height: %dpx;'>%s</div>",
      width,
      height,
      svg_str
    )

    popTemplate = system.file("templates/popup-graph.brew", package = "leafpop")
    myCon = textConnection("outputObj", open = "w")
    brew::brew(popTemplate, output = myCon)
    outputObj = outputObj
    close(myCon)

    return(paste(outputObj, collapse = ' '))

  })
}


### png -----
popupPNGraph = function(graphs, dsn = tempdir(),
                        width = 300, height = 300, ...) {
  # pngs = lapply(1:length(graphs), function(i) {
  #   nm = paste0("tmp_", i, ".png")
  #   fls = file.path(dsn, nm)
  #
  #   png(filename = fls, width = width, height = height, units = "px", ...)
  #   print(graphs[[i]])
  #   dev.off()
  #
  #   rel_path = file.path("..", basename(dsn), nm)
  #   return(rel_path)
  # })
  #
  # popupImage(pngs, width = width, height = height, src = "local")

  pngs = lapply(1:length(graphs), function(i) {

    fl = tempfile(fileext = ".png")

    grDevices::png(filename = fl, width = width, height = height, units = "px", ...)
    print(graphs[[i]])
    dev.off()

    plt64 = base64enc::base64encode(fl)
    pop = paste0('<img src="data:image/png;base64,', plt64, '" />')

    # return(uri)
    popTemplate = system.file("templates/popup-graph.brew", package = "leafpop")
    myCon = textConnection("outputObj", open = "w")
    brew::brew(popTemplate, output = myCon)
    outputObj = outputObj
    close(myCon)

    return(paste(outputObj, collapse = ' '))
  })

  return(pngs)
}

### html -----
popupHTMLGraph = function(graphs, dsn = tempdir(),
                          width = 300, height = 300, ...) {
  lapply(1:length(graphs), function(i) {
    nm = paste0("tmp_", i, ".html")
    fls = file.path(dsn, nm)
    htmlwidgets::saveWidget(graphs[[i]], fls, ...)

    rel_path = file.path("..", basename(dsn))

    popupIframe(file.path(rel_path, basename(fls)), width + 5, height + 5)

  })
}


### iframe -----
popupIframe = function(src, width = 300, height = 300) {
  pop = paste0("<iframe src='",
               src,
               "' frameborder=0 width=",
               width,
               " height=",
               height,
               #" align=middle",
               "></iframe>")

  popTemplate = system.file("templates/popup-graph.brew", package = "leafpop")
  myCon = textConnection("outputObj", open = "w")
  brew::brew(popTemplate, output = myCon)
  outputObj = outputObj
  close(myCon)

  return(paste(outputObj, collapse = ' '))
}
