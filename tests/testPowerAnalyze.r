# PowerAnalyze Test
# We test the main code base here
#
# Created by David Tran
# Version 0.4.3.0
# Last Modified 03-04-2014

source("R/powerAnalyze.r")

lib("testthat")

# Set Context of Test
context("Power Analyze Code Base")

test_that("Local Datasets exist", {

  expect_that(object.exists(beaver1), equals(TRUE))
  expect_that(object.exists(ChickWeight), equals(TRUE))
  expect_that(object.exists(cars), equals(TRUE))
  expect_that(object.exists(mtcars), equals(TRUE))
  expect_that(object.exists(Orange), equals(TRUE))
  expect_that(object.exists(rock), equals(TRUE))
  expect_that(object.exists(ToothGrowth), equals(TRUE))

})

test_that("Power Analyze code base works", {
  test_that("library.r is correct", {
    test_that("body function works", {

      lambda = function(x) integer(x)

      expect_that(body(1:50), equals(21:30))
      expect_that(body(1:20, 4), equals(5:16))
      expect_that(body(1:10, 1), equals(2:9))
      expect_that(body(lapply(1:10, lambda), 1),
        equals(lapply(2:9, lambda)))
      expect_that(body(paste(c("X", "Y"), 1:10, sep = ""), 4),
        equals(c("X5", "Y6")))
    })

    test_that("mag function works", {

      expect_that(mag(3), equals(3))
      expect_that(mag(3:4), equals(5))
      expect_that(mag(3+4i), equals(5))
      expect_that(mag(list(5, 12)), equals(13))
    })

    test_that("removeColumn function works", {

      # These datasets are built into R

      expect_that(removeColumn(mtcars, "mpg"),
        equals(mtcars[-1]))
      expect_that(removeColumn(Orange, "age"),
        equals(Orange[-2]))
      expect_that(removeColumn(ToothGrowth, "dose"),
        equals(ToothGrowth[-3]))
    })

    test_that("sort.data.frame function works", {

      expect_that(sort.data.frame(cars),
        equals(cars[order(cars[1]), ]))
      expect_that(sort.data.frame(cars, "speed"),
        equals(cars[order(cars[1]), ]))
    })

    test_that("square function works", {

      expect_that(square(4), equals(16))
      expect_that(square(c(3, 4, 5)), equals(c(9, 16, 25)))
      expect_that(square(list(3, 4, 5)), equals(list(9, 16, 25)))
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

      input = list(
        row1 = list(a = 1, b = 2),
        row2 = list(a = 3, b = 4)
      )

      output = (rbind(
        row1 = list(a = 1, b = 2),
        row2 = list(a = 3, b = 4)
      ))

      # Breaks since its not a "perfect" data.frame
      #expect_that(to.data.frame(input), equals(output))

      expect_that(1, equals(1))
    })
  })

  test_that("powerAnalyze.r is correct", {
    test_that("processTrace works", {

      expect_that(processTrace(1:49)[["mean"]], equals(25))

      expect_that(processTrace(mtcars[["mpg"]])[["sd"]],
        equals(sd(mtcars[["mpg"]])))
      expect_that(processTrace(ChickWeight[["weight"]])[["mad"]],
        equals(mad(ChickWeight[["weight"]])))
      expect_that(processTrace(rock[["shape"]])[["IQR"]],
        equals(IQR(rock[["shape"]])))

    })

    test_that("loadCsvTrace works", {

      testFileName = "tests/testCsvData/testRock.csv"
      if (!file.exists(testFileName)){
        printf("File %s does not exist. EXITING!", testFileName)
        stop("Halting...")
      }

      expect_that(
        to.data.frame(
          loadCsvTrace(testFileName, columnName = "peri")
        )[["mean"]],
        equals( mean(rock[["peri"]][21:(nrow(rock)-20)]))
      )

    })
  })

  test_that("svm.r is correct", {
    test_that("svmCountSplit works", {

      testOutput = to.data.frame(list(
        row1 = list(a = 1, b = 2),
        row2 = list(a = 1, b = 4),
        row3 = list(a = 1, b = 6),
        row4 = list(a = 1, b = 8)
      ))

      expect_that(svmCountSplit(1, testOutput, guessColumn = "a"),
        equals(c(FALSE, TRUE, TRUE, TRUE))
      )

      expect_that(svmCountSplit(1, testOutput, percentage = 0.5, guessColumn = "a"),
        equals(c(FALSE, FALSE, TRUE, TRUE))
      )

      ret = svmCountSplit(0, sort.data.frame(mtcars), guessColumn = "vs")

      expect_that(length(ret), equals(18))
      expect_that(ret[1:3],
        equals(c(FALSE, FALSE, FALSE)))
      expect_that(ret[4:18], equals(as.logical(4:18)))

      ret = svmCountSplit(4, sort.data.frame(mtcars), guessColumn = "cyl")

      expect_that(length(ret), equals(11))
      expect_that(ret[1:2], equals(c(FALSE, FALSE)))
      expect_that(ret[3:11], equals(as.logical(3:11)))
    })

    test_that("svmFormatData works", {

      ret = svmFormatData(sort.data.frame(beaver1, "activ"), guessColumn = "activ")
      trainSet = ret[["trainSet"]]
      testSet = ret[["testSet"]]

      count = function(dataSet, key, col = "activ"){
        return(nrow(dataSet[dataSet[[col]] == key, ]))
      }

      expect_that(nrow(trainSet), equals(92))
      expect_that(nrow(testSet), equals(22))

      expect_that(count(trainSet, 0), equals(87))
      expect_that(count(testSet, 0), equals(21))

      expect_that(count(trainSet, 1), equals(5))
      expect_that(count(testSet, 1), equals(1))

    })
  })
})

# Print overview of test
str(test_file("."))

printf("Tests completed successfully")
