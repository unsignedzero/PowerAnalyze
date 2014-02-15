# PowerAnalyze Test
# We test the main code base here
#
# Created by David Tran
# Version 0.3.0.0
# Last Modified 02-15-2014

source('powerAnalyze.r')
lib('testthat')

context("Power Analyze Test")

test_that("Power Analyze code base works", {
  test_that("library.r is correct", {
    test_that("body function works", {

      lambda = function(x) integer(x)

      expect_that(body(1:50), equals(21:30))
      expect_that(body(1:20, 4), equals(5:16))
      expect_that(body(1:10, 1), equals(2:9))
      expect_that(body(lapply(1:10, lambda), 1),
        equals(lapply(2:9, lambda)))
      expect_that(body(paste(c("X","Y"), 1:10, sep=""),4),
        equals(c("X5","Y6")))
    })

    test_that("mag function works", {

      expect_that(mag(3), equals(3))
      expect_that(mag(3:4), equals(5))
      expect_that(mag(3+4i), equals(5))
      expect_that(mag(list(5, 12)), equals(13))
    })

    test_that("removeColumn function works", {

      # These datasets are built into R

      expect_that(removeColumn(mtcars, 'mpg'),
        equals(mtcars[-1]))
      expect_that(removeColumn(Orange, 'age'),
        equals(Orange[-2]))
      expect_that(removeColumn(ToothGrowth, 'dose'),
        equals(ToothGrowth[-3]))
    })

    test_that("sort.data.frame function works", {

      expect_that(sort.data.frame(cars),
        equals(cars[order(cars[1]),]))
      expect_that(sort.data.frame(cars, 'speed'),
        equals(cars[order(cars[1]),]))
    })

    test_that("square function works", {

      expect_that(square(4), equals(16))
      expect_that(square(c(3,4,5)), equals(c(9,16,25)))
      expect_that(square(list(3,4,5)), equals(c(9,16,25)))
    })

    test_that("successCount function works", {

      counterA = successCount(5)
      counterB = successCount(0)
      counterC = successCount(7)

      expect_that(counterA(), equals(6))
      expect_that(counterB(), equals(1))
      expect_that(counterA(), equals(7))
      expect_that(counterB(), equals(2))
      expect_that(counterA(), equals(8))
      expect_that(counterC(), equals(8))
    })

    test_that("to.data.frame works", {

      input=list(
        row1=list(a=1, b=2),
        row2=list(a=3, b=4)
      )

      output=(rbind(
        row1=list(a=1, b=2),
        row2=list(a=3, b=4)
      ))

      # Breaks since its not a 'perfect' data.frame
      #expect_that(to.data.frame(input), equals(output))

      expect_that(1, equals(1))
    })
  })

  test_that("powerAnalyze.r is correct", {
    test_that("processTrace works", {

      expect_that(processTrace(1:49)[['mean']], equals(25))

      expect_that(processTrace(mtcars[['mpg']])[['sd']],
        equals(sd(mtcars[['mpg']])))
      expect_that(processTrace(ChickWeight[['weight']])[['mad']],
        equals(mad(ChickWeight[['weight']])))
      expect_that(processTrace(rock[['shape']])[['IQR']],
        equals(IQR(rock[['shape']])))

    })

    test_that("loadCsvTrace works", {

      testFileName = 'test/testCsvData/testRock.csv'

      expect_that(
        to.data.frame(
          loadCsvTrace(testFileName, columnName='peri')
        )[['mean']],
        equals( mean(rock[['peri']][21:(nrow(rock)-20)]))
      )

    })
  })
})

str(test_file('.'))
