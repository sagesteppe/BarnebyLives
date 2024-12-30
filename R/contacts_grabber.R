#' Given an index herbariorum code find a shipping address and a curator's contact information
#'
#' @description Assuming you know an IH code this function will acquire some basic information from IH for creating a letterhead on transmittal notices.
#' It's utility is somewhat restricted by idiosyncrasies within the IH database itself, and some data which have somewhat free forms of formatting.
#' @param x Character. an IH code. If you don't know it, you can find it at the following link https://sweetgum.nybg.org/science/ih/.


museums

museums$address[, grep('physical|postal', colnames(museums$address)) ]

contacts_grabber <- function(x){

  # CAT THE CODE WE ARE SEARCHING FOR HERE!!! NO NEED TO DL THE WHOLE COUNTRY TO GET
  # THE RELEVANT RESULTS, START OUT SUBSET...

  url <- "http://sweetgum.nybg.org/science/api/v1/institutions/search?country=U.S.A."
  museums <- jsonlite::fromJSON(url)$data

  museums <- cbind(

    museums[,c('organization', 'code')], # these two fields from 1st table

    { # here we grab the shipping addresses.
      museum_addy <- museums$address[, grep('physical|postal', colnames(museums$address)) ]
      museum_addy[museum_addy==""] <- NA # it's easy to test for NA's

      # overwrite original values that are NA, with the physical address information.
      # really long winded- but want to be able to deal with any IH name changes
      # without having to refactor.
      post <- cnames[grep('postal', cnames)]
      for (i in seq_along(post)){
        museum_addy[,museum_addy[i]] <- ifelse(
          is.na(
            museum_addy[,museum_addy[i]]),
          museum_addy[, gsub('postal', 'physical', museum_addy[i])], museum_addy[,museum_addy[i]]
        ) # this only catches pretty egregious errors in the DB.
      }
      # no need for the physical 'walk in' addresses for the institutes.
      museumsTEST2 <- museumsTEST2[, grep('postal', colnames(museumsTEST2))]
    },

    museums$contact
  )

  # now we will just drop many institute with missing street addresses. The odds that
  # a user of this package would be shipping to those locations is very low.
  museums <- museums[!is.na(museums$postalStreet),]
  return(museums)

  url <- "http://sweetgum.nybg.org/science/api/v1/staff/search?country=U.S.A."
  people <- jsonlite::fromJSON(url)$data

  people <- cbind(
    people[,c('code', 'firstName', 'lastName', 'correspondent')],
    people$contact
  )

  matches <- merge(
    x = museums, y = people,
    by = 'code', all.x = TRUE # left join
  ) |>
    as.data.frame()
  matches[matches==""] <- NA

}

museums <- contacts_grabber()

# these just used for testing while not able to reach wifi.
cnames <- c('postalStreet', 'postalCity', 'postalState', 'postalZipCode', 'postalCountry')
cnames <- c(cnames, gsub('postal', 'physical', cnames))
museums <- setNames(
  data.frame(
    cbind(
      matrix(
        sample(c(NA, 1), prob = c(0.2, 0.8), size = 100, replace = TRUE), ncol = 5
      ),
      matrix(rep(2:6, each = 20), ncol = 5)
    )
  ),
  cnames
)



