geoCode <- function(address,verbose=FALSE) {
  if(verbose) cat(address,"\n")
  u <- url(address)
  doc <- try(getURL(u), silent = TRUE)
  if(inherits(doc, "try-error")) return(geoCodeOSM(address, verbose = verbose))
  x <- fromJSON(doc,simplify = FALSE)
  if(x$status %in% c("REQUEST_DENIED", "INVALID_REQUEST", "ZERO_RESULTS", "OVER_QUERY_LIMIT")){
    return(geoCodeOSM(address, verbose = verbose))
  }
  count <- 1
  
  while(x$status != "OK" & count < 10){
    doc <- try(getURL(u), silent = TRUE)
    if(inherits(doc, "try-error")) return(geoCodeOSM(address, verbose = verbose))
    x <- fromJSON(doc,simplify = FALSE)
    if(x$status %in% c("REQUEST_DENIED", "INVALID_REQUEST", "ZERO_RESULTS", "OVER_QUERY_LIMIT")){
      return(geoCodeOSM(address, verbose = verbose))
    }
    count <- count + 1
    Sys.sleep(0.5)
  }
  
  if(x$status=="OK") {
    lat <- x$results[[1]]$geometry$location$lat
    lng <- x$results[[1]]$geometry$location$lng
    location_type  <- x$results[[1]]$geometry$location_type
    formatted_address  <- x$results[[1]]$formatted_address
    return(c(lat, lng, location_type, formatted_address))
  } else {
    return(geoCodeOSM(address, verbose = verbose))
  }
}

geoCodeOSM <- function(address, verbose = FALSE) {
  if(verbose) cat("OpenStreetMap fallback:", address, "\n")
  u <- osm_url(address)
  doc <- try(getURL(u, httpheader = c("User-Agent" = "whats-flying-tonight/1.0")), silent = TRUE)
  if(inherits(doc, "try-error")) return(c(NA, NA, NA, NA))

  x <- try(fromJSON(doc, simplify = FALSE), silent = TRUE)
  if(inherits(x, "try-error") || length(x) < 1) return(c(NA, NA, NA, NA))

  lat <- x[[1]]$lat
  lng <- x[[1]]$lon
  location_type <- "APPROXIMATE"
  formatted_address <- x[[1]]$display_name

  return(c(lat, lng, location_type, formatted_address))
}

url <- function(address, return.call = "json", sensor = "false") {
  root <- "https://maps.google.com/maps/api/geocode/"
  u <- paste(root, return.call, "?address=", address, "&sensor=", sensor,
             google_key(), sep = "")
  return(URLencode(u))
}

osm_url <- function(address) {
  root <- "https://nominatim.openstreetmap.org/search"
  query <- paste0(
    "?format=json",
    "&limit=1",
    "&countrycodes=gb",
    "&q=", URLencode(address, reserved = TRUE)
  )
  paste0(root, query)
}
