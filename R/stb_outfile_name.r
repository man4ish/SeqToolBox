stb_outfile_name <- function (filename) {
  if (is.null(VERSION)) {
      VERSION <<- format(Sys.Date(), format="%Y%m%d")
  }
  return (paste0("./out/", paste(VERSION,filename, sep = "-")))
}