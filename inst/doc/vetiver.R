## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = requireNamespace("parsnip", quietly = TRUE) && requireNamespace("recipes", quietly = TRUE) && requireNamespace("workflows", quietly = TRUE)
)

## -----------------------------------------------------------------------------
library(parsnip)
library(recipes)
library(workflows)
data(bivariate, package = "modeldata")
bivariate_train

biv_rec <-
  recipe(Class ~ ., data = bivariate_train) %>%
  step_BoxCox(all_predictors())%>%
  step_normalize(all_predictors())

svm_spec <-
  svm_linear(mode = "classification") %>%
  set_engine("LiblineaR")

svm_fit <- 
  workflow(biv_rec, svm_spec) %>%
  fit(sample_frac(bivariate_train, 0.7))

## -----------------------------------------------------------------------------
library(vetiver)
v <- vetiver_model(svm_fit, "biv_svm")
v

## ----message=FALSE------------------------------------------------------------
library(pins)
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

## ----message=FALSE------------------------------------------------------------
svm_fit <- 
  workflow(biv_rec, svm_spec) %>%
  fit(sample_frac(bivariate_train, 0.7))

v <- vetiver_model(svm_fit, "biv_svm")

model_board %>% vetiver_pin_write(v)

## -----------------------------------------------------------------------------
model_board %>% pin_versions("biv_svm")

## -----------------------------------------------------------------------------
library(plumber)
pr() %>%
  vetiver_api(v)

## ----eval=FALSE---------------------------------------------------------------
#  vetiver_write_plumber(model_board, "biv_svm")

## ----echo=FALSE, comment = ""-------------------------------------------------
tmp <- tempfile()
vetiver_write_plumber(model_board, "biv_svm", file = tmp)
cat(readr::read_lines(tmp), sep = "\n")

## -----------------------------------------------------------------------------
library(vetiver)
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint

