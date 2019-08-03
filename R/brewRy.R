listPopupTemplatesR = function(x, names, row_index = TRUE) {

  id_crd = names == "Feature ID"
  id_val = !id_crd

  out = setNames(data.frame(matrix(ncol = ncol(x), nrow = nrow(x))), names)
  if (any(id_crd)) {
    out[, id_crd] = brewPopupCoordsR(names[id_crd], x[, id_crd])
  }
  out[, id_val] = matrix(brewPopupRowR(which(id_val), names[id_val], t(x[, id_val]) # test for 1-column
                                       , row_index)
                         , ncol = sum(id_val), byrow = TRUE)

  args = c(out, sep = "")
  out = do.call(paste, args)

  vsub = Vectorize(gsub)
  as.character(vsub("<%=pop%>", out, createTemplateR()))
}

brewPopupCoordsR = function(colname, value) {
  ind_string = "<td></td>"
  col_string = paste0("<td><b>", colname, "</b></td>")
  val_string = paste0("<td align='right'>", value, "&emsp;</td>")
  out_string = paste0("<tr class='coord'>", ind_string, col_string, val_string, "</tr>")

  return(out_string)
}

brewPopupRowR = function(index, colname, value, row_index = TRUE) {
  ind_string = if (row_index) {
    paste0("<td>", index - 1, "</td>")
  } else {
    "<td></td>"
  }
  col_string = paste0("<td><b>", colname, "&emsp;</b></td>")
  val_string = paste0("<td align='right'>", value, "&emsp;</td>")

  out_string = paste0("<tr", ifelse(index %% 2 == 0, " class=\'alt\'>", ">")
                      , ind_string, col_string, val_string, "</tr>")

  return(out_string)
}

createTemplateR = function() {
  gsub("\\n", ""
       , '<html>
<head>
<link rel="stylesheet" type="text/css" href="lib/popup/popup.css">
</head>

<body>

<div class="scrollableContainer">
<table class="popup scrollable" id="popup">

<%=pop%>

</table>
</div>
</body>
</html>
')
}
