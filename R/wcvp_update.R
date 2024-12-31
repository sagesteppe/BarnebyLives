#' install or update World Vascular Plants Checklist
#'
#' This function checks to see whether the version of WCVP is the most current,
#'  if not, it will re-download WCVP and set up the BL taxonomy structure.
#' @param tax_dat_p the path to the taxonomic data, the raw wcvp.zip should be there.
#' @examples \dontrun{
#' wcvp_update('/home/sagesteppe/Downloads')
#' }
#' @param export
wcvp_update <- function(tax_dat_p){

  url2wcvp <- "http://sftp.kew.org/pub/data-repositories/WCVP/"
  ### obtain the date of the current downloaded version ###

  if(length(list.files(file.path(tax_dat_p), pattern = 'wcvp.zip') == 1)){

  unzip(zipfile = file.path(tax_dat_p, 'wcvp.zip'), files = "README_WCVP.xlsx", exdir = tax_dat_p)
  date_extracted <- gsub('Extracted: ', '',
                         as.character(
                           suppressMessages(
                           readxl::read_xlsx(path = file.path(tax_dat_p, 'README_WCVP.xlsx'))[7,1]
                           )
                         )
  )
  file.remove(file.path(tax_dat_p, 'README_WCVP.xlsx'))

  date_extracted <- as.Date(date_extracted, format = '%d/%m/%Y')

  ### obtain the date of the most recent version on the web ###
  wcvp_pattern <- "wcvp[.]zip\\s*(.*?)\\s*wcvp_dwca[.]zip"
  date_pattern <- '20[0-9]{2}-[0-9]{2}-[0-9]{2}'

  content <-
    rvest::read_html(url2wcvp) |>
    rvest::html_element("body") |>
    rvest::html_element("pre") |>
    rvest::html_text2()

  date_uploaded <- unlist(regmatches(content, regexec(wcvp_pattern, content)))[1]
  date_uploaded <- regmatches(
    date_uploaded, gregexpr(date_pattern, date_uploaded, perl = TRUE))[[1]]
  date_uploaded <- as.Date(date_uploaded)

  rm(wcvp_pattern, date_pattern, content)

  dif <- as.numeric(date_uploaded - date_extracted) # difference in days.

  } else {dif <- 0} # has never been downloaded.


  if(dif > 14 | dif == 0){ # if two week or more difference,
    # re-download. 1st time i checked diff was 6 days

    orig_TO <- getOption("timeout") # save any local mods to timeout
    if(orig_TO < 420){ # allow users to set options in main env if need be.
      options(timeout = max(420, getOption("timeout")))} # 7 minute timeout
    download.file(url = paste0(url2wcvp, '/wcvp.zip'), destfile = file.path(tax_dat_p, 'wcvp.zip'))
    options(timeout = max(orig_TO, getOption("timeout"))) # revert to original settings

    cat(crayon::green('WCVP checklist downloaded to: ', tax_dat_p,
                      '\nuse the functionn `BarnebyLives::TaxUnpack` to initialize a new taxonomy backbone.'))

    rm(orig_TO)
  } else {cat(crayon::green('WCVP checklist does not appear to have been updated since last download, defaulting to current instance.'))}

}
