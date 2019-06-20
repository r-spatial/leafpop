#' Add graph/plot popups to leaflet layers.
#'
#' @param map the \code{leaflet} map to add the popups to.
#' @param graph A \code{list} of lattice or ggplot2 objects. Needs to be a list,
#'   even for a single plot!
#' @param group the map group to which the popups should be added.
#' @param width the width of the graph(s) in pixels.
#' @param height the height of the graph(s) in pixels.
#'
#' @return
#' A \code{leaflet} map.
#'
#' @examples
#' if (interactive()) {
#' library(sf)
#' library(leaflet)
#'
#' pt = data.frame(x = 174.764474, y = -36.877245)
#' pt = st_as_sf(pt, coords = c("x", "y"), crs = 4326)
#'
#' p2 = levelplot(t(volcano), col.regions = terrain.colors(100))
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = pt, group = "pt") %>%
#'   addPopupGraphs(list(p2), group = "pt", width = 300, height = 400)
#'
#' }
#'
#' @export addPopupGraphs
#' @name addPopupGraphs
#' @rdname addPopupGraphs
addPopupGraphs = function(map, graph, group, width = 300, height = 300) {

  imgs = lapply(seq_along(graph), function(i) {
    fl = tempfile(fileext = ".png")
    grDevices::png(filename = fl, width = width, height = height, units = "px")
    print(graph[[i]])
    dev.off()
    return(fl)
  })

  addPopupImages(map, imgs, group)
}
