.onLoad <- function(libname, pkgname) {
  set_nm_opts()
}

if (!exists(".sso_env")) {
  .sso_env <- new.env(parent = emptyenv())
  .sso_env$run_count <- 0
}
