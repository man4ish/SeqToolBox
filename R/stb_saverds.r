stb_saveRDS.xz <- function(object,file) {
  con <- pipe(paste0("xz -T0>",file),"wb")
  saveRDS(object, file = con)
  close(con)
}