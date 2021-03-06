library(testthat)
context("RidgeLFMM")

test_that("RidgeLFMM_main", {

  K <- 3
  dat <- lfmm_sampler(n = 100, p = 1000, K = K,
                      outlier.prop = 0.1,
                      cs = c(0.8),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)

  lambda <- 1e-5
  P.list <- compute_P(X = dat$X, lambda = lambda)

  m <- ridgeLFMM(K = K,
                 lambda = lambda)

  res <- ridgeLFMM_main(m, dat, P.list)

  svd.res <- svd(P.list$sqrt.P %*% dat$Y)
  expect_lte(mean(abs(svd.res$v[,1:K] - res$V)), 0.06)
  ## RMK: error very high, it is because for this data first K singular values
  ## are quite the same.
  ## svd.res$d

})


test_that("comp with lfmmR", {

  skip_if_not_installed("ThesisRpackage")
  require(ThesisRpackage)
  dat <- lfmm_sampler(n = 100, p = 1000, K = 3,
                      outlier.prop = 0.1,
                      cs = c(0.8),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)
  dat.list <- list(G = dat$Y, X = dat$X)

  K <- 3
  lambda <- 1e-5

  ## lfmm implemented in R
  lfmmR <- finalLfmmRdigeMethod(K = 3, lambda = lambda)
  lfmmR$center <- FALSE
  lfmmR <- fit(lfmmR, dat.list)

  ## lfmm implemented with rsvd
  lfmm <- ridgeLFMM(K = K,
                    lambda = lambda)
  lfmm <- lfmm_fit(lfmm, dat)

  expect_equal(dim(lfmm$B), c(1000, 1))
  expect_equal(dim(lfmm$U), c(100, K))
  expect_equal(dim(lfmm$V), c(1000, K))

  ## comparison
  W.lfmm <- tcrossprod(lfmm$U, lfmm$V)
  W.lfmmR <- tcrossprod(lfmmR$U, lfmmR$V)
  expect_lte(mean(abs(W.lfmmR - W.lfmm)), 1e-6)
  expect_lte(mean(abs(lfmm$B - t(lfmmR$B))), 1e-6)
  ## rmk: we do not use same P... but it is still close :D

})

test_that("ridgeLFMM of ThesisRpackage with NA", {

  skip("a test only to debug")
  skip_if_not_installed("ThesisRpackage")
  futile.logger::flog.threshold(futile.logger::TRACE, name = "ThesisRpackage")
  require("ThesisRpackage")
  
  n <- 100
  p <- 1000
  dat <- lfmm_sampler(n = n, p = p, K = 3,
                      outlier.prop = 0.1,
                      cs = c(0.8),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)
  dat <- as.list(dat)
  dat$G <- dat$Y
  dat$Y <- NULL

  ## no NA
  lfmm.noNA <- finalLfmmRdigeMethod(K = 3, lambda = 1e-5)
  lfmm.noNA <- fit(lfmm.noNA, dat)

  ## add na
  na.ind <- sample.int(n * p, 0.5 * n * p)
  dat$G[na.ind] <- NA

  ## lfmm with na
  lfmm.NA <- finalLfmmRdigeMethod(K = 3, lambda = 1e-5)
  lfmm.NA <- fit(lfmm.NA, dat)

  ## impute by median first
  dat$G <- impute_median(dat$G)
  lfmm.NA.impute <- finalLfmmRdigeMethod(K = 3, lambda = 1e-5)
  lfmm.NA.impute <- fit(lfmm.NA.impute, dat)

  ## comparison W
  W.NA <- tcrossprod(lfmm.NA$U, lfmm.NA$V)
  W.noNA <- tcrossprod(lfmm.noNA$U, lfmm.noNA$V)
  W.NA.impute <- tcrossprod(lfmm.NA.impute$U, lfmm.NA.impute$V)
  e1 <- sqrt(mean((W.NA - W.noNA) ^ 2))
  e2 <- sqrt(mean((W.NA.impute - W.noNA) ^ 2))
  expect_gt((e2 - e1) / e1, 5)

  ## comparison B
  e1 <- sqrt(mean((lfmm.noNA$B - lfmm.NA$B) ^ 2))
  e2 <- sqrt(mean((lfmm.noNA$B - lfmm.NA.impute$B) ^ 2))
  expect_gt((e2 - e1) / e1, 1)

})

