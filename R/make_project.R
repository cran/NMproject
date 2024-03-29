#' Create analysis project
#'
#' @description
#'
#' `r lifecycle::badge("stable")`
#'
#' This is the underlying function used by: `File` -> `New Project` ->
#' `New Directory` -> `New NMproject`.  It creates a new analysis working
#' directory with a directory structure similar to an R package.
#'
#' @param path Character path (relative or absolute) to project.  If just
#'   specifying a name, this will create the analysis project in the current
#' working directory.  See details for naming requirements.
#' @param dirs Character list or vector.  Default = `nm_default_dirs()`.  Can
#'   also handle an ordered string which is supplied by the RStudio project
#'   template interface.
#' @param style Character. Either `"analysis"` or `"analysis-package"` See
#'   details for `path` requirements and function behaviour.
#' @param use_renv Logical (default = `FALSE`). Should `renv` be used or not in
#'   project.
#' @param readme_template_package Package name from which to load the README
#'   template (default = `"NMproject"`)
#' @param ... Deprecated.
#'
#' @details The function works like as is inspired by
#'   `starters::create_analysis_project()`. There is no restriction on directory
#'   name.  It is therefore possible to violate R package naming conventions.
#'
#'   When `style = "analysis"` is selected, the analysis directory will be
#'   package-like in structure, with the package name `"localanalysis"`.
#'   For `style = "analysis-package"`, `path` should contain only (ASCII)
#'   letters, numbers and dot, have at least two characters and start with a
#'   letter and not end in a dot.  See [Description file
#'   requirements](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file)
#'   for more information.
#'
#'   This is to cater to users who like underscores and aren't interested in
#'   creating a package.
#'
#' @section Default modelling directories:
#'
#' Default modelling directories can be modified with `nm_default_dirs` option
#' (see [options()] for information on how to modify this). A (partially) named
#' list of directories to be used by `nm_create_analysis_project` Required names
#' are `"models"`, `"scripts"` and `"results"`. By default these are set to
#' `"Models"`, `"Scripts"` and `"Results"`, respectively. Additional nameless
#' characters (e.g. `"SourceData"`) correspond to additional modelling
#' directories.
#'
#' \describe{
#'   \item{"SourceData":}{
#'   intended for unmodified source datasets entering the analysis project.
#'   }
#'   \item{"DerivedData":}{
#'   intended for cleaned and processed NONMEM ready datasets
#'   }
#'   \item{"Scripts":}{
#'   intended for all R scripts
#'   }
#'   \item{"Models":}{
#'   intended for all NONMEM modelling
#'   }
#'   \item{"Results":}{
#'   intended as default location for run diagnostics, plots and tables
#'   }
#' }
#'
#' @seealso [nm_default_dirs()] for modifying default directory structure.
#' @export

nm_create_analysis_project <- function(path, dirs = nm_default_dirs(),
                                       style = c("analysis", "analysis-package"),
                                       use_renv = FALSE, readme_template_package = "NMproject",
                                       ...) {

  if (!requireNamespace("devtools")) stop("install devtools")
    
  ## need to normalize path because usethis has different
  ## home directory, so use use R normalizePath to remove abiguity

  if(is.character(dirs) & length(dirs) == 1) dirs <- parse_dirs(dirs)

  current_default_dirs <- nm_default_dirs()
  nm_default_dirs(dirs)
  on.exit(nm_default_dirs(current_default_dirs))

  ## if it's a full path, leave it alone
  ## otherwise if it's a relative path, we need the working directory to make it full
  if (!is_full_path(path)) {
    path <- file.path(normalizePath(getwd()), path)
    path <- normalizePath(path, mustWork = FALSE)
  }
  ## needed because usethis::create_project and R can disagree on ~ location
  ## R should take precendence
  path <- path.expand(path)

  if (file.exists(path)) {
    stop("Directory already exists. Aborting.")
  }

  style <- match.arg(style)
  name <- basename(path)
  folder <- dirname(path)

  if (grepl("package", style) & !valid_package_name(name)) {
    stop("directory name is not compliant for style = \"analysis-package\" see ?nm_create_analysis_project")
  }

  usethis::create_project(path = path, rstudio = TRUE, open = FALSE)
  ## left over steps = use_rstudio() - this will be done with use_rstudio_package() below

  current_proj <- try(usethis::proj_get(), silent = TRUE)
  if (inherits(current_proj, "try-error")) {
    current_proj <- NULL
  }
  usethis::proj_set(path)
  on.exit(usethis::proj_set(current_proj), add = TRUE)
  
  ## needed to set .Rbuildignore and *.Rproj to package types
  unlink(file.path(path, "*.Rproj"))
  use_rstudio_package(name)

  write("This directory is for .R files containing R functions", file.path(path, "R", "Readme.txt"))
  usethis::use_build_ignore(file.path("R", "Readme.txt"))

  usethis::use_template("README.Rmd",
    data = c(Package = name, dirs),
    package = readme_template_package
  )

  usethis::use_build_ignore("README.Rmd")

  if (use_renv) {
    if (!requireNamespace("renv", quietly = TRUE)) {
      stop("install renv", call. = FALSE)
    }
    if (!requireNamespace("desc", quietly = TRUE)) {
      stop("install desc", call. = FALSE)
    }
  }

  if (use_renv) renv::scaffold(project = usethis::proj_get())

  for (i in seq_along(dirs)) {
    dir_name <- dirs[[i]]
    if (!dir_name %in% ".") {
      usethis::use_directory(dir_name, ignore = TRUE)
      ## create staging equivalent
      usethis::use_directory(file.path("staging", dir_name), ignore = TRUE)

      generic_dir_name <- names(dirs)[i]
      readme_path <- file.path(dir_name, "Readme.txt")
      staging_readme_path <- file.path("staging", dir_name, "Readme.txt")
      if (generic_dir_name %in% names(.nm_dir_descriptions)) {
        write(.nm_dir_descriptions[[generic_dir_name]], file.path(path, readme_path))
        write(.nm_dir_descriptions[[generic_dir_name]], file.path(path, staging_readme_path))
      } else {
        write("Custom directory", file.path(path, readme_path))
        write("Custom directory", file.path(path, staging_readme_path))
      }
    }
  }

  tryCatch(
    {
      if (style %in% "analysis") {
        usethis::use_description(fields = list(Package = "localanalysis"), check_name = FALSE)
      }
      if (style %in% "analysis-package") {
        usethis::use_description()
      }

      if (use_renv) {
        desc::desc_set_dep(
          package = "renv", type = "Imports",
          file = usethis::proj_get()
        )
      }
    },
    error = function(e) {
      usethis::ui_info("skipping creation of {usethis::ui_path('DESCRIPTION')}")
    }
  )

  tryCatch(
    {
      usethis::use_namespace()
    },
    error = function(e) {
      usethis::ui_info("skipping creation of {usethis::ui_path('NAMESPACE')}")
    }
  )

  set_default_dirs_in_rprofile(file.path(folder, name, ".Rprofile"), dirs)

  tryCatch(
    {
      suppressMessages(devtools::build_readme(path = path))   
    },
    error = function(e) {
      usethis::ui_info("skipping {usethis::ui_path('README.Rmd')} build")
    }
  )

  ## No R directory for simple package - advanced users needs to create this manually
  ##  This is because RStudio by default tries to save files in the R directory.
  if (style %in% "analysis") unlink(file.path(folder, name, "R"), recursive = TRUE)

  ## no badges - skip this part of starters for now
  repo <- git2r::init(usethis::proj_get())

  if(!is.null(nm_pre_commit_hook())) {
    usethis::use_git_hook("pre-commit", nm_pre_commit_hook())
  }

  if(!is.null(nm_pre_push_hook())) {
    usethis::use_git_hook("pre-push", nm_pre_push_hook())
  }

  git2r::add(repo, path = "*")

  tryCatch(
    {
      git2r::commit(repo, message = "Initial commit", all = TRUE)
    },
    error = function(e) {
      check_git_uservalues()
      usethis::ui_oops("cannot commit. Aborting commit, git functionality will be reduced...")
    }
  )

  return(invisible(path))
}

