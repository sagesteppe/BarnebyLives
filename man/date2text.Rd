% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date2text.R
\name{date2text}
\alias{date2text}
\title{take mdy format date and make it written herbarium label format}
\usage{
date2text(x)
}
\arguments{
\item{x}{a data frame with dates}
}
\description{
take the 'month day year' date format, popular in North America, and place it into a
museum compliant text format
}
\examples{
first50dates <- paste0(sample(3:9, size = 10, replace = TRUE), '-',
   sample(1:29, size = 10, replace = TRUE), '-',
   rep(2023, times = 10)
 )
head(first50dates)
first50dates <- date2text(first50dates)
head(first50dates)
}
