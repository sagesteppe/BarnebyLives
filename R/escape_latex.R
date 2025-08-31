#' escape characters for use with latex rendering

escape_latex <- function(x) {
  if(is.na(x) || is.null(x)) return("")
  x <- gsub("&", "\\\\&", x)      # Escape &
  x <- gsub("%", "\\\\%", x)      # Escape %
  x <- gsub("\\$", "\\\\$", x)    # Escape $
  x <- gsub("#", "\\\\#", x)      # Escape #
  x <- gsub("\\^", "\\\\textasciicircum{}", x)  # Escape ^
  x <- gsub("_", "\\\\_", x)      # Escape _
  x <- gsub("\\{", "\\\\{", x)    # Escape {
  x <- gsub("\\}", "\\\\}", x)    # Escape }
  x <- gsub("~", "\\\\textasciitilde{}", x)     # Escape ~
  return(x)
}
