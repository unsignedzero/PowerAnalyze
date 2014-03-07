# PowerAnalyze
# Reads in power traaces and processes them accordingly.
# The output is a data frame that is passed into
# the SVM module with the correct group information.
#
# This is the main package managing the data flow.
#
# Created by David Tran (unsignedzero)
# Version 0.8.0.1
# Last Modified 03-07-2014

# Load the other src code.
# Path check if documentation is being built or not.
if (object.exists(docBuild)){
  source("library.r")
  source("svm.r")
}
if (!object.exists(docBuild)){
  source("R/library.r")
  source("R/svm.r")
}

#' Debugger flag. Set TRUE to enable debugging or false otherwise.
#'
#' With this off, the verbosity is at a minimum.
#'
#' @usage DEBUG <- logical type
#' @format logical type (default FALSE)
DEBUG <- FALSE

#' Plot data flag. Set TRUE to plot out all input data.
#'
#' Can slow down the program given large inputs. The values are not modified
#' before being plotted.
#'
#' @usage PLOTDATA <- logical type
#' @format logical type (default FALSE)
PLOTDATA <- FALSE

# Aliases for easier printing
printf <- function (...) print(sprintf(...))
debugprint <- function (...) if (DEBUG) print(...)
debugprintf <- function (...) if (DEBUG) printf(...)

#' Given a string label, this function maps the label to a group ID number.
#'
#' This is used to group different filenames into similar groups. This uses
#' regexes and should be EDITED before working on different data sets. This
#' allows the SVM to group different datasets correctly.
#'
#' NAs will return a -1.
#'
#' @param dataLabel The string that will used to identify a group ID.
#' @return A group ID or 0 if it can't be matched.
labelTrace <- function( dataLabel ) {

  retLabel <- NA

  if (is.null(dataLabel)){
    retLabel <- -1
  }
  else if (grepl("^.._baseline", dataLabel)){
    retLabel <- 1
  }
  else if (grepl("^.._Graph500", dataLabel)){
    retLabel <- 2
  }
  else if (grepl("^.._nsort", dataLabel)){
    retLabel <- 3
  }
  else if (grepl("^.._p95", dataLabel)){
    retLabel <- 4
  }
  else if (grepl("^.._stream", dataLabel)){
    retLabel <- 5
  }
  else if (grepl("^.._systemburn_DGEMM", dataLabel)){
    retLabel <- 6
  }
  else if (grepl("^.._systemburn_FFT1D", dataLabel)){
    retLabel <- 7
  }
  else if (grepl("^.._sb_fft1d", dataLabel)){
    retLabel <- 7
  }
  else if (grepl("^.._systemburn_FFT2D", dataLabel)){
    retLabel <- 8
  }
  else if (grepl("^.._systemburn_GUPS", dataLabel)){
    retLabel <- 9
  }
  else if (grepl("^.._systemburn_SCUBLAS", dataLabel)){
    retLabel <- "A"
  }
  else if (grepl("^.._systemburn_TILT", dataLabel)){
    retLabel <- "B"
  }
  else if (grepl("^.._sb_tilt", dataLabel)){
    retLabel <- "B"
  }
  else if (grepl("^.._calib", dataLabel)){
    retLabel <- "C"
  }
  else{
    printf("labelTrace: Bad label for %s", dataLabel)
    retLabel <- 0
  }

  retLabel <- as.character(retLabel)

  debugprintf("File %s, labeled as %s", dataLabel, retLabel)

  return(retLabel)
}

#' Given a vector and a label, returns a vector containing its group ID and
#' output from mean, median, sd, mad and IQR.
#'
#' This function, preforms the mean, median, sd, mad and IQR on the dataset.
#' This returns back a six-element vector containing the group ID of the trace
#' and then the outputs of mean, median, sd, mad and IQR.
#'
#' @param traceVector The input numeric vector.
#' @param label (optional, default NULL) The label for the trace that will be
#'   used to group the trace.
#' @return A new vector contains the group ID and output of the statistical
#'   functions.
processTrace <- function ( traceVector, label = NULL ) {

  funs <- c(mean, median, sd, mad, IQR)
  output <- lapply(funs, function(f) f(traceVector, na.rm = TRUE))

  # Add "label" to first entry in vector.
  traceLabel <- labelTrace(label)
  output <- c(traceLabel, output)

  names(output) <- c("label",
    c("mean", "median", "sd", "mad", "IQR")
  )

  return(output)
}

