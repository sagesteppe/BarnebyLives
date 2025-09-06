#' escape characters for use with latex rendering

escape_latex <- function(x) {
  if (is.null(x)) {
    return("")
  }
  x[is.na(x)] <- ""

  x <- gsub("\\\\", "\\\\textbackslash{}", x) # Escape backslash

  x <- gsub("&", "\\\\&", x)
  x <- gsub("%", "\\\\%", x)
  x <- gsub("\\$", "\\\\$", x)
  x <- gsub("#", "\\\\#", x)
  x <- gsub("\\^", "\\\\textasciicircum{}", x)
  x <- gsub("_", "\\\\_", x)
  x <- gsub("\\{", "\\\\{", x)
  x <- gsub("\\}", "\\\\}", x)
  x <- gsub("~", "\\\\textasciitilde{}", x)

  return(x)
}
