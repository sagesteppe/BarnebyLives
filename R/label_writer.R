#' write herbarium labels to pdf
#'
#' This function uses the BarnebyLives custom template to write labels ala
#' a mail merge. Each label will be written as a separate file with the dimensions
#' of 4x4 inches.
#' @param x a path to a csv of labels which have been cleaned with BL, and which the analyst
#' has evaluated for conflicts.
#' @param outdir an output directory to hold the files.
#' @example
#' label_writer(collection_examples, BL_label_example)
#' @export
label_writer <- function(x, outdir) {

  if(missing(outdir)){outdir <- file.path(getwd(), 'Labels') }
  if (!dir.exists(outdir)){ dir.create(outdir) }

	label_info <- read.csv(file = x) |>
	  dplyr::mutate(UNIQUEID = paste0(.$Primary_Collector, .$Collection_number))

	for (i in 1:nrow(label_info)){
  	rmarkdown::render(
  	  input = "Labels-skeleton.Rmd",
    	output_format = "pdf_document",
    	output_file = paste0(i$UNIQUEID, ".pdf"),
    	output_dir = outdir)
	}
}

