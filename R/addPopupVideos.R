# #' Add video popups to leaflet layers.
# #'
# #' @param map the \code{leaflet} map to add the popups to.
# #' @param video A character \code{vector} of file path(s) od the video files.
# #' @param group the map group to which the popups should be added.
# #' @param width the width of the video(s) in pixels.
# #' @param height the height of the video(s) in pixels.
# #'
# #' @return
# #' A \code{leaflet} map.
# #'
# #' @examples
# #' if (interactive()) {
# #'   library(leafpop)
# #'   library(leaflet)
# #'   library(sf)
# #'
# #'   brew1 = st_as_sf(breweries91)[1, ]
# #'
# #'   m = leaflet() %>%
# #'     addTiles() %>%
# #'     addCircleMarkers(data = brew1, group = "brew1")
# #'
# #'  vid_file = "https://www.tylermw.com/wp-content/uploads/2018/06/bigmeadweb2.mp4"
# #'  vid = tempfile(fileext = ".mp4")
# #'  download.file(vid_file, vid)
# #'
# #'  m %>%
# #'    addPopupVideos(vid, group = "brew1")
# #'
# #' }
# #'
# #' @export addPopupVideos
# #' @name addPopupVideos
# #' @rdname addPopupVideos
# addPopupVideos = function(map, video, group, width = NULL, height = NULL) {
#
#   drs = createTempFolder("videos")
#
#   vdos = lapply(1:length(video), function(i) {
#
#     fl = video[[i]]
#
#     nm = basename(fl)
#     fls = file.path(drs, nm)
#     invisible(file.copy(fl, file.path(drs, nm)))
#     width = width
#     height = height
#
#     return(list(nm = nm, width = width, height = height))
#
#   })
#
#   vdo = lapply(vdos, "[[", "nm")
#   names(vdo) = basename(tools::file_path_sans_ext(video))
#   name = names(vdo)
#   local_videos = vdo[file.exists(unlist(video))]
#   width = lapply(vdos, "[[", "width")
#   height = lapply(vdos, "[[", "height")
#   # src = lapply(vdos, "[[", "src")
#
#   map$dependencies <- c(
#     map$dependencies,
#     list(
#       htmltools::htmlDependency(
#         "popup",
#         '0.0.1',
#         system.file("htmlwidgets", package = "leafpop"),
#         script = c("popup.js")
#       )
#     ),
#     list(
#       htmltools::htmlDependency(
#         "video",
#         "0.0.1",
#         drs,
#         attachment = local_videos
#       )
#     )
#   )
#
#   vdo_dep_id = grep("video", map$dependencies)
#   vdo_dep_ln = lengths(sapply(map$dependencies[vdo_dep_id], "[[", "attachment"))
#   vdo_dep_id = vdo_dep_id[vdo_dep_ln > 0]
#   vdo_dep_id = vdo_dep_id[!is.na(vdo_dep_id)]
#   if (length(vdo_dep_id) > 1) {
#     map$dependencies[[vdo_dep_id[1]]] =
#       utils::modifyList(map$dependencies[[vdo_dep_id[1]]],
#                         map$dependencies[[vdo_dep_id[2]]],
#                         keep.null = TRUE)
#     map$dependencies[[vdo_dep_id[2]]] = map$dependencies[[vdo_dep_id[1]]]
#   }
#   map$dependencies = map$dependencies[!duplicated(map$dependencies)]
#
#   leaflet::invokeMethod(
#     map,
#     leaflet::getMapData(map),
#     'videoPopup',
#     unname(vdo),
#     group,
#     width,
#     height,
#     as.list(name)
#   )
# }
#
