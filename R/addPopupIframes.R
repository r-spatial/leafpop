addPopupIframes = function(map, source, group, width = 300, height = 300) {

  drs = createTempFolder("iframes")

  srcs = lapply(1:length(source), function(i) {

    fl = source[[i]]

    if (file.exists(fl)) {
      src = "l"
      width = width
      height = height
      nm = basename(fl)
      fls = file.path(drs, nm)
      invisible(file.copy(fl, file.path(drs, nm)))
      from_dir = paste0(tools::file_path_sans_ext(fl), "_files")
      if (dir.exists(from_dir)) {
        invisible(
          file.copy(
            from = from_dir,
            to = drs,
            recursive = TRUE
          )
        )
      }
    } else {
      src = "r"
      nm = fl
      width = width
      height = height
    }

    return(list(nm = nm, width = width, height = height, src = src))

  })

  nms = lapply(srcs, "[[", "nm")
  names(nms) = basename(tools::file_path_sans_ext(source))
  name = names(nms)
  local_sources = nms[file.exists(unlist(source))]
  width = lapply(srcs, "[[", "width")
  height = lapply(srcs, "[[", "height")
  src = lapply(srcs, "[[", "src")

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
        "iframe",
        "0.0.1",
        drs,
        attachment = local_sources
      )
    )
  )

  src_dep_id = grep("ifrme", map$dependencies)
  src_dep_ln = lengths(sapply(map$dependencies[src_dep_id], "[[", "attachment"))
  src_dep_id = src_dep_id[src_dep_ln > 0]
  src_dep_id = src_dep_id[!is.na(src_dep_id)]
  if (length(src_dep_id) > 1) {
    map$dependencies[[src_dep_id[1]]] =
      utils::modifyList(map$dependencies[[src_dep_id[1]]],
                        map$dependencies[[src_dep_id[2]]],
                        keep.null = TRUE)
    map$dependencies[[src_dep_id[2]]] = map$dependencies[[src_dep_id[1]]]
  }
  map$dependencies = map$dependencies[!duplicated(map$dependencies)]

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'iframePopup',
    unname(nms),
    group,
    width,
    height,
    src,
    as.list(name)
  )
}
