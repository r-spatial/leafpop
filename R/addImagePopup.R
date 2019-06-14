addPopupImage = function(map, img, group, width = NULL, height = NULL) {

  drs = file.path(tempdir(), "images")
  if (!dir.exists(drs)) dir.create(drs)

  pngs = lapply(1:length(img), function(i) {

    fl = img[[i]]

    # info = strsplit(
    #   sf::gdal_utils(
    #     util = "info",
    #     source = fl,
    #     quiet = TRUE
    #   ),
    #   split = "\n"
    # )
    info = sapply(fl, function(...) gdalUtils::gdalinfo(...))
    info = unlist(lapply(info, function(i) grep(utils::glob2rx("Size is*"), i, value = TRUE)))
    cols = as.numeric(strsplit(gsub("Size is ", "", info), split = ", ")[[1]])[1]
    rows = as.numeric(strsplit(gsub("Size is ", "", info), split = ", ")[[1]])[2]
    yx_ratio = rows / cols
    xy_ratio = cols / rows

    if (is.null(height) && is.null(width)) {
      width = 300
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

    return(list(nm = nm, width = width, height = height))

  })

  image = lapply(pngs, "[[", "nm")
  width = lapply(pngs, "[[", "width")
  height = lapply(pngs, "[[", "height")

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
        "image",
        "0.0.1",
        drs,
        attachment = unlist(image)
      )
    )
  )

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'imagePopup',
    image,
    group,
    width,
    height
  )
}
