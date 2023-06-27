
#' Import Google directions to a site
#' 
#' Use Google Maps to write directions to a site, so that the people re-locating 
#' the site don't need to use Google Maps to write directions to a site. These
#' are crude and will require some refinement for some relevant applications. 
#' @param x the output of directions_grabber
#' @example 
#' SoS_gkey = Sys.getenv("Sos_gkey")
#' df <- google_directions(origin = "Reno, Nevada",
#"                        destination = "39.2558, -117.6827",
#'                        key = SoS_gkey,
#'                        mode = "driving",
#'                        simplify = TRUE)
#' specificDirections(df)
#' @export 
specificDirections <- function(x){
  
  cleanFun <- function(x) {
    y <- gsub("<.*?>", "", x)
    y <- gsub('Pass by Burger King.*$', "", y)
    y <- gsub('Destination will be on.*$', "", y)
    y <- gsub('onto', 'on', y)
    y <- gsub('Continue', "Con't", y)
    y <- gsub('continue', "con't", y)
    y <- gsub(' and becomes .*$', '', y)
    y <- gsub(' right ', ' R ', y)
    y <- gsub(' left ', ' L ', y)
    y <- gsub('BUS', '', y)
    y <- gsub('ALT', 'Alt', y)
    return(y)
  }

  dirStartEnd <- function(x){
    y <- gsub('^Continue onto ', 'Take ', x)
    y <- gsub('^Take the ramp onto ', 'Take ', x)
    y <- trimws(y)
    return(y)
  }
  
  dist <- df[['routes']][['legs']][[1]][['steps']][[1]]$distance
  dist <- data.frame(
    distance = dist$value, 
    t_dist = sum(dist['value'] ), 
    c_dist = cumsum(dist['value']) / sum(dist['value']) * 100,
    dist_mi = round(dist$value * 0.000621371, 1)
  )
  distances <- dist[ which(dist$value > 1), ]

  instruct <- df[['routes']][['legs']][[1]][['steps']][[1]]$html_instructions
  instruct <- instruct[ which(dist$value > 1) ]
  instruct <- cleanFun(instruct) # need to pad destination. 
  
  directionsString <- paste(instruct, distances$dist_mi, 'mi. ', collapse = "") 
  directionsString <- dirStartEnd(directionsString)
  
  return(directionsString)
}
