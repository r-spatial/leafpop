addPopupImages = function(map, img, group, width = NULL, height = NULL) {

  drs = file.path(tempdir(), "images")
  if (!dir.exists(drs)) dir.create(drs)

  pngs = lapply(1:length(img), function(i) {

    fl = img[[i]]

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

    return(list(nm = nm, width = width, height = height, src = src))

  })

  image = lapply(pngs, "[[", "nm")
  names(image) = basename(tools::file_path_sans_ext(img))
  name = names(image)
  local_images = image[file.exists(unlist(img))]
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
        "image",
        "0.0.1",
        drs,
        attachment = local_images
      )
    )
  )

  img_dep_id = grep("image", map$dependencies)
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

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'imagePopup',
    unname(image),
    group,
    width,
    height,
    src,
    as.list(name)
  )
}
