#' return a quick route summary from googleway::google_directions
#'
#' This function creates a quick abstract of a google maps route, which contains the travel time, starting location and the route overview.
#' @param x results from a googleway::google_directions API query
#' @example
#' df <- google_directions(origin = "Burns, Oregon",
#'  destination = "42.825, -118.913",  key = SoS_gkey,  mode = "driving",
#'                        simplify = TRUE)
#' directions_overview(df)
#' @export
directions_overview <- function(x){
  # google maps name for starting location
  from <- gsub("(.*)[0-9]{5}.*", "\\1", x[["routes"]][["legs"]][[1]][["start_address"]])
  from <- paste('from', gsub(' $|,', '', from))

  # main route overview,
  summary <- x[["routes"]][["summary"]]

  # expected drive time
  time <- sum ( x[["routes"]][["legs"]][[1]][["steps"]][[1]][["duration"]][["value"]] ) / 60

  time <- ceiling( sum( time, (time * 0.05)) / 10 ) * 10 # pad in some extra time 5%
  hour <- floor(time/60)
  minutes <- time %% 60

  if(hour > 0 & minutes != 0){ # an hour or many and change
    overview <- paste0(hour, '.', (10 * round( (minutes / 60), 1)),
                       ' hrs ', from, ' via ', summary, '.')
  } else if (hour == 1 & minutes == 0){ # one hour flat
    overview <- paste0(hour, ' hr ', from, ' via ', summary, '.')
  } else if (hour >= 1 & minutes == 0){  # multiple hours flat
    overview <- paste0(hour, ' hrs ', from, ' via ', summary, '.')
  } else { # less than one hour.
    overview <- paste0(minutes, 'mins ', from, ' via ', summary, '.')
  }

  return(overview)

}
