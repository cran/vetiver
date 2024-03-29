% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/monitor.R
\name{vetiver_pin_metrics}
\alias{vetiver_pin_metrics}
\title{Update model metrics over time for monitoring}
\usage{
vetiver_pin_metrics(
  board,
  df_metrics,
  metrics_pin_name,
  .index = .index,
  overwrite = FALSE,
  type = NULL,
  ...
)
}
\arguments{
\item{board}{A pin board, created by \code{\link[pins:board_folder]{board_folder()}}, \code{\link[pins:board_connect]{board_connect()}},
\code{\link[pins:board_url]{board_url()}} or another \code{board_} function.}

\item{df_metrics}{A tidy dataframe of metrics over time, such as created by
\code{\link[=vetiver_compute_metrics]{vetiver_compute_metrics()}}.}

\item{metrics_pin_name}{Pin name for where the \emph{metrics} are stored (as
opposed to where the model object is stored with \code{\link[=vetiver_pin_write]{vetiver_pin_write()}}).}

\item{.index}{The variable in \code{df_metrics} containing the aggregated dates
or date-times (from \code{time_var} in \code{data}). Defaults to \code{.index}.}

\item{overwrite}{If \code{FALSE} (the default), error when the new metrics contain
overlapping dates with the existing pin.If \code{TRUE}, overwrite any metrics for
dates that exist both in the existing pin and new metrics with the \emph{new}
values.}

\item{type}{File type used to save metrics to disk. With the default \code{NULL},
uses the \code{type} of the existing pin. Options are "rds" and "arrow".}

\item{...}{Additional arguments passed on to methods for a specific board.}
}
\value{
A dataframe of metrics.
}
\description{
These three functions can be used for model monitoring (such as in a
monitoring dashboard):
\itemize{
\item \code{\link[=vetiver_compute_metrics]{vetiver_compute_metrics()}} computes metrics (such as accuracy for a
classification model or RMSE for a regression model) at a chosen time
aggregation \code{period}
\item \code{vetiver_pin_metrics()} updates an existing pin storing model metrics
over time
\item \code{\link[=vetiver_plot_metrics]{vetiver_plot_metrics()}} creates a plot of metrics over time
}
}
\details{
Sometimes when you monitor a model at a given time aggregation, you
may end up with dates in your new metrics (like \code{new_metrics} in the example)
that are the same as dates in your existing aggregated metrics (like
\code{original_metrics} in the example). This can happen if you need to re-run a
monitoring report because something failed. With \code{overwrite = FALSE} (the
default), \code{vetiver_pin_metrics()} will error when there are overlapping
dates. With \code{overwrite = TRUE}, \code{vetiver_pin_metrics()} will replace such
metrics with the new values. You probably want \code{FALSE} for interactive use
and \code{TRUE} for dashboards or reports that run on a schedule.

You can initially create your pin with \code{type = "arrow"} or the default
(\code{type = "rds"}). \code{vetiver_pin_metrics()} will update the pin using the
same \code{type} by default.
}
\examples{
\dontshow{if (rlang::is_installed(c("dplyr", "parsnip", "modeldata", "arrow")) && identical(Sys.getenv("NOT_CRAN"), "true")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(dplyr)
library(parsnip)
data(Chicago, package = "modeldata")
Chicago <- Chicago \%>\% select(ridership, date, all_of(stations))
training_data <- Chicago \%>\% filter(date < "2009-01-01")
testing_data <- Chicago \%>\% filter(date >= "2009-01-01", date < "2011-01-01")
monitoring <- Chicago \%>\% filter(date >= "2011-01-01", date < "2012-12-31")
lm_fit <- linear_reg() \%>\% fit(ridership ~ ., data = training_data)

library(pins)
b <- board_temp()

## before starting monitoring, initiate the metrics and pin
## (for example, with the testing data):
original_metrics <-
    augment(lm_fit, new_data = testing_data) \%>\%
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
pin_write(b, original_metrics, "lm_fit_metrics", type = "arrow")

## to continue monitoring with new data, compute metrics and update pin:
new_metrics <-
    augment(lm_fit, new_data = monitoring) \%>\%
    vetiver_compute_metrics(date, "week", ridership, .pred, every = 4L)
vetiver_pin_metrics(b, new_metrics, "lm_fit_metrics")
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link[=vetiver_compute_metrics]{vetiver_compute_metrics()}}, \code{\link[=vetiver_plot_metrics]{vetiver_plot_metrics()}}
}
