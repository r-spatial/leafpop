# StringVector listPopupTemplates(CharacterMatrix x, CharacterVector names,
#                                 std::string tmpPath, bool rowIndex) {
#
#   // number of rows and columns
#   int nRows = x.nrow();
#   int nCols = x.ncol();
#
#   // intermediary variables
#   CharacterVector chVal(nCols);
#   std::string chStr;
#
#   // output list
#   StringVector lsOut(nRows);
#
#   // import template
#   std::string chTemplate = createTemplate(tmpPath);
#   String chTmp = chTemplate;
#
#   // create strings for each single row
#   for (int i = 0; i < nRows; i++) {
#     chVal = enc2utf8_chrvec(x(i, _));
#     chStr = mergePopupRows(names, chVal, rowIndex);
#
#     chTmp = gsubC("<%=pop%>", chStr, chTmp);
#     lsOut[i] = enc2utf8_string(chTmp);
#
#     // reset intermediary string
#     chTmp = chTemplate;
#   }
#
#   return lsOut;
# }

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

  # classes = rep(ifelse(index %% 2 == 0, " class=\'alt\'>", ">")
  #               , each = ratio <- length(val_string) / length(index))
  # indexes = rep(ind_string, each = ratio)
  # colnames = rep(col_string, each = ratio)

  out_string = paste0("<tr", ifelse(index %% 2 == 0, " class=\'alt\'>", ">"), ind_string, col_string, val_string, "</tr>")

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

# mergePopupRowsR = function(names, values, row_index = TRUE, id_crd, id_val = !id_crd) {
#
#   out = character(length(names))
#   out[id_crd] = brewPopupCoordsR(names[id_crd], values[id_crd])
#   out[id_val] = brewPopupRowR(which(id_val), names[id_val], values[id_val], row_index)
#
#   return(paste(out, collapse = ""))
# }

