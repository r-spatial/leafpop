% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/graph.R, R/image.R, R/table.R
\name{popupGraph}
\alias{popupGraph}
\alias{popupImage}
\alias{popupTable}
\title{Create HTML strings for popups}
\usage{
popupGraph(
  graphs,
  type = c("png", "svg", "html"),
  width = 300,
  height = 300,
  selfcontained = TRUE,
  ...
)

popupImage(img, src = c("local", "remote"), embed = FALSE, ...)

popupTable(x, zcol, row.numbers = TRUE, feature.id = TRUE, className = NULL)
}
\arguments{
\item{graphs}{A \code{list} of figures associated with \code{x}.}

\item{type}{Output filetype, one of "png" (default), "svg" or "html".}

\item{width}{popup width in pixels.}

\item{height}{popup height in pixels.}

\item{selfcontained}{Whether to save the HTML as a single self-contained file (with external resources base64 encoded) or a file with external resources placed in an adjacent directory. Only for filetype "html"}

\item{...}{further arguments passed on to underlying methods such as
height and width.}

\item{img}{A character \code{vector} of file path(s) or
web-URL(s) to any sort of image file(s).}

\item{src}{Whether the source is "local" (i.e. valid file path(s)) or
"remote" (i.e. valid URL(s)).}

\item{embed}{whether to embed the (local) images in the popup html as
base64 ecoded. Set this to TRUE if you want to save and share your map, unless
you want render many images, then set to FALSE and make sure to copy ../graphs
when copying the map to a different location.}

\item{x}{A \code{data.frame}, \code{sf}, \code{SpatVector} or \code{Spatial*} object.}

\item{zcol}{\code{numeric} or \code{character} vector indicating the columns
included in the output popup table. If missing, all columns are displayed.}

\item{row.numbers}{\code{logical} whether to include row numbers in the popup table.}

\item{feature.id}{\code{logical} whether to add 'Feature ID' entry to popup table.}

\item{className}{CSS class name(s) that can be used to style the table through
additional css dependencies (see \link[htmltools]{attachDependencies}).}
}
\value{
A \code{list} of HTML strings required to create popup graphs.

A \code{list} of HTML strings required to create popup graphs.

A \code{list} of HTML strings required to create feature popup tables.
}
\description{
Create HTML strings for \code{popup} graphs used as input for
\code{mapview} or \code{leaflet}.

Create HTML strings for \code{popup} images used as input for
\code{mapview} or \code{leaflet}.

Create HTML strings for \code{popup} tables used as input for
\code{mapview} or \code{leaflet}.
This optionally allows the user to include only a subset of feature attributes.
}
\details{
Type \code{svg} uses native \code{svg} encoding via \code{\link{readLines}}.
\code{height} and \code{width} are set via \code{...} and passed on to
\code{\link{svg}} \cr
Type \code{png} embeds via \code{"<img src = ..."}.
\code{height} and \code{width} are set via \code{...} and passed on to
\code{\link{png}} \cr
Type \code{html} embeds via \code{"<iframe src = ..."}.
\code{height} and \code{width} are set directly in pixels. \cr
}
\examples{
if (interactive()) {
### example: svg -----

library(sp)
library(lattice)

data(meuse)
coordinates(meuse) = ~ x + y
proj4string(meuse) = CRS("+init=epsg:28992")
meuse = spTransform(meuse, CRS("+init=epsg:4326"))

## create plots with points colored according to feature id
library(lattice)
p = xyplot(copper ~ cadmium, data = meuse@data, col = "grey")
p = mget(rep("p", length(meuse)))

clr = rep("grey", length(meuse))
p = lapply(1:length(p), function(i) {
  clr[i] = "red"
  update(p[[i]], col = clr)
})

leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = meuse, popup = popupGraph(p, type = "svg"))

### example: png -----
pt = data.frame(x = 174.764474, y = -36.877245)

coordinates(pt) = ~ x + y
proj4string(pt) = "+init=epsg:4326"

p2 = levelplot(t(volcano), col.regions = terrain.colors(100))

leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = pt, popup = popupGraph(p2, width = 300, height = 400))

### example: html -----
leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(
    data = breweries91[1, ],
    popup = popupGraph(
      leaflet() \%>\%
        addProviderTiles("Esri.WorldImagery") \%>\%
        addMarkers(data = breweries91[1, ],
                   popup = popupTable(breweries91[1, ])),
     type = "html"
    )
  )

}

if (interactive()) {
## remote images -----
### one image
library(sf)

pnt = st_as_sf(data.frame(x = 174.764474, y = -36.877245),
                coords = c("x", "y"),
                crs = 4326)

img = "http://bit.ly/1TVwRiR"

leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = pnt, popup = popupImage(img, src = "remote"))

### multiple file (types)
library(sp)
images = c(img,
            "https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg",
            "https://www.r-project.org/logo/Rlogo.png",
            "https://upload.wikimedia.org/wikipedia/commons/d/d6/MeanMonthlyP.gif")

pt4 = data.frame(x = jitter(rep(174.764474, 4), factor = 0.01),
                  y = jitter(rep(-36.877245, 4), factor = 0.01))
coordinates(pt4) = ~ x + y
proj4string(pt4) = "+init=epsg:4326"

leaflet() \%>\%
  addTiles() \%>\%
  addMarkers(data = pt4, popup = popupImage(images)) # NOTE the gif animation

## local images -----
pnt = st_as_sf(data.frame(x = 174.764474, y = -36.877245),
                coords = c("x", "y"), crs = 4326)
img = system.file("img","Rlogo.png",package="png")
leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = pnt, popup = popupImage(img))
}

library(leaflet)

leaflet() \%>\% addTiles() \%>\% addCircleMarkers(data = breweries91)

leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = breweries91,
                   popup = popupTable(breweries91))

leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = breweries91,
                   popup = popupTable(breweries91,
                                      zcol = c("brewery", "zipcode", "village"),
                                      feature.id = FALSE,
                                      row.numbers = FALSE))

## using a custom css to style the table
className = "my-popup"

css = list(
  "background" = "#ff00ff"
)

css = list(css)
names(css) = sprintf("table.\%s", className)

evenodd = list("#ffff00", "#00ffff")
names(evenodd) = rep("background", 2)

evenodd = lapply(evenodd, function(i) {
  list("background" = i)
})

names(evenodd) = c(
  sprintf("table.\%s tr:nth-child(even)", className)
  , sprintf("table.\%s tr:nth-child(odd)", className)
)

lst = append(css, evenodd)

jnk = Map(function(...) do.call(htmltools::css, ...), lst)

dir = tempfile()
dir.create(dir)
fl = file.path(dir, "myCSS.css")

cat(
  sprintf(
    "\%s{ \n  \%s\n}\n\n"
    , names(jnk)
    , jnk
  )
  , sep = ""
  , file = fl
)

mymap = leaflet() \%>\%
  addTiles() \%>\%
  addCircleMarkers(data = breweries91,
                   popup = popupTable(breweries91, className = className))

addMyCSSDependency = function() {
  list(
    htmltools::htmlDependency(
      name = "mycss"
      , version = "0.0.1"
      , src = dir
      , stylesheet = basename(fl)
    )
  )
}

mymap$dependencies = c(
  mymap$dependencies
  , addMyCSSDependency()
)

mymap


}
