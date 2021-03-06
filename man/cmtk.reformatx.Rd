% Generated by roxygen2 (4.0.2): do not edit by hand
\name{cmtk.reformatx}
\alias{cmtk.reformatx}
\title{Reformat an image with a CMTK registration using the reformatx tool}
\usage{
cmtk.reformatx(floating, target, registrations, output, dryrun = FALSE,
  Verbose = TRUE, MakeLock = TRUE, OverWrite = c("no", "update", "yes"),
  filesToIgnoreModTimes = NULL, ...)
}
\arguments{
  \item{floating}{The floating image to be reformatted}

  \item{target}{A character vector specifying a file, an
  \code{im3d} object or a 6-or 9-vector defining a grid in
  the form Nx,Ny,Nz,dX,dY,dZ,[Ox,Oy,Oz].}

  \item{registrations}{One or more CMTK format
  registrations on disk}

  \item{output}{The output image (defaults to
  target-floating.nrrd)}

  \item{dryrun}{Just print command}

  \item{Verbose}{Whether to show cmtk status messages and
  be verbose about file update checks. Sets command line
  \code{--verbose} option.}

  \item{MakeLock}{Whether to use a lock file to allow
  simple parallelisation (see \code{makelock})}

  \item{OverWrite}{Whether to OverWrite an existing output
  file. One of c("no","update","yes"). When
  OverWrite='update' \code{\link{RunCmdForNewerInput}} is
  used to determine if the output is older than any of the
  input files.}

  \item{filesToIgnoreModTimes}{Input files whose
  modification time should not be checked when determining
  if new output is required.}

  \item{...}{additional arguments passed to CMTK
  \code{reformatx} after processing by
  \code{\link{cmtk.call}}.}
}
\description{
Reformat an image with a CMTK registration using the
reformatx tool
}
\examples{
\dontrun{
cmtk.reformatx('myimage.nrrd', target='template.nrrd',
  registrations='template_myimage.list')
}
}
\seealso{
\code{\link{cmtk.bindir}, \link{cmtk.call},
\link{makelock}, \link{RunCmdForNewerInput}}
}

