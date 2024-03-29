% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm_render.R
\name{nm_render}
\alias{nm_render}
\alias{nm_list_render}
\title{Create run reports}
\usage{
nm_render(
  m,
  input,
  output_file = NA,
  args = list(),
  force = getOption("nm.force_render"),
  ...
)

nm_list_render(
  m,
  input,
  output_file = NA,
  args = list(),
  force = getOption("nm.force_render"),
  ...
)
}
\arguments{
\item{m}{An nm object.}

\item{input}{Character. Same as \code{rmarkdown::render()} arg.}

\item{output_file}{Character. Same as \code{rmarkdown::render()} arg.}

\item{args}{List. Same as "params" arg in \code{rmarkdown::render()}.}

\item{force}{Logical (default = \code{getOption("nm.force_render")}). Will force
execution.}

\item{...}{Additional argument passed to \code{rmarkdown::render()}.}
}
\value{
The same nm object, \code{m}, with modified \code{results_files} field.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

A wrapper around \code{rmarkdown::render} for nm objects.  Use markdown templates
to create a customised set of diagnostics to reuse on multiple models. In the
demo an example is shown in \code{Scripts/basic_gof.Rmd}, but ideally you'll
create your own customised version with everything you need to evaluate your
model. To create an R markdown diagnostic template go to \code{FILE} -> \verb{New File}
-> \verb{R markdown} -> \verb{From Template} the select from one of the following:

\itemize{ \item model diagnostic \item VPC diagnostic
\item PPC diagnostic
\item bootstrap results (\code{nm_list_render})
}

These are intentionally minimal templates that can be run as notebooks or as
automated diagnostics run with \code{nm_render}.  Follow the instructions at the
top of the template for more details.
}
\details{
\code{input} must refer to a properly specified Rmd document. The R
markdown template "model diagnostic" in RStudio sets this up for you.

These R markdown templates are usable as R Notebooks (e.g. for code
development and debugging) if the object \code{.m} is defined in the global work
space first.

\code{nm_list_render()} is mostly used for bootstraps, and other routines where a
parent run spawns multiple children in the form of an nm_list
}
\examples{

## requires NONMEM to be installed
\dontrun{
m1 \%>\% nm_render("Scripts/basic_gof.Rmd")

## to run "Scripts/basic_gof.Rmd" as an R Notebook
## first define .m

.m <- m1 ## Now you can run "Scripts/basic_gof.Rmd" as a Notebook
}
}
