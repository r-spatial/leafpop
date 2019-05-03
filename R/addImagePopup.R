addImagePopup = function(map, image, group) {

  map$dependencies <- c(
    map$dependencies,
    list(
      htmltools::htmlDependency(
        "popup",
        '0.0.1',
        system.file("htmlwidgets", package = "leafpop"),
        script = c("popup.js")
      )
    )
  )

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'imagePopup',
    image,
    group
  )
}