test_that("ridgeLFMM with NA", {

  set.seed(454)
  n <- 100
  p <- 1000
  dat <- lfmm_sampler(n = n, p = p, K = 3,
                      outlier.prop = 0.1,
                      cs = c(0.8),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)
  dat.list <- list(G = dat$Y, X = dat$X)

  ## no NA
  lfmm.noNA<- ridgeLFMM(K = 3, lambda = 1e-5)
  lfmm.noNA<- lfmm_fit(lfmm.noNA, dat)

  ## add na
  na.ind <- sample.int(n * p, 0.1 * n * p)
  dat$Y[na.ind] <- NA
  dat.list$Y[na.ind] <- NA

  ## lfmm with na
  lfmm.NA <- ridgeLFMM(K = 3, lambda = 1e-5)
  lfmm.NA <- lfmm_fit(lfmm.NA, dat)

  ## impute by median first
  dat$Y <- impute_median(dat$Y)
  lfmm.NA.impute <- ridgeLFMM(K = 3, lambda = 1e-5)
  lfmm.NA.impute <- lfmm_fit(lfmm.NA.impute, dat)

  ## comparison W
  W.NA <- tcrossprod(lfmm.NA$U, lfmm.NA$V)
  W.noNA <- tcrossprod(lfmm.noNA$U, lfmm.noNA$V)
  W.NA.impute <- tcrossprod(lfmm.NA.impute$U, lfmm.NA.impute$V)
  e1 <- sqrt(mean((W.NA - W.noNA) ^ 2))
  e2 <- sqrt(mean((W.NA.impute - W.noNA) ^ 2))
  (e2 - e1) / e1
  expect_gt((e2 - e1) / e1, 5)

  ## comparison B
  e1 <- sqrt(mean((lfmm.noNA$B - lfmm.NA$B) ^ 2))
  e2 <- sqrt(mean((lfmm.noNA$B - lfmm.NA.impute$B) ^ 2))
  (e2 - e1) / e1
  expect_gt((e2 - e1) / e1, 2)

})

test_that("ridgeLFMM CV", {

  n <- 100
  p <- 1000
  dat <- lfmm_sampler(n = n, p = p, K = 3,
                      outlier.prop = 0.1,
                      cs = c(0.6),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)

  lfmm <- ridgeLFMM(K = 3, lambda = 1e-5)

  cv.err <- lfmm_CV(m = lfmm,
                    dat = dat,
                    n.fold.row = 5,
                    n.fold.col = 5,
                    lambdas = c(1e-10, 1 , 1e20),
                    Ks = c(1, 2,3,4,5,6),
                    col.prop = 1.0)
  expect_equal(dim(cv.err), c(6 * 3 * 5 * 5, 4))

  skip("plots")
  ggplot(cv.err, aes(y = err, x = as.factor(K))) +
    geom_boxplot() +
    facet_grid(lambda ~ ., scale = "free")

  ggplot(cv.err, aes(y = err, x = as.factor(lambda))) +
    geom_boxplot() +
    facet_grid(K ~ ., scales = "free")

})

test_that("lassoLFMM CV", {


  skip('cross validation ne marche pas ....')
  
  n <- 100
  p <- 1000
  dat <- lfmm_sampler(n = n, p = p, K = 3,
                      outlier.prop = 0.1,
                      cs = c(0.6),
                      sigma = 0.2,
                      B.sd = 1.0,
                      U.sd = 1.0,
                      V.sd = 1.0)

  lfmm <- lassoLFMM(K = 3, nozero.prop = NULL, lambda.num = 10, lambda.min.ratio = 0.001)

  cv.err <- lfmm_CV(m = lfmm,
                                    dat = dat,
                                    n.fold.row = 5,
                                    n.fold.col = 2,
                                    col.prop = 1.0,
                                    it.max = 100, relative.err.epsilon = 1e-4
                                    )

  expect_equal(dim(cv.err), c(6 * 3 * 2 * 5, 3))

  skip("plots")

  ggplot(cv.err, aes(y = err, x = as.factor(lambda))) +
    geom_boxplot() 

  ggplot(cv.err, aes(y = err, x = nozero.prop)) +
    geom_smooth()

})
