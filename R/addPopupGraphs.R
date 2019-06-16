addPopupGraphs = function(map, grph, group, width = 300, height = 300) {

  imgs = lapply(seq_along(grph), function(i) {
    fl = tempfile(fileext = ".png")
    grDevices::png(filename = fl, width = width, height = height, units = "px")
    print(grph[[i]])
    dev.off()
    return(fl)
  })

  addPopupImages(map, imgs, group)
}
