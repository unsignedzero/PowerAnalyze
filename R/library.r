# PowerAnalyze Library Module
# A collection of support functions for PowerAnalyze.
#
# Created by David Tran (unsignedzero)
# Version 0.8.0.1
# Last Modified 03-07-2014

#' Grabs all but the first nth and last nth elements of a list.
#'
#' As oppose to head and tail, we grab all but the first nth
#' and last nth elements of the data, if it is possible, and return the empty
#' container otherwise.
#'
#' @param data The data input data structure (data.frame, list, or vector)
#' @param n (optional, default 20) Specifies the number of elements from the
#'   front and end that will be removed.
#' @return The data structure with the elements removed or the empty
#'   structure if it is not possible.
#' @examples
#' body(1:50) -> 21:30
#' body(1:6, 2) -> 3:4
#' body(1:10, n = 4) -> 5:6
body <- function ( data, n = 20 ) {

  if (class(data) == "data.frame"){
    len <- nrow(data)
    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return(data[NULL, ])
    }

    return(data[(n+1):(len-n), ])

  } else if (class(data) == "list"   || class(data) == "integer" ||
            class(data) == "numeric" || class(data) == "character" ||
            class(data) == "logical" ){
    len <- length(data)

    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return(NULL)
    }

    output <- data[(n+1):(len-n)]
    print(output)
    return(output)

  } else{
    printf("body: Unknown data type %s", class(data))
    return(NA)
  }
}

#' Preforms the dot product on two numeric lists.
#'
#' Multiplies matching elements in different lists and adds all these products
#' together. Unlike R, unequal list lengths that share a common factor will
#' NOT be multiplied.
#'
#' @param listA The first numeric list that will be used in the dot product.
#' @param listB The second numeric list that will be used in the dot product.
#' @return A value containing the dot product.
dotProduct <- function ( listA, listB ) {

  if (length(listA) != length(listB)){
    printf("Lists %s and %s are not identical in length",
      str(listA), str(listB))
    stop("Halting...")
  }

  return(sum(listA*listB, na.rm = TRUE))
}

#' Stops the program and prints what was passed in.
#'
#' @param ... Prints out anything passed.
#' @return The input but this should not happen.
halt <- function ( ... ) {

  print(...)
  stop("Halting execution...")

  # This should NOT happen
  return(...)
}

#' Installs the package, if it exists, and bypasses the interactive
#' prompt.
#'
#' A wrapper around install.packages, this function installs the package while
#' bypassing the interactive move. This is set to download from
#' the US CRAN repo. The default location, if not specified, is
#' at .libPaths()[1] which can be /usr/lib/R/site-library
#'
#' @param pack The package, as a string that will be installed/loaded.
#' @param ... Any other arguments passed to install.packages.
#' @return NULL This is a statement. Use other functions to check if
#'   install works
#' @examples
#' install("e1071")
#' @seealso \code{\link{lib}}
install <- function ( pack, ... ) {

  install.packages(pack,
    dependencies = TRUE, repos = "http://cran.us.r-project.org",
    ...
  )
}
inst <- install # Function alias

#' Checks if a package is installed and loads it. If not, it will install and
#' then try to load it.
#'
#' Unlike library, this function will INSTALL the package if it is not
#' available on the current system. If the package is already installed, it
#' will load it.
#'
#' Should the package not exist, due to a typo or incompatible version number,
#' this function will error out like library but also return false.
#'
#' @param pack The package, as a string, that will be checked and
#'   loaded/installed accordingly.
#' @param ... Other arguments passed into the libCheck function.
#' @return A boolean value stating if the requested package is loaded.
lib <- function ( pack, ... ) {

  if (libCheck(pack, ...)){
    # Loaded successfully
    return(TRUE)
  }
  else{
    # Try to install and load
    install(pack)
    return(libCheck(pack, ...))
  }
}

#' Checks if a package is installed.
#'
#' Returns true if the package is installed and false otherwise. This DOES NOT
#' emit an error message.
#'
#' @param pack The package, as a string, that will be checked and
#'   loaded/installed accordingly.
#' @param ... Any other arguments for the library function.
#' @return A boolean value stating if the requested package is loaded.
#' @seealso \code{\link{lib}}
libCheck <- function ( pack, ... ) {

  return(suppressWarnings(
    library(pack,
      logical.return = TRUE, character.only = TRUE,
    ...)
    )
  )
}

