% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_tree.R
\name{nm_tree}
\alias{nm_tree}
\title{Make data.tree object}
\usage{
nm_tree(..., summary = FALSE)
}
\arguments{
\item{...}{Arguments passed to \code{\link[=nm_list_gather]{nm_list_gather()}}.}

\item{summary}{Logical (default = \code{FALSE}). Should \code{\link[=summary_wide]{summary_wide()}} variables be appended.}
}
\value{
A \code{data.tree} object.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Draw a tree diagram showing model development path.
}
