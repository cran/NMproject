% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rmd_to_vignette.R
\name{rmd_to_vignettes}
\alias{rmd_to_vignettes}
\title{Convert R markdown scripts to vignettes}
\usage{
rmd_to_vignettes(script_files, overwrite = FALSE)
}
\arguments{
\item{script_files}{Optional character vector of scripts.  If empty will find
scripting making the \code{s##_XXX.Rmd} convention.  Must be .Rmd files}

\item{overwrite}{Logical (default = \code{FALSE}). Overwrites existing vignettes
of the same name.}
}
\value{
No return value, called for side effects.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Copies (by default) all scripts \code{s01_XXX.Rmd}, \code{s02_XXX.Rmd} into the
"vignettes" and reformats so they meet vignette standards.  Use of
\code{\link[devtools:build_vignettes]{devtools::build_vignettes()}} can then be used to build vignettes.
}
\details{
Uses of \code{\link[=decision]{decision()}} must pass without stopping so these must have
been run interactively prior to use of \code{\link[devtools:build_vignettes]{devtools::build_vignettes()}}.
}
