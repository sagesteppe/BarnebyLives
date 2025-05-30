% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_database_import.R
\name{format_database_import}
\alias{format_database_import}
\title{Export a spreadsheet for mass upload to an herbariums database}
\usage{
format_database_import(x, format)
}
\arguments{
\item{x}{data frame holding the final output from BarnebyLives}

\item{format}{a character vector indicating which database to create output for.}
}
\description{
Only a few schemas are currently supported, but we always seek to add more.
}
\examples{
library(BarnebyLives)
dat4import <- format_database_import(collection_examples, format = 'JEPS')

# we also know a bit about our material and can populate it here by hand #
dat4import |>
  dplyr::mutate(
   Label_Footer = 'Collected under the auspices of the Bureau of Land Management',
   Coordinate_Uncertainty_In_Meters = 5,
    Coordinate_Source = 'iPad')

}
