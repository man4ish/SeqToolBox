stb_outfile_name <- function (filename, dir = "./out") {

  if (is.null(VERSION)) {
      VERSION <<- format(Sys.Date(), format="%Y%m%d")
  }
  dir <- gsub ("/$", "", dir, perl = TRUE)
  return (paste0(dir,"/", paste(VERSION,filename, sep = "-")))
}