#' Computes the magnitude of a complex number or a numeric list.
#'
#' For a list, each element is squared before it is added and then the sum is
#' is square rooted. This is analogous to the distance formula. For singletons,
#' this function returns back the value passed.
#'
#' @param x The input numeric list, or complex number.
#' @return The computed magnitude of the input.
#' @examples
#' mag(3, 4) -> 5
#' mag(5 + 12i) -> 13
#' mag(c(6, 8)) -> 10
mag <- function( x ) {

  # Computes the magnitude

  if (class(x) == "numeric"){
    return(x)
  }
  else if (class(x) == "complex"){
    return(sqrt(Re(x)^2 + Im(x)^2))
  }
  else if ((class(x) == "list") || (class(x) == "numeric") ||
           (class(x) == "integer")){
    return(sqrt(sum(sapply(x, function(x) x^2))))
  }
  else{
    stop("Unknown datatype passed")
  }
}

#' Checks if a variable (object) exists.
#'
#' Returns true if it does and false otherwise. Literals are false.
#'
#' @param obj The object, this function will check if it exists.
#' @return A boolean value stating if it exist.
#' @examples
#' object.exists(mtcars) -> TRUE
#' object.exists(1) -> FALSE
#' object.exists(NA) -> FALSE
object.exists <- function( obj ) {

  # Check if an object(variable) exists

  return(exists(as.character(substitute(obj))))

}

#' Plot function used to create plots from Power Traces for posters.
#'
#' Generates a time-series of the dataset with 1:n on the X-axis and the data
#' on the Y-axis. The output is a pdf file.
#'
#' @param dataFrame The input data frame that holds the data.
#' @param y The name of the column that the dataset that will be plotted
#'    lives in.
#' @param fileName The filename for the output without the .pdf extension.
#' @param ... Any other arguments that will be passed into plot.
#' @return The input data frame.
plotPowerTrace <- function ( dataFrame, y, fileName, ... ) {

  if (is.null(fileName)){
    name <- "output"
    fileName <- "output.pdf"
  }
  else{
    name <- fileName
    fileName <- paste(fileName, ".pdf", collapse = "")
  }

  pdf(fileName)
  plot(x = 1:nrow(dataFrame), y = dataFrame[[y]],
    xlab = "Seconds", ylab = "Watts",
    col = "blue",
    main = paste("Power Trace of", name),
    type = "l", ...
  )
  dev.off()

  return(dataFrame)
}

#' Removes a column with its names from a given data frame, if it exists.
#'
#' This is analogous to frame[-n] where n is the column number of the matching
#' column name this function is searching for where n is the length of the
#' input data set.
#'
#' @param frame The input data frame.
#' @param colName A string for a column name is the data frame that will be
#'   removed.
#' @return The data frame with the specified column removed, if possible.
#' @examples
#' removeColumn(mtcars, "mpg")
#' removeColumn(rock, "perm")
removeColumn <- function( frame , colName ) {

  logicVector <- unlist(lapply(colnames(frame),
    function(x) (!grepl(colName, x))))

  return(frame[logicVector])
}

#' Sorts a data frame by the column specified or the first column if not.
#'
#' This function will half if the column passed does not exist.
#'
#' @usage sort.data.frame(frame, col = NULL)
#' @param frame The input data frame that will be sorted.
#' @param col (optional, default NULL) The column name that will be sorted on.
#'   Should be this NULL, the first column is sorted on.
#' @return The sorted data frame.
#' @examples
#' sort.data.frame(mtcars, "wt")
#' sort.data.frame(rock, "shape")
sort.data.frame <- function ( frame, col = NULL ) {

  if (class(frame) == "data.frame"){
    if (is.null(col)){
      return(frame[order(frame[1]), ])
    }
    else if (col %in% colnames(frame)){
      return(frame[order(frame[col]), ])
    }
    else{
      stop("sort: Col %s passed does not exist in data frame %s",
        str(col), str(frame)
      )
      return(-1)
    }
  }
  else if (class(frame) == "list"){
    return(frame[order(unlist(frame))])
  }
  else if (class(frame) == "numeric" || class(frame) == "character" ||
          class(frame) == "integer" )
        {
    return(sort(frame))
  }
  else{
    stop("sort: Unknown data type %s passed.", class(frame))
    return(-1)
  }
}

#' Squares the given input, be it a numeric or vector.
#'
#' In the case of a vector, each element is squared.
#'
#' @param x The numberic input that will be squared.
#' @return The input with all elements squared.
#' @seealso \code{\link{mag}}
#' @examples
#' square(4) -> 16
#' square(list(3, 4)) -> list(16, 25)
square <- function ( x ) {

  if (class(x) == "numeric"){
    return(x^2)
  }
  else{
    return(lapply(x, function(x) x^2))
  }
}

