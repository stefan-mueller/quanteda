% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/docvars.R
\name{metadoc}
\alias{metadoc}
\alias{metadoc<-}
\title{get or set document-level meta-data}
\usage{
metadoc(x, field = NULL)

metadoc(x, field = NULL) <- value
}
\arguments{
\item{x}{a \link{corpus} object}

\item{field}{character, the name of the metadata field(s) to be queried or 
set}

\item{value}{the new value of the new meta-data field}
}
\value{
For \code{texts}, a character vector of the texts in the corpus.
  
  For \code{texts <-}, the corpus with the updated texts.
}
\description{
Get or set document-level meta-data.  Document-level meta-data are a special 
type of \link{docvars}, meant to contain information about documents that 
would not be used as a "variable" for analysis. An example could be the 
source of the document, or notes pertaining to its transformation, copyright 
information, etc.
}
\details{
Document-level meta-data differs from corpus-level meta-data in that the 
latter pertains to the collection of texts as a whole, whereas the 
document-level version can differ with each document.
}
\note{
Document-level meta-data names are preceded by an underscore character,
  such as \code{_language}, but when named in in the \code{field} argument, 
  do \emph{not} need the underscore character.
}
\examples{
mycorp <- corpus_subset(data_corpus_inaugural, Year > 1990)
summary(mycorp, showmeta = TRUE)
metadoc(mycorp, "encoding") <- "UTF-8"
metadoc(mycorp)
metadoc(mycorp, "language") <- "english"
summary(mycorp, showmeta = TRUE)
}
\seealso{
\code{\link{metacorpus}}
}
\keyword{corpus}