parse_dirs <- function(dirs){
  dirs <- as.character(dirs)
  if(length(dirs) != 1) stop("dirs must be length 1", call. = FALSE)
  dirs <- strsplit(dirs, ",")[[1]]
  dirs <- trimws(dirs)

  named_indexes <- seq_len(min(length(dirs), length(.nm_dir_descriptions)))
  names(dirs)[named_indexes] <- names(.nm_dir_descriptions)[named_indexes]
  names(dirs)[is.na(names(dirs))] <- ""
  dirs <- dirs[!dirs %in% ""]
  dirs <- as.list(dirs)
  dirs
}

## following is a copy of usethis::use_rstudio() but with is_package() set to TRUE
use_rstudio_package <- function(project_name, line_ending = c("posix", "windows")) {
  is_package <- TRUE
  line_ending <- rlang::arg_match(line_ending)
  line_ending <- c("posix" = "Posix", "windows" = "Windows")[[line_ending]]
  
  rproj_file <- paste0(project_name, ".Rproj")
  new <- usethis::use_template(
    "template.Rproj",
    save_as = rproj_file,
    data = list(line_ending = line_ending, is_pkg = is_package),
    ignore = is_package
  )
  
  usethis::use_git_ignore(".Rproj.user")
  if (is_package) {
    usethis::use_build_ignore(".Rproj.user")
  }
  
  invisible(new)
}


#' @rdname git_hooks
#' @name git_hooks
#' @title Git hooks
#'
#' @description
#'
#' `r lifecycle::badge("experimental")`
#'
#' This function is primarily for organisational level configuration. Supply
#' git hooks in the form of R functions and they will be executed via the
#' `Rscript` interface.
#'
#' @param cmd Optional command for setting the git hook.
#'
#' @return If no `cmd` is specified this returns the return value of
#'   `getOption("nm_pre_commit_hook")`.  Otherwise there is no return value.
#'
#' @seealso [nm_create_analysis_project()]
#' @keywords internal
#' @export
nm_pre_commit_hook <- function(cmd){
  if (missing(cmd)) {
    return(getOption("nm_pre_commit_hook"))
  }
  ## now assume we're setting
  options(nm_pre_commit_hook = cmd)
}

#' @rdname git_hooks
#' @export
nm_pre_push_hook <- function(cmd){
  if (missing(cmd)) {
    return(getOption("nm_pre_push_hook"))
  }
  ## now assume we're setting
  options(nm_pre_push_hook = cmd)
}


#' Package name validator from `usethis`
#'
#' @param x Name of package.
#'
#' @return A logical `TRUE` if or `FALSE` indicating if `x` is a valid package
#'   name.
#'
#' @keywords internal
valid_package_name <- function(x) {
  grepl("^[a-zA-Z][a-zA-Z0-9.]+$", x) && !grepl("\\.$", x)
}
