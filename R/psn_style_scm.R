#' PsN style stepwise covariate method
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Intent is not to replicate PsN SCM.  This is mainly here for illustrative and
#' comparison purposes. Should replicate the model selection in PsN's SCM
#' functionality with greedy setting.
#'
#' @param base An nm object (base model).
#' @param run_in A directory to run in.
#' @param dtest Output of [test_relations()].
#' @param alpha_forward Numeric (default = `0.05`). Alpha level for forward
#'   inclusion.
#' @param alpha_backward Numeric (default = `0.01`). Alpha level for backward
#'   deletion.
#'
#' @return The nm object of the selected model.
#'
#' @seealso [test_relations()], [covariate_step_tibble()],
#'   [bind_covariate_results()].
#'
#' @export
psn_style_scm <- function(base, run_in, dtest,
                          alpha_forward = 0.05, alpha_backward = 0.01) {
  base_run_id <- run_id(m)
  m <- base
  fi <- 1
  bi <- 1
  while (TRUE) { ## foward step
    run_id <- paste0(base_run_id, "_", fi)
    d <- m %>% covariate_step_tibble(
      run_id = run_id,
      run_in = run_in,
      dtest = dtest,
      direction = "forward"
    )

    d <- d$m %>%
      run_nm() %>%
      wait_finish()

    d <- d %>% bind_covariate_results()

    ## most significant is the first - pick that
    if (d$p_chisq[1] > alpha_forward) break

    m <- d$m[1]
    fi <- fi + 1
  }

  forward_run_id <- run_id

  while (TRUE) {
    run_id <- paste0(forward_run_id, "_", bi)
    d <- m %>% covariate_step_tibble(
      run_id = run_id,
      run_in = run_in,
      dtest = dtest,
      direction = "backward"
    )

    d$m <- d$m %>%
      run_nm() %>%
      wait_finish()

    d <- d %>% bind_covariate_results()

    if (d$p_chisq[1] < alpha_backward) break

    m <- d$m[1] ## most sig
  }
  m
}
