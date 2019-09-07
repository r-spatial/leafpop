listPopupTemplates = function(x, row_index = TRUE) {

  nms = colnames(x)
  id_crd = nms == "Feature ID"
  id_val = !id_crd

  out = data.frame(matrix(ncol = ncol(x), nrow = nrow(x)))
  colnames(out) = nms
  if (any(id_crd)) {
    out[, id_crd] = brewPopupCoords(nms[id_crd], x[, id_crd])
  }
  out[, id_val] = matrix(brewPopupRow(which(id_val), nms[id_val], t(x[, id_val])
                                      , row_index)
                         , ncol = sum(id_val), byrow = TRUE)

  args = c(out, sep = "")
  out = do.call(paste, args)

  # as.character(vsub("<%=pop%>", out, createTemplate(), perl = TRUE))
  sprintf(createTemplate(), out)

  # vapply(out, gsub, "chracter", x = createTemplate()
  #        , pattern = "<%=pop%>", USE.NAMES = FALSE)
}

vsub = Vectorize(gsub)

brewPopupCoords = function(colname, value) {
  ind_string = "<td></td>"
  # col_string = paste0("<td><b>", colname, "</b></td>")
  # val_string = paste0("<td align='right'>", value, "&emsp;</td>")
  # out_string = paste0("<tr class='coord'>", ind_string, col_string, val_string, "</tr>")
  col_string = sprintf("<td><b>%s</b></td>", colname)
  val_string = sprintf("<td align='right'>%s&emsp;</td>", value)
  out_string = sprintf("<tr class='coord'>%s%s%s</tr>", ind_string, col_string, val_string)

  return(out_string)
}

brewPopupRow = function(index, colname, value, row_index = TRUE) {
  # ind_string = if (row_index) {
  #   paste0("<td>", index - 1, "</td>")
  # } else {
  #   "<td></td>"
  # }
  # col_string = paste0("<td><b>", colname, "&emsp;</b></td>")
  # val_string = paste0("<td align='right'>", value, "&emsp;</td>")
  #
  # out_string = paste0("<tr", ifelse(index %% 2 == 0, " class=\'alt\'>", ">")
  #                     , ind_string, col_string, val_string, "</tr>")
  ind_string = if (row_index) {
    sprintf("<td>%s</td>", index - 1)
  } else {
    "<td></td>"
  }
  col_string = sprintf("<td><b>%s&emsp;</b></td>", colname)
  val_string = sprintf("<td align='right'>%s&emsp;</td>", value)

  row_class = paste0("<tr", ifelse(index %% 2 == 0, " class=\'alt\'>%s%s%s</tr>",
                                   ">%s%s%s</tr>"))

  out_string = sprintf(row_class, ind_string, col_string, val_string)

  return(out_string)
}

createTemplate = function() {
  gsub("\\n", ""
       , '<html>
<head>
<link rel="stylesheet" type="text/css" href="lib/popup/popup.css">
</head>

<body>

<div class="scrollableContainer">
<table class="popup scrollable" id="popup">

%s

</table>
</div>
</body>
</html>
')
}
