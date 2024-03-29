% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{\%f>\%}
\alias{\%f>\%}
\title{Function pipe for nm objects}
\usage{
lhs \%f>\% rhs
}
\arguments{
\item{lhs}{An nm object.}

\item{rhs}{A list of functions.  Must be same length as \code{lhs}.}
}
\value{
A modified nm object.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Pipe an nm object object to a list of functions.  Although this enables
multiple NONMEM runs to be handled simultaneously, it does make your code
less readable.
}
\examples{

# create example object m1 from package demo files
exdir <- system.file("extdata", "examples", "theopp", package = "NMproject")
m1 <- new_nm(run_id = "m1", 
             based_on = file.path(exdir, "Models", "ADVAN2.mod"),
             data_path = file.path(exdir, "SourceData", "THEOPP.csv"))
             
temp_data_file <- paste0(tempfile(), ".csv")

## dataset has missing WTs so create a new one and assign this to the run
input_data(m1) \%>\% 
  dplyr::group_by(ID) \%>\%
  dplyr::mutate(WT = na.omit(WT)) \%>\%
  write_derived_data(temp_data_file)
  
m1 <- m1 \%>\% data_path(temp_data_file)

mWT <- m1 \%>\% child(c("m2", "m3", "m4")) \%f>\% 
list(
 . \%>\% add_cov(param = "V", cov = "WT", state = "linear"),
 . \%>\% add_cov(param = "V", cov = "WT", state = "power"),
 . \%>\% add_cov(param = "V", cov = "WT", state = "power1")
)

mWT \%>\% dollar("PK")

unlink(temp_data_file)

}
\seealso{
\code{\link[=child]{child()}} for creating multiple child NONMEM objects
}
