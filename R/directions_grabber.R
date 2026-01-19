#' Have Google maps help you write directions to a site
#'
#' This function helps users write directions to a site which is somewhat near roads.
#' @param x an sf/tibble/data frame of locations
#' @param api_key a Google developer api key for use with googleway
#' @examples # see package vignette
#' @export
directions_grabber <- function(x, api_key) {

  if (missing(api_key) || is.null(api_key)) {
    stop("api_key is required")
  }
  
  required_cols <- c("latitude_dd", "longitude_dd", "Site")
  if (!all(required_cols %in% names(x))) {
    stop("Input must contain columns: ", paste(required_cols, collapse = ", "))
  }

  # identify unique sites
  sites <- split(x, f = list(x$latitude_dd, x$longitude_dd), drop = TRUE)
  sites <- lapply(sites, '[', 1, )

  sites_names <- do.call(rbind, lapply(sites, '[', 'Site'))
  # retrieve the site name
  sitename <- paste(
    ' Head to',
    gsub('^ ', '', gsub('^.*from', '', sites_names$Site))
  )

  # gather results from API
  test_gq <- get_google_directions(sites, api_key = api_key)

  # extract an overview of the directions as well as the specifics
  dir_over <- lapply(test_gq, directions_overview) |> unlist()

  dir_specific <- vector(mode = 'list', length = length(test_gq))
  for (i in seq(test_gq)) {
    # some areas google says NO! to, handle them here.
    if (dir_over[i] == '0mins from  via .') {
      dir_over[i] <- 'Google will not'
      dir_specific[i] <- "give results"
    } else {
      dir_specific[i] <- specificDirections(test_gq[[i]])
    }
  }
  dir_specific <- unlist(dir_specific)

  sites_out <- do.call(rbind, sites)
  sites_out <- sites_out[, c('latitude_dd', 'longitude_dd')]
  sites_out <- sf::st_drop_geometry(sites_out)
  sites_out$Directions_BL = paste0(dir_over, ' ', dir_specific, sitename)
  out <- dplyr::left_join(
    x,
    sites_out,
    by = c('latitude_dd', 'longitude_dd')
  ) |>
    dplyr::relocate(Directions_BL, .before = geometry) |>
    dplyr::mutate(Directions_BL = gsub('#', 'No.', Directions_BL))
}
