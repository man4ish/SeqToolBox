# R function to extract entrez id for a list of gene symbol
# using NCBI gene info file

library(readr)
library(stringr)

stb_symbol2entrezid <- function (gene_list=NULL, gene_info_file=NULL) {
    
    symbol_id_map <- new.env(hash=TRUE)

    if (is.null(gene_info_file) || !file.exists(gene_info_file)) {
        download.file("ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz", destfile = "Homo_sapiens_gene_info.gz")
        gene_info_file <- "Homo_sapiens_gene_info.gz"
    }
    

    hs_gene_info <- read_tsv(gene_info_file)
    apply (hs_gene_info,  MARGIN=1, FUN = function (x) {
        gene_id <- x[2]
        all <- vector()
        
        if (x[3] != "-") {
             symbol <- x[3]
             all <- c(all, symbol)   
        }
       

        # if (x[5] != "-") {
        #     synonyms <- unlist(strsplit(x[5], "\\|"))
        #     all <- c(all, synonyms)
        # }
        
        if (x[11] != "-") {
            others <- x[11]
            all <- c(all, others)
        }
        
        #all <- c(symbol, synonyms, others)
        all <- unique(all)
        #cat (all)
        for ( i in all ) {
            if (exists(i, symbol_id_map)) {
                cat (paste0(i, ": Lower id found, skipping\n"))
            } else {
                symbol_id_map[[i]] <- gene_id
            }
        }

    }) 

    apply (hs_gene_info,  MARGIN=1, FUN = function (x) {
        gene_id <- x[2]
        all <- vector()

        if (x[5] != "-") {
            synonyms <- unlist(strsplit(x[5], "\\|"))
            all <- c(all, synonyms)
        }
        
        
        #all <- c(symbol, synonyms, others)
        all <- unique(all)
        #cat (all)
        for ( i in all ) {
            if (exists(i, symbol_id_map)) {
                cat (paste0(i, ": Lower id found, skipping\n"))
            } else {
                symbol_id_map[[i]] <- gene_id
            }
        }

    }) 


    result <- vector()
    for (i in gene_list) {
        if (exists(i, symbol_id_map)) {
            result <- c(result, str_trim(symbol_id_map[[i]]))
        }else {
            result <- c(result, NA)
        }
    } 
    names(result) <- gene_list
    return(result)
}