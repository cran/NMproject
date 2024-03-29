% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{is_full_path}
\alias{is_full_path}
\title{Test if full path}
\usage{
is_full_path(x)
}
\arguments{
\item{x}{String giving file/path name.}
}
\value{
\code{TRUE} only when path starts with ~, /, \\ or X: (i.e. when x is a full path), \code{FALSE} otherwise.
}
\description{
Test if full path
}
\keyword{internal}
