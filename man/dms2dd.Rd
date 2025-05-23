% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dms2dd.R
\name{dms2dd}
\alias{dms2dd}
\title{this function parses coordinates from DMS to decimal degrees}
\usage{
dms2dd(x, lat, long, dms)
}
\arguments{
\item{x}{an input data frame to apply operations too}

\item{lat}{a name of the column holding the latitude values}

\item{long}{a name of the colymn holding the longitude values}

\item{dms}{are coordinates in degrees minutes seconds? TRUE for yes, FALSE for decimal degrees}
}
\value{
data frame(/tibble) with coordinates unambiguously labeled as being in both degrees, minutes, seconds (_dms) and decimal degrees (_dd).
}
\description{
this function parses coordinates from DMS to decimal degrees
}
\examples{
 coords <- data.frame(
  longitude_dd = runif(15, min = -120, max = -100),
  latitude_dd = runif(15, min = 35, max = 48)
)
coords_formatted <- dms2dd( coords )
head(coords_formatted)
colnames(coords_formatted)
}