#' Attempts to source the file and its path. Should that fail, it will repeat
#' by removing directories, on the path from the left, and try again.
#'
#' Attempts to add the file and remove directories from the right and tries
#' those combinations as well. May add multiple files.
#'
#' @param filePath The file path of the source file that should be loaded.
#' @return A boolean value containing if it was successfully added.
srcFile <- function ( filePath ) {

  if (file.exists(filePath)){
    source(filePath)
    return (TRUE)
  }
  else{
    pathSplitArray <- unlist(strsplit(filePath, '/'))
    splitCountArray <- 1:length(pathSplitArray)

    splitCheckFunction <- function ( splitLocation, pathSplitArray ) {
      newPath <- paste(pathSplitArray[splitLocation:length(pathSplitArray)],
        collapse = "/")

      if (file.exists(newPath)){
        source(newPath)
        return (splitLocation)
      }
      else{
        return (NA)
      }
    }

    retValue <- sapply(splitCountArray, splitCheckFunction, pathSplitArray)
    filteredRetValue <- which(!is.na(retValue))

    if (!is.na(min(filteredRetValue))) {
      # The file we wann to add  was successfully added
      return (TRUE)
    }
    else {
      return (FALSE)
    }

  }
}

#' Returns a substring of the input the input string.
#'
#' This function may take one argument, which cuts from zero or two arguments
#' to cut at certain points. The cut is inclusive left and exclusive right,
#' that is to say the cut on the left is part of the string and the
#' right point is not. (Remember that R lists start at one, not zero. To
#' have the cut tart at zero, pass in the C_RANGE flag.)
#'
#' If the range is passed in the wrong order, that is fixed.
#'
#' Should the empty string be passed, it is returned back.
#'
#' Should a negative value be passed in, the program is stopped.
#'
#' @param str The input string that will be cut.
#' @param start (optional, default 0) The starting place to cut, or end if
#'   this is the only other argument passed.
#' @param end (optional, default NULL) The end point of the cut, if it is
#'    passed a value.
#' @param C_RANGE A boolean flag stating is C-Ranges (starting at zero)
#'    are passed in. Shifts range by +1 to match R-ranges.
#' @return A substring of the input string.
subStr <- function ( str, start = 0, end = NULL, C_RANGE = FALSE ) {

  if (nchar(str) == 0){
    return(str)
  }

  if (is.null(end)){
    end <- start
    start <- 0
  }

  if (end < start){
    temp <- start
    start <- end
    end <- temp
  }

  if (start < 0){
    stop("subStr range contains negative values")
  }

  if (C_RANGE){
    start = start + 1
    end = end + 1
  }

  if (end > nchar(str)){
    end = nchar(str)
  }

  return(paste((unlist(strsplit(str, ""))[start:end]), collapse = ""))
}

#' An increment counter with local counter value.
#'
#' An increment counter used to count the number of times an event occurred.
#' DEBUG needs to be enabled for this function to print. This is a factory
#' function so the returned value from a call needs to be invoked to increment
#' stored value. The function will also return the value when invoked.
#'
#' @param n (optional, default 0) The initial start value of the counter
#'   that should be an integer.
#' @param startMsg A string that will be shown before the number if it is
#'   printed.
#' @param endMsg A string that will be shown after the number if it is
#'   printed.
#' @return A function that needs to be invoked to increment and return the
#'   contained value.
#' @examples
#' a <- successCount(1)
#' b <- successCount(0)
#' a() -> 2
#' b() -> 0
#' b() -> 1
#' b() -> 2
successCount <- function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ) {

  increment <- function () {
    n <<- n + 1
    debugprintf("%s%d%s", startMsg, n, endMsg)
    return(n)
  }

  return(increment)
}

#' Prints the current data frame passed, into a file and passes it to the next
#' function.
#'
#' This function is primarily used for debugging purposes.
#'
#' @param csvData The input data frame that will be written to file.
#' @param fileName (optional, "outputDataFrame") The filename that the frame
#'   will be written to.
#' @return The input data frame.
#' @examples
#' (...(tee(function(input))))
tee <- function( csvData, fileName = "outputDataFrame" ) {

  write.csv(csvData, file = fileName)

  return(csvData)
}

#' Converts a list of lists (matrix) into a data frame.
#'
#' May not always work correctly, given how R data structures work.
#'
#' @param mat The input matrix that will be converted.
#' @return The converted matrix.
to.data.frame <- function ( mat ) {

  return(do.call(rbind.data.frame, mat))
}
