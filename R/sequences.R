#' Find variable-length collocations 
#' 
#' This function automatically identifies contiguous collocations consisting of 
#' variable-length term sequences whose frequency is unlikely to have occurred 
#' by chance.  The algorithm is based on Blaheta and Johnson's (2001) 
#' "Unsupervised Learning of Multi-Word Verbs".
#' @param x a \link{tokens} object
#' @param min_count minimum frequency of sequences for which parameters are 
#'   estimated
#' @param size length of collocations, default is 2. Can be set up to 5.
#'        Use c(2,n) or 2:n to return collocations of bigram to n-gram collocations.
#' @param method default is "lambda" and option is "lambda1"
#' @param smoothing default is 0.5
#' @keywords collocations internal
#' @author Kohei Watanabe and Haiyan Wang
#' @references Blaheta, D., & Johnson, M. (2001). 
#'   \href{http://web.science.mq.edu.au/~mjohnson/papers/2001/dpb-colloc01.pdf}{Unsupervised
#'    learning of multi-word verbs}. Presented at the ACLEACL Workshop on the 
#'   Computational Extraction, Analysis and Exploitation of Collocations.
#' @examples 
#' toks <- tokens(corpus_segment(data_corpus_inaugural, what = "sentence"), remove_punct=TRUE)
#' toks <- tokens_select(toks, stopwords("english"), "remove", padding = TRUE)
#' # extracting multi-part proper nouns (capitalized terms)
#' toks <- tokens_select(toks, "^([A-Z][a-z\\-]{2,})", valuetype="regex", 
#'                      case_insensitive = FALSE, padding = TRUE)
#' 
#' seqs <- sequences(toks, size = 2:3)
#' head(seqs, 10)
#' # to return only trigrams
#' seqs <- sequences(toks, size=3)
#' head(seqs, 10)
#' @export
sequences <- function(x, 
                       min_count = 2,
                       size = 2,
                       method = c("lambda", "lambda1"),
                       smoothing = 0.5) {
    
    # .Deprecated('textstat_collocations')
    UseMethod("sequences")
}

#' @rdname sequences
#' @noRd
#' @export
sequences.tokens <- function(x,
                              min_count = 2,
                              size = 2,
                              method = c("lambda", "lambda1"),
                              smoothing = 0.5) {
    
    attrs_org <- attributes(x)
    methodtype = match.arg(method)
    
    if (any(!(size %in% 2:5)))
        stop("Only bigram, trigram, 4-gram and 5-gram collocations implemented so far.")
    
    types <- types(x)
    
    result <- qatd_cpp_sequences(x, types, min_count, size, methodtype, smoothing)
    result <- result[result$count >= min_count,]
    if (methodtype == "lambda") {
        result$z <- result$lambda / result$sigma
    } else {
        result$z <- result$lambda1 / result$sigma
    }
    result$p <- 1 - stats::pnorm(result$z)
    result <- result[order(result$z, decreasing = TRUE),]
    attr(result, 'types') <- types
    class(result) <- c("sequences", 'data.frame')
    
    return(result)
}

#' @method "[" sequences
#' @export
#' @noRd
"[.sequences" <- function(x, i, ...) {
    x <- as.data.frame(x)[i,]
    attr(x, 'ids') <- attr(x, 'ids')[i]
    class(x) <- c("sequences", 'data.frame')
    return(x)
}

#' @export
#' @method as.tokens sequences
#' @noRd 
as.tokens.sequences <- function(x) {
    toks <- attr(x, 'tokens')
    attr(toks, 'types') <- attr(x, 'types')
    class(toks) <- c("tokens", "tokenizedTexts")
    return(toks)
}

#' @rdname sequences
#' @export
#' @return \code{sequences} returns \code{TRUE} if the object is of class
#'   sequences, \code{FALSE} otherwise.
is.sequences <- function(x) "sequences" %in% class(x)
