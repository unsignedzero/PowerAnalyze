# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is the main package managing the data flow.
#
# Created by David Tran
# Version 0.4.0.0
# Last Modified 02-01-2014

# Add more files with this
source('library.r')
source('svm.r')

# Debugger state
DEBUG = FALSE

# Aliases for easier printing
printf = function (...) print(sprintf(...))
debugprint = function (...) if (DEBUG) print(...)
debugprintf = function (...) if (DEBUG) printf(...)

# Main trace functions

labelTrace = function(dataLabel) {

  # Regexes the string and maps it to a number

  retLabel = NA

  if (is.null(dataLabel)){
    retLabel = -1
  }
  else if (grepl('baseline', dataLabel)){
    retLabel = 1
  }
  else if (grepl('Graph500', dataLabel)){
    retLabel = 2
  }
  else if (grepl('nsort', dataLabel)){
    retLabel = 3
  }
  else{
    retLabel = 0
  }

  return (as.character(retLabel))
}

processTrace = function (traceVector, label=NULL){

  # Applies the statistics functions to the input vector and returns it
  # labeled

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
  columnName = 'watts' ) {

  # Attempts to open and read the csv and says if it works

  if ((is.null(fileName))| is.na(fileName) | (!file.exists(fileName))){
    printf("File passed %s does not exist.", fileName)
    return (NA)
  }
  else {
    debugprintf("Loading %s", fileName)
  }

  successfulCallCount()

  # Grab what we need from the data
  trimmedData = ((body(read.csv(fileName))))

  usefulColumns = c(columnName)

  if (usefulColumns %in% colnames(trimmedData)){
    trimmedData=trimmedData[usefulColumns]
  }
  else {
    printf("File %s does not contain column %s Exiting.",
      fileName, usefulColumns)
    stop("Exiting...")
  }

  names(trimmedData) = c()

  # Get statistical work
  return (lapply(trimmedData,function(x) processTrace(x, fileName)))
}

main = function () {

  # Reads in input and setups the call chain for all other functions.

  debugprintf("Code read successfully. Executing...")
  args=(commandArgs(TRUE))
  currentDir=getwd()

  if(length(args)==0){
    printf(
      "No arguments supplied. Grabbing all files in the current directory")
  }
  else{
    setwd(file.path(getwd(),args[1]))
  }

  # Loads only files with CSV extension
  args=list.files(pattern='\\.csv$')

  fileargs=Filter(file.exists, args)

  if (length(fileargs)==0){
    printf("No files were successfully located at %s", getwd())
    stop("Halting execution.")
  }

  # We create an instance of the above for our record
  callCounter = successCount()

  outputDataFrame = sapply(fileargs,
    function(x) loadCsvTrace(x, callCounter))

  setwd(currentDir)

  return (svmMain(do.call(rbind.data.frame,outputDataFrame)[1:2]))
}

print(tee(main()))
