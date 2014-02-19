# PowerAnalyze
# This r file will read power traces and attempt to classify them
# via svm.r
#
# This is the main package managing the data flow.
#
# Created by David Tran
# Version 0.5.2.0
# Last Modified 02-18-2014

# Add more files with this
source('R/library.r')
source('R/svm.r')

#' Debugger flag. Set TRUE to enable debugging or false otherwise.
DEBUG = FALSE

# Aliases for easier printing
printf = function (...) print(sprintf(...))
debugprint = function (...) if (DEBUG) print(...)
debugprintf = function (...) if (DEBUG) printf(...)

#' Given a string label, this function labels the trace. This is used to group
#' different files together as one group to be able to run svm correctly.
#'
#' @param dataLabel the string that will
#' @return returns the label or 0 is it can't label.
labelTrace = function(dataLabel) {

  retLabel = NA

  if (is.null(dataLabel)){
    retLabel = -1
  }
  else if (grepl('^.._baseline', dataLabel)){
    retLabel = 1
  }
  else if (grepl('^.._Graph500', dataLabel)){
    retLabel = 2
  }
  else if (grepl('^.._nsort', dataLabel)){
    retLabel = 3
  }
  else if (grepl('^.._p95', dataLabel)){
    retLabel = 4
  }
  else if (grepl('^.._stream', dataLabel)){
    retLabel = 5
  }
  else if (grepl('^.._systemburn_DGEMM', dataLabel)){
    retLabel = 6
  }
  else if (grepl('^.._systemburn_FFT1D', dataLabel)){
    retLabel = 7
  }
  else if (grepl('^.._sb_fft1d', dataLabel)){
    retLabel = 7
  }
  else if (grepl('^.._systemburn_FFT2D', dataLabel)){
    retLabel = 8
  }
  else if (grepl('^.._systemburn_GUPS', dataLabel)){
    retLabel = 9
  }
  else if (grepl('^.._systemburn_SCUBLAS', dataLabel)){
    retLabel = 'A'
  }
  else if (grepl('^.._systemburn_TILT', dataLabel)){
    retLabel = 'B'
  }
  else if (grepl('^.._sb_tilt', dataLabel)){
    retLabel = 'B'
  }
  else if (grepl('^.._calib', dataLabel)){
    retLabel = 'C'
  }
  else{
    printf("labelTrace: Bad label for %s", dataLabel)
    retLabel = 0
  }

  retLabel = as.character(retLabel)

  debugprintf("File %s, labeled as %s", dataLabel, retLabel)

  return (retLabel)
}

#' Given the traceVector and a label, labels the associated trace and
#' computes the statistics functions in funs
#'
#' @param traceVector the input vector that the statistical functions will
#'   act on
#' @param label the label for the trace that will be converted
#' @return a new vector contains the output of the statistical functions
#'   and its label
processTrace = function (traceVector, label=NULL){

  funs = c(mean, median, sd, mad, IQR)
  output = lapply(funs, function(f) f(traceVector, na.rm = TRUE))

  # Add 'label' to first entry in vector.
  traceLabel = labelTrace(label)
  output = c(traceLabel,output)

  names(output) = c("label",
    c("mean", "median", "sd", "mad", "IQR")
  )

  return (output)
}

loadCsvTrace = function ( fileName, successfulCallCount = function() NULL,
  columnName = 'watts', transformFunction = function (x) x ) {

  # Attempts to open and read the csv and says if it works

  if ((is.null(fileName))| is.na(fileName) | (!file.exists(fileName))){
    printf("loadCsvTrace: File passed %s does not exist.", fileName)
    return (NA)
  }
  else {
    debugprintf("loadCsvTrace: Loading %s", fileName)
  }

  # Grab what we need from the data
  trimmedData = ((body(read.csv(fileName))))

  usefulColumns = c(columnName)

  if (usefulColumns %in% colnames(trimmedData)){
    trimmedData = trimmedData[usefulColumns]
  }
  else {
    printf("loadCsvTrace: File %s does not contain column %s Exiting.",
      fileName, usefulColumns)
    stop("Exiting...")
  }

  # Transform Data as needed
  trimmedData[usefulColumns] = transformFunction(trimmedData[[usefulColumns]])

  # Removes header info
  names(trimmedData) = c()

  successfulCallCount()
  debugprintf("loadCsvTrace: File %s processed", fileName)

  # Get statistical work
  return (lapply(trimmedData, function(x) processTrace(x, fileName)))
}

main = function ( transformFunction = function(x) x) {

  # Reads in input and setups the call chain for all other functions.

  debugprintf("Code read successfully. Executing...")
  args = (commandArgs(TRUE))
  currentDir = getwd()

  if(length(args)==0){
    printf(
      "main: No arguments supplied. Grabbing all files in the current directory %s",
      getwd())
  }
  else{
    setwd(file.path(getwd(),args[1]))
  }

  # Loads only files with CSV extension
  args=list.files(pattern='\\.csv$')

  fileargs=Filter(file.exists, args)

  if (length(fileargs) == 0){
    printf("main: No files were successfully located at %s", getwd())
    stop("Halting execution.")
  }

  # We create an instance of a call counter for debugging purposes
  callCounter = successCount()

  outputDataFrame = sapply(fileargs, loadCsvTrace, callCounter,
    columnName='watts', transformFunction=transformFunction)

  setwd(currentDir)

  return (svmMain(tee(to.data.frame(outputDataFrame))))
}

processedMain = function ( selectedCols = c('label', 'mean') ){

  # Main that takes in a processed Data Frame and passes it to SVM

  debugprintf("Code read successfully. Executing...")
  args = (commandArgs(TRUE))
  fileName = NULL

  if(length(args) == 0){
    stop("main: No processed csv passed. Exiting....")
  }

  fileName = args[1]

  if (!file.exists(fileName)){
    printf("File passed %s does not exist.", fileName)
    stop("Halting...")
  }

  outputDataFrame = read.csv(fileName)

  return (svmMain(outputDataFrame[selectedCols]))
}

