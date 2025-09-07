#' write values and collapse NAs
#'
#' This function will determine whether to print a variable onto labels or hide it
#' @param x the input character of length 1
#' @param italics italicize or not? Boolean, defaults to FALSE
#' @examples
#' writer(collection_examples[9,'Binomial_authority'] )
#' writer(collection_examples[9, 'Infraspecies'], italics = TRUE )
#' @export
writer <- function(x, italics) {
  x[x == ""] <- NA
  if (missing(italics)) {
    italics <- FALSE
  }
  if (is.na(x)) {
    ""
  } else if (italics == FALSE) {
    x
  } else {
    (paste0('\\textit{', x, '}'))
  }
}

#' write values and collapse NAs
#'
#' This function will determine whether to print a variable onto labels or hide it
#' @param x the input character of length 1
#' @param italics italicize or not? Boolean, defaults to FALSE
#' @param period Boolean, whether to add a period or not at end of string.
#' Defaults to FALSE.
#' @examples
#' writer(collection_examples[9,'Binomial_authority'] )
#' writer(collection_examples[9, 'Infraspecies'], italics = TRUE )
#' @export
writer2 <- function(x, italics, period) {
  if (missing(period)) {
    period <- FALSE
  }
  x[x == ""] <- NA
  if (missing(italics)) {
    italics <- FALSE
  }
  if (period == TRUE) {
    x <- paste0(gsub('[.]$', '', x), '.')
  }
  if (is.na(x)) {
    ""
  } else if (italics == FALSE) {
    x
  } else {
    (paste0('\\textit{', x, '}'))
  }
}

#' do or don't write determination information
#'
#' This functions determines whether to write information on whom determined the specimen
#' when, and via which texts. It used as a final step when formatting labels.
#' @param x data frame holding the values
#' @examples
#' text <- data.frame(
#' Fide = c('Michigan Flora Book (emphatic)',
#'         'Michigan Flora Book (emphatic) verbose',
#'         'Michigan Flora Book'),
#' Determined_by = rep('Marabeth', 3),
#' Determined_date_text = rep('a day in time', 3)
#' ) |>
#'  split(f = 1:3)
#'
#' lapply(text, writer_fide)
#' @export
writer_fide <- function(x) {
  x$Fide[x$Fide == ""] <- NA

  # if there is nothing to write, simply return an empty string to avoid emitting
  # the NA onto the label.
  if (is.na(x$Fide)) {
    ""
  } else {
    # buy a little bit more real estate. abbreviate Flora.
    x$Fide <- sub(' Flora ', ' Fl. ', x$Fide)

    # now consider this string "BOOK (emphatic) talkative". we need three dispatches
    # to accommodate this. Dispatch 1 will test for (), if not present (most cases)
    # we will run down the ELSE below.

    # DISPATCH 1 check for both parentheses
    if (grepl('\\(.*\\)', x$Fide)) {
      fide_base <- paste0(
        # write everything up to the parenthesis
        paste0('Fide: \\textit{', gsub('\\(.*$', '', x$Fide), '}'),
        paste0('(', gsub('.*\\(|\\).*', '', x$Fide), ')')
      )

      # now test for words after the last parenthesis
      if (nchar(gsub('.*\\)', '', x$Fide)) > 0) {
        paste0(
          fide_base,
          paste0(' \\textit{', gsub('.*\\)', '', x$Fide), '}'),
          ', det.: ',
          x$Determined_by,
          ', ',
          x$Determined_date_text,
          '.'
        )
      } else {
        # return the string with parentheses here
        paste0(
          fide_base,
          ', det.: ',
          x$Determined_by,
          ', ',
          x$Determined_date_text,
          '.'
        )
      }
    } else {
      # IF dispatch 1 finds no '()' return a nice simple string.
      # return a nice uncomplicated string without parentheses
      paste0(
        'Fide: \\textit{',
        sub(' Flora ', ' Fl. ', x$Fide),
        '}, det.: ',
        x$Determined_by,
        ', ',
        x$Determined_date_text,
        '.'
      )
    }
  }
}
