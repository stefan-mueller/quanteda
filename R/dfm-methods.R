####################################################################
## methods for dfm objects
##
## Ken Benoit
####################################################################

#' get the feature labels from a dfm
#' 
#' Get the features from a document-feature matrix, which are stored as the
#' column names of the \link{dfm} object.
#' @param x the dfm whose features will be extracted
#' @return character vector of the features
#' @examples
#' inaugDfm <- dfm(data_corpus_inaugural, verbose = FALSE)
#' 
#' # first 50 features (in original text order)
#' head(featnames(inaugDfm), 50)
#' 
#' # first 50 features alphabetically
#' head(sort(featnames(inaugDfm)), 50)
#' 
#' # contrast with descending total frequency order from topfeatures()
#' names(topfeatures(inaugDfm, 50))
#' @export
featnames <- function(x) {
    UseMethod("featnames")
}

#' @export
#' @noRd
featnames.NULL <- function(x) {
    NULL
}

#' @export
#' @noRd
featnames.dfm <- function(x) {
    if (is.null(colnames(x))) {
        character()
    } else {
        colnames(x)
    }
}

#' deprecated function name for featnames
#' 
#' Please use \code{\link{featnames}} instead.
#' @keywords internal deprecated
#' @export
features <- function(x) {
    .Deprecated("featnames")
    featnames(x)
}

#' @noRd
#' @export
docnames.dfm <- function(x) {
    if (is.null(rownames(x))) {
        character()
    } else {
        rownames(x)
    }
}

#' @noRd
#' @export
docnames.NULL <- function(x) {
    NULL
}

#' coercion and checking functions for dfm objects
#' 
#' Check for a dfm, or convert
#' a matrix into a dfm.
#' @param x a \link{dfm} object
#' @return 
#' \code{is.dfm} returns \code{TRUE} if and only if its argument is a \link{dfm}.
#' @seealso \code{\link{as.data.frame.dfm}}, \code{\link{as.matrix.dfm}}
#' @export
is.dfm <- function(x) {
    is(x, "dfm")
    # "dfm" %in% class(x)
}

#' @rdname is.dfm
#' @return \code{as.dfm} coerces a matrix or data.frame to a dfm
#' @export
as.dfm <- function(x) {
    if (!any((c("matrix", "data.frame") %in% class(x))))
        stop("as.dfm only applicable to matrix(-like) objects.")
    new("dfmSparse", Matrix(as.matrix(x), 
                            sparse = TRUE,
                            dimnames = list(docs = if (is.null(rownames(x))) paste0("doc", seq_len(nrow(x))) else rownames(x),
                                            features = if (is.null(colnames(x))) paste0("feat", seq_len(ncol(x))) else colnames(x)) 
                            ) 
        )
}



#' identify the most frequent features in a dfm
#' 
#' List the most (or least) frequently occuring features in a \link{dfm}, either
#' as a whole or separated by document.
#' @name topfeatures
#' @param x the object whose features will be returned
#' @param n how many top features should be returned
#' @param decreasing If \code{TRUE}, return the \code{n} most frequent features;
#'   otherwise return the \code{n} least frequent features
#' @param scheme one of \code{count} for total feature frequency (within
#'   \code{group} if applicable), or \code{docfreq} for the document frequencies
#'   of features
#' @param groups either: a character vector containing the names of document 
#'   variables to be used for grouping; or a factor or object that can be 
#'   coerced into a factor equal in length or rows to the number of documents. 
#'   See \code{\link{dfm_group}} for details.
#' @return A named numeric vector of feature counts, where the names are the 
#'   feature labels, or a list of these if \code{groups} is given.
#' @examples
#' mydfm <- dfm(corpus_subset(data_corpus_inaugural, Year > 1980), remove_punct = TRUE)
#' mydfm_nostopw <- dfm_remove(mydfm, stopwords("english"))
#' 
#' # most frequent features
#' topfeatures(mydfm)
#' topfeatures(mydfm_nostopw)
#' 
#' # least frequent features
#' topfeatures(mydfm_nostopw, decreasing = FALSE)
#' 
#' # top features of individual documents  
#' topfeatures(mydfm_nostopw, n = 5, groups = docnames(mydfm_nostopw))
#' 
#' # grouping by president last name
#' topfeatures(mydfm_nostopw, n = 5, groups = "President")
#'
#' # features by document frequencies
#' tail(topfeatures(mydfm, scheme = "docfreq", n = 200))
#' @export
topfeatures <- function(x, n = 10, decreasing = TRUE, scheme = c("count", "docfreq"), groups = NULL) {
    UseMethod("topfeatures")
}

#' @export
#' @noRd
#' @importFrom stats quantile
topfeatures.dfm <- function(x, n = 10, decreasing = TRUE,  scheme = c("count", "docfreq"), groups = NULL) {
    scheme <- match.arg(scheme)
    
    if (!is.null(groups)) {
        rownames(x) <- generate_groups(x, groups)
        result <- list()
        for (i in unique(docnames(x))) {
            result[[i]] <- topfeatures(x[which(rownames(x)==i), ], 
                                       n = n, scheme = scheme, 
                                       decreasing = decreasing, groups = NULL)
        }
        return(result)
    }
    
    if (n > nfeature(x)) n <- nfeature(x)
    
    if (scheme == "count") {
        wght <- colSums(x)
    } else if (scheme == "docfreq") {
        wght <- docfreq(x)
    }
    
    result <- sort(wght, decreasing)
    return(result[1:n])
    
    # Under development by Ken
    # if (is.resampled(x)) {
    #     subdfm <- x[, order(colSums(x[,,1]), decreasing = decreasing), ]
    #     subdfm <- subdfm[, 1:n, ]   # only top n need to be computed
    #     return(data.frame(#features=colnames(subdfm),
    #         freq=colSums(subdfm[,,1]),
    #         cilo = apply(colSums(subdfm), 1, stats::quantile, (1 - ci) / 2),
    #         cihi = apply(colSums(subdfm), 1, stats::quantile, 1 - (1 - ci) / 2)))
    # } else {
    #    subdfm <- sort(colSums(x), decreasing)
    #    return(subdfm[1:n])
    #}
}


#' compute the sparsity of a document-feature matrix
#'
#' Return the proportion of sparseness of a document-feature matrix, equal
#' to the proportion of cells that have zero counts.
#' @param x the document-feature matrix
#' @examples 
#' inaug_dfm <- dfm(data_corpus_inaugural, verbose = FALSE)
#' sparsity(inaug_dfm)
#' sparsity(dfm_trim(inaug_dfm, min_count = 5))
#' @export
sparsity <- function(x) {
    if (!is.dfm(x))
        stop("sparsity is only defined for dfm objects")
    (1 - length(x@x) / prod(dim(x)))
}

#' internal functions for dfm objects
#' 
#' Internal function documentation for \link{dfm} objects.
#' @name dfm-internal
#' @keywords dfm internal
NULL

#' The \code{Compare} methods enable relational operators to be use with dfm. 
#' Relational operations on a dfm with a numeric will return a
#' \link[Matrix]{dgCMatrix-class} object.
#' @rdname dfm-internal
#' @param e1 a \link{dfm}
#' @param e2 a numeric value to compare with values in a dfm
#' @export
#' @seealso \link{Comparison} operators
setMethod("Compare", c("dfmSparse", "numeric"), function(e1, e2) {
    as(callGeneric(as(e1, "dgCMatrix"), e2), "lgCMatrix")
})
