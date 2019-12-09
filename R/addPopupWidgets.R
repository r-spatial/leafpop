# addPopupWidgets = function(map, widget, group, width = 300, height = 300) {
#
#   widget = list(widget)
#
#   wdgts = lapply(seq_along(widget), function(i) {
#
#     if (inherits(widget[[i]], "htmlwidget")) {
#       drs = createTempFolder("widgets")
#       flnm = basename(tempfile(fileext = ".html"))
#       libdir = paste0(tools::file_path_sans_ext(flnm), "_files")
#       fl = paste(drs, flnm, sep = "/")
#       htmlwidgets::saveWidget(
#         widget = widget[[i]],
#         file = fl,
#         libdir = libdir
#       )
#     }
#
#     return(fl)
#
#   })
#
#   addPopupIframes(map, wdgts, group)
# }
