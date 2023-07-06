
#' Import Google directions to a site
#'
#' Use Google Maps to write directions to a site, so that the people re-locating
#' the site don't need to use Google Maps to write directions to a site. These
#' are crude and will require some refinement for some relevant applications.
#' This function operates entirely within 'directions_grabber'
#' @param x the output of directions_grabber
#' @examples # see 'directions_grabber'#
#' @export
specificDirections <- function(x){

  strip_html <- function(x) {
    rvest::html_text(rvest::read_html(charToRaw(x)))
  }

  cleanFun <- function(x) {
    y <- gsub('Pass by Burger King.*$', "", x)
    y <- gsub('Destination will be on.*$', "", y)
    y <- gsub('onto', 'on', y)
    y <- gsub('Continue', "Con't", y)
    y <- gsub('continue', "con't", y)
    y <- gsub( " [A-z].*Con't", " Con't", y)
    y <- gsub(' and becomes .*$', '', y)
    y <- gsub(' right ', ' R ', y)
    y <- gsub(' left ', ' L ', y)
    y <- gsub('BUS', '', y)
    y <- gsub("Turn Con't", "Con't", y)
    y <- gsub('ALT', 'Alt', y)
    y <- gsub("Con't Con't", "Con't", y)
    return(y)
  }

  dirStartEnd <- function(x){
    y <- gsub('^Continue onto ', 'Take ', x)
    y <- gsub('^Take the ramp onto ', 'Take ', y)
    y <- gsub("^Head Con't to follow", 'Follow', y)
    y <- gsub(" 0 mi", "", y)
    y <- gsub('Pass by .*[)]', '', y)
    y <- trimws(y)
    return(y)
  }

  dist <- x[['routes']][['legs']][[1]][['steps']][[1]]$distance
  dist <- data.frame(
    distance = dist$value,
    t_dist = sum(dist['value'] ),
    c_dist = cumsum(dist['value']) / sum(dist['value']) * 100,
    dist_mi = round(dist$value * 0.000621371, 1)
  )

  if(nrow(dist) > 5 ){
    distances <- dist[which(dist$value > 1), ]
  } else {
    distances <- dist
  }

  instruct <- x[['routes']][['legs']][[1]][['steps']][[1]]$html_instructions
  if(nrow(dist) > 5 ){
    instruct <- instruct[which(dist$value > 1) ]
  } else {
    instruct <- instruct
  }

  instruct <- vapply(instruct, FUN = strip_html, FUN.VALUE = 'character')
  instruct <- cleanFun(instruct) # need to pad destination.

  directionsString <- paste(instruct, distances$dist_mi, 'mi. ')
  directionsString <- paste0(directionsString, '. ',  collapse = "")
  directionsString <- gsub('. .', '.', directionsString, fixed = TRUE)
  directionsString <- dirStartEnd(directionsString)

  return(directionsString)
}

