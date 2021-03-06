% Generated by roxygen2 (4.0.2): do not edit by hand
\name{read.amiramesh}
\alias{read.amiramesh}
\alias{read.amiramesh.header}
\title{Read AmiraMesh data in binary or ascii format}
\usage{
read.amiramesh(file, sections = NULL, header = FALSE, simplify = TRUE,
  endian = NULL, ReadByteAsRaw = FALSE, Verbose = FALSE)

read.amiramesh.header(file, Parse = TRUE, Verbose = FALSE)
}
\arguments{
  \item{file}{Name of file (or connection) to read}

  \item{sections}{character vector containing names of
  sections}

  \item{header}{Whether to include the full unprocessesd
  text header as an attribute of the returned list.}

  \item{simplify}{If there is only one datablock in file do
  not return wrapped in a list (default TRUE).}

  \item{endian}{Whether multibyte data types should be
  treated as big or little endian. Default of NULL checks
  file or uses \code{.Platform$endian}}

  \item{ReadByteAsRaw}{Logical specifying whether to read 8
  bit data as an R \code{raw} vector rather than
  \code{integer} vector (default: FALSE).}

  \item{Verbose}{Print status messages}

  \item{Parse}{Logical indicating whether to parse header
  (default: TRUE)}
}
\value{
list of named data chunks
}
\description{
Read AmiraMesh data in binary or ascii format

Read the header of an amiramesh file
}
\details{
reading byte data as raw arrays requires 1/4 memory but
complicates arithmetic.

\code{read.amiramesh.header} will open a connection if file
is a character vector and close it when finished reading.
}
\seealso{
\code{\link{readBin}, \link{.Platform}}

Other amira: \code{\link{amiratype}}; \code{\link{hxsurf}},
\code{\link{read.hxsurf}}; \code{\link{is.amiramesh}};
\code{\link{read.amiralandmarks}},
\code{\link{write.amiralandmarks}};
\code{\link{write.hxsurf}}
}

