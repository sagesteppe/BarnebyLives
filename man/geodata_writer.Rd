% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geodata_writer.R
\name{geodata_writer}
\alias{geodata_writer}
\title{write out spatial data for collections to Google Earth or QGIS}
\usage{
geodata_writer(x, path, filename, filetype)
}
\arguments{
\item{x}{a data frame(/sf/tibble) which has at least undergone the 'dms2dd' and 'coords2sf' functions from BarnebyLives.}

\item{path}{a location to save the data to. If not supplied defaults to the current working directory.}

\item{filename}{name of file. if not supplied defaults to appending todays date to 'Collections'}

\item{filetype}{a file format to save the data to. This is a wrapper for sf::st_write and will support all drivers used there. If not supplied defaults to kml for use with Google Earth.}
}
\description{
This function will write out a simple labeled vector data (ala a 'shapefile') containing just collection number.
More data (e.g. species) can be written out using sf::st_write directly. See ?sf those details.
The function defaults to writing Google Earth KML files because these can be viewed online without having to to have a local install of the program.
}
