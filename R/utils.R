createTempFolder = function(basename, ndigits = 6) {
  id = paste(sample(c(letters[1:6], 0:9), ndigits), collapse = "")
  drs = file.path(tempdir(), paste0(basename, id))
  if (!dir.exists(drs)) dir.create(drs)
  return(invisible(drs))
}
