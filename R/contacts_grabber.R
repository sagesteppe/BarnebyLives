#' Given an index herbariorum code find a shipping address and a curator's contact information
#'
#' @description Assuming you know an IH code this function will acquire some basic information from IH for creating a letterhead on transmittal notices.
#' It's utility is somewhat restricted by idiosyncrasies within the IH database itself, and some data which have somewhat free forms of formatting.
#' @param x Character. an IH code. If you don't know it, you can find it at the following link https://sweetgum.nybg.org/science/ih/.


museums

museums$address[, grep('physical|postal', colnames(museums$address)) ]

contacts_grabber <- function(x){

  url <- "http://sweetgum.nybg.org/science/api/v1/institutions/search?country=U.S.A."
  museums <- jsonlite::fromJSON(url)$data

  museums <- cbind(
    museumsTEST <- museums[,c('organization', 'code')], # these two fields from 1st table

    { musemsTEST2 <- museums$address[, grep('physical|postal', colnames(museums$address)) ]
      musemsTEST2[musemsTEST2==""] <- NA # it's easy to test for NA's
      museumsTEST2 <- dplyr::mutate(musemsTEST2,
          postalStreet = ifelse(is.na(postalStreet), physicalStreet, postalStreet),
          postalCity = ifelse(is.na(postalCity), physicalCity, postalCity),
          postalState = ifelse(is.na(postalState), physicalState, postalState),
          postalZipCode = ifelse(is.na(postalZipCode), physicalZipCode, postalZipCode),
          postalCountry = 'U.S.A.' # yeah some places are missing this...
        )
    museumsTEST2 <- museumsTEST2[, grep('postal', colnames(museumsTEST2))]},

    museums$contact
  )

  # now we will just drop many institute with missing street addresses. The odds that
  # a user of this package would be shipping to those locations is very low.
  museums <- museums[!is.na(museums$postalStreet),]

  return(museums)
}

museums <- contacts_grabber()

cnames <- colnames(museums$address)


post <- cnames[grep('postal', cnames)]
cnames[grep('physical', cnames)][i]

for (i in 1:seq_along(post)){

  museums[,post[i]] <- ifelse(
    is.na(
      museums[,post[i]]),
    physicalStreet, museums[,post[i]]
    )
}

# now we will just drop many institute with missing street addresses. The odds that
# a user of this package would be shipping to those locations is very low.
museumsTEST2 <- museumsTEST2[!is.na(museumsTEST2$postalStreet),]

