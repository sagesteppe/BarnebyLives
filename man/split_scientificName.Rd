% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/split_scientificName.R
\name{split_scientificName}
\alias{split_scientificName}
\title{split out a scientific input column to pieces}
\usage{
split_scientificName(x, sciName_col, overwrite)
}
\arguments{
\item{x}{a dataframe with collection information}

\item{sciName_col}{column containing the data to parse}
}
\description{
This function attempts to split a scientific name into it's component pieces.
Given an input scientific, or scientific with scientific authorities and infraspecies
this function will parse them into the columns used in the BarnebyLives pipeline.
}
\examples{
library(BarnebyLives)
ce <- collection_examples
ce <- data.frame(
  Collection_number = ce$Collection_number[sample(1:nrow(ce), size = 100, replace = F)],
  Binomial = c(ce$Full_name, ce$Name_authority)[sample(1:nrow(ce)*2, size = 100, replace = F)],
  Binomial_authority = ce$Binomial_authority[sample(1:nrow(ce), size = 100, replace = F)]
) # extra columns to challenge name search - values are meaningless

split_scientificName(ce)|> head()
split_scientificName(ce, sciName_col = 'Binomial') |> head()
}