#' Opens the csv files and processes the data, returning a list containing
#' the condensed output of processTrace.
#'
#' This is a loader function that calls other functions and processes the
#' data so that it will work for the next function. This function is called
#' once for each csv file. Invalid or malformatted files return NA.
#'
#' If plots of the input csv are desired, it is suggested that the flag
#' PLOTDATA be set to true.
#'
#' @param filename The csv file that will be opened and processed.
#' @param successfulCallCount A counter function, counting how many times
#'   this function was successfully executed. Mainly used for counting bad
#'   files.
#' @param columnName The column name, from the csv, that will be used as
#'   the dataset.
#' @param transformFunction A function that should transform the data,
#'   i.e. FFT, if desired. This will apply itself before processTrace is
#'   called.
#' @return A list containing the output of processTrace. Each row maps to
#'   a csv file.
#' @seealso \code{\link{processTrace}}
loadCsvTrace <- function ( fileName, successfulCallCount = function() NULL,
  columnName = "watts", transformFunction = function (x) x ) {

  if ((is.null(fileName))| is.na(fileName) | (!file.exists(fileName))){
    printf("loadCsvTrace: File passed %s does not exist.", fileName)
    return(NA)
  }
  else {
    debugprintf("loadCsvTrace: Loading %s", fileName)
  }

  # Grab what we need from the data
  trimmedData <- ((body(read.csv(fileName))))

  usefulColumns <- c(columnName)

  # Plot it
  if (PLOTDATA){
    plotPowerTrace(dataFrame = trimmedData, y = "watts",
      fileName = subStr(fileName, 1, nchar(fileName) - 4))
  }

  if (usefulColumns %in% colnames(trimmedData)){
    trimmedData = trimmedData[usefulColumns]
  }
  else {
    printf("loadCsvTrace: File %s does not contain column %s Exiting.",
      fileName, usefulColumns)
    stop("Exiting...")
  }

  # Transform Data as needed
  trimmedData[usefulColumns] <- transformFunction(trimmedData[[usefulColumns]])

  # Removes header info
  names(trimmedData) <- c()

  successfulCallCount()
  debugprintf("loadCsvTrace: File %s processed", fileName)

  # Get statistical work
  return(lapply(trimmedData, function(x) processTrace(x, fileName)))
}

#' Takes a directory of CSV files, loads it and calls other functions to
#' process and parse the input. Then it is passed into the SVM package.
#'
#' This function sets up the calls for all other functions. Implicitly,
#' it is assumed that the data is in separate files. If the data is already
#' collected, from another run, processedMain may be used instead to speed
#' up the process and avoid processing the CSV files.
#'
#' @param transformFunction A function that will be used to transform the
#'   data, i.e. FFT.
#' @param svmProcessFunction (optional, default NULL) An SVM process function
#'   stating which mode to use.
#' @return The output of svmMain which is the data set passed in
#' @seealso \code{\link{processedMain}}
main <- function ( transformFunction = function(x) x,
    svmProcessFunction = NULL) {

  debugprintf("Code read successfully. Executing...")
  args <- (commandArgs(TRUE))
  currentDir <- getwd()

  if (length(args) == 0){
    printf(
      "main: No arguments supplied. Grabbing all files in the current directory %s",
      getwd())
  }
  else{
    setwd(file.path(getwd(), args[1]))
  }

  # Loads only files with CSV extension
  args <- list.files(pattern = "\\.csv$")

  fileargs <- Filter(file.exists, args)

  if (length(fileargs) == 0){
    printf("main: No files were successfully located at %s", getwd())
    stop("Halting execution.")
  }

  # We create an instance of a call counter for debugging purposes
  callCounter <- successCount()

  outputDataFrame <- sapply(fileargs, loadCsvTrace, callCounter,
    columnName = "watts", transformFunction = transformFunction)

  setwd(currentDir)

  # Configure the feature set that will passed into the SVM here
  return(svmMain(tee(to.data.frame(outputDataFrame)[1:3]),
    svmProcessFunction = svmProcessFunction))
}

#' A variant of main that reads in the csv and passes it onto SVM.
#'
#' No processing is done here. If the data needs to be processed,
#' use main instead.
#'
#' @param selectedCols The vector of columns names used to pick off the desired
#'   elements for the feature vector that will be used in the SVM.
#' @param svmProcessFunction (optional, default NULL) An SVM process function
#'   stating which mode to use.
#' @return The output of svmMain which is the data set passed in
#' @seealso \code{\link{main}}
processedMain <- function ( selectedCols = c("label", "mean"),
    svmProcessFunction = NULL ) {

  debugprintf("Code read successfully. Executing...")
  args <- (commandArgs(TRUE))
  fileName <- NULL

  if (length(args) == 0){
    stop("main: No processed csv passed. Exiting....")
  }

  fileName <- args[1]

  if (!file.exists(fileName)){
    printf("File passed %s does not exist.", fileName)
    stop("Halting...")
  }

  outputDataFrame <- read.csv(fileName)

  return(svmMain(outputDataFrame[selectedCols],
    svmProcessFunction = svmProcessFunction))

}

