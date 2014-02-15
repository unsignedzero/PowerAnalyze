# PowerAnalyze Test
# We test the main code base here
#
# Created by David Tran
# Version 0.1.0.0
# Last Modified 02-15-2014

source('powerAnalyze.r')
lib('testthat')

context("Power Analyze Test")

test_that("Power Analyze code base works", {
  test_that("Testing library.r", {
    expect_that(body(1:50), equals(21:30))
  })
})

test_file('.')
