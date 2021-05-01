#' Add image popups to leaflet layers.
#'
#' @param map the \code{leaflet} map to add the popups to.
#' @param image A character \code{vector} of file path(s) or
#'   web-URL(s) to any sort of image file(s).
#' @param group the map group to which the popups should be added.
#' @param width the width of the image(s) in pixels.
#' @param height the height of the image(s) in pixels.
#' @param tooltip logical, whether to show image(s) as popup(s) (on click) or
#'   tooltip(s) (on hover).
#' @param ... additional options passed on to the JavaScript creator function.
#'   See \url{https://leafletjs.com/reference-1.7.1.html#popup} &
#'   \url{https://leafletjs.com/reference-1.7.1.html#tooltip} for details.
#'
#' @return
#' A \code{leaflet} map.
#'
#' @examples
#' if (interactive()) {
#' ## remote images -----
#' ### one image
#' library(leaflet)
#' library(sf)
#' library(lattice)
#'
#' pnt = st_as_sf(data.frame(x = 174.764474, y = -36.877245),
#'                 coords = c("x", "y"),
#'                 crs = 4326)
#'
#' img = "http://bit.ly/1TVwRiR"
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = pnt, group = "pnt") %>%
#'   addPopupImages(img, group = "pnt")
#'
#' ### multiple file (types)
#' library(sf)
#' images = c(img,
#'             "https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg",
#'             "https://www.r-project.org/logo/Rlogo.png",
#'             "https://upload.wikimedia.org/wikipedia/commons/d/d6/MeanMonthlyP.gif")
#'
#' pt4 = data.frame(x = jitter(rep(174.764474, 4), factor = 0.01),
#'                   y = jitter(rep(-36.877245, 4), factor = 0.01))
#' pt4 = st_as_sf(pt4, coords = c("x", "y"), crs = 4326)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addMarkers(data = pt4, group = "points") %>%
#'   addPopupImages(images, group = "points", width = 400) # NOTE the gif animation
#'
#' ## local images -----
#' pnt = st_as_sf(data.frame(x = 174.764474, y = -36.877245),
#'                 coords = c("x", "y"), crs = 4326)
#' img = system.file("img","Rlogo.png",package="png")
#' leaflet() %>%
#'   addTiles() %>%
#'   addCircleMarkers(data = pnt, group = "pnt") %>%
#'   addPopupImages(img, group = "pnt")
#' }
#'
#' @export addPopupImages
#' @name addPopupImages
#' @rdname addPopupImages
addPopupImages = function(map,
                          image,
                          group,
                          width = NULL,
                          height = NULL,
                          tooltip = FALSE,
                          ...) {

  drs = createTempFolder("images")

  pngs = lapply(1:length(image), function(i) {

    fl = image[[i]]

    if (file.exists(fl)) {
      src = "l"
      info = strsplit(
        sf::gdal_utils(
          util = "info",
          source = fl,
          quiet = TRUE
        ),
        split = "\n"
      )
      info = unlist(lapply(info, function(i) grep(utils::glob2rx("Size is*"), i, value = TRUE)))
      cols = as.numeric(strsplit(gsub("Size is ", "", info), split = ", ")[[1]])[1]
      rows = as.numeric(strsplit(gsub("Size is ", "", info), split = ", ")[[1]])[2]
      yx_ratio = rows / cols
      xy_ratio = cols / rows

      if (is.null(height) && is.null(width)) {
        width = cols
        height = yx_ratio * width
      } else if (is.null(height)) {
        height = yx_ratio * width
      } else if (is.null(width)) {
        width = xy_ratio * height
      } else {
        width = width
        height = height
      }

      nm = basename(fl)
      fls = file.path(drs, nm)
      invisible(file.copy(fl, file.path(drs, nm)))
    } else {
      src = "r"
      nm = fl
      width = width
      height = height
    }

    return(
      list(
        nm = nm
        , width = width
        , height = height
        , src = src
      )
    )

  })

  img = lapply(pngs, "[[", "nm")
  names(img) = basename(tools::file_path_sans_ext(image))
  name = names(img)
  local_images = img[file.exists(unlist(image))]
  width = lapply(pngs, "[[", "width")
  height = lapply(pngs, "[[", "height")
  src = lapply(pngs, "[[", "src")

  map$dependencies <- c(
    map$dependencies,
    list(
      htmltools::htmlDependency(
        "popup",
        '0.0.1',
        system.file("htmlwidgets", package = "leafpop"),
        script = c("popup.js")
      )
    ),
    list(
      htmltools::htmlDependency(
        paste0("image", "-", group),
        "0.0.1",
        drs,
        attachment = local_images
      )
    )
  )

  img_dep_id = grep(paste0("image", "-", group), map$dependencies)
  img_dep_ln = lengths(sapply(map$dependencies[img_dep_id], "[[", "attachment"))
  img_dep_id = img_dep_id[img_dep_ln > 0]
  img_dep_id = img_dep_id[!is.na(img_dep_id)]
  if (length(img_dep_id) > 1) {
    map$dependencies[[img_dep_id[1]]] =
      utils::modifyList(map$dependencies[[img_dep_id[1]]],
                        map$dependencies[[img_dep_id[2]]],
                        keep.null = TRUE)
    map$dependencies[[img_dep_id[2]]] = map$dependencies[[img_dep_id[1]]]
  }
  map$dependencies = map$dependencies[!duplicated(map$dependencies)]

  dotlist = utils::modifyList(
    list(
      "maxWidth" = 2000
    )
    , list(...)
  )

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'imagePopup',
    unname(img),
    group,
    width,
    height,
    src,
    as.list(name),
    tooltip,
    dotlist
  )
}
