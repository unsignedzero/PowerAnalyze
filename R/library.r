# PowerAnalyze Library Module
# Library support functions for PowerAnalyze repo
#
# Created by David Tran
# Version 0.6.2.0
# Last Modified 02-18-2014

# Background Functions

#' As oppose to head and tail, we grab all but the first nth
#' and last nth elements of the data, if it is possible.
#' We return the empty container if it is not possible.
#'
#' @param data input data structure (data.frame, list or vector)
#' @param n (optional) specifies how many elements from the front
#'   and end we will remove. Defaults to 20 if not specified.
#' @return the data strcture with the elements removed or the empty
#'   structure if it is not possible.
#' @examples
#' body(1:50) -> 21:30
#' body(1:6, 2) -> 3:4
#' body(1:10, n=4) -> 5:6
body = function ( data, n = 20 ){

  if (class(data) == "data.frame"){
    len = nrow(data)
    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (data[NULL,])
    }

    return (data[(n+1):(len-n),])

  } else if (class(data) == "list"   || class(data) == "integer" ||
            class(data) == "numeric" || class(data) == "character" ||
            class(data) == "logical" ){
    len = length(data)

    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    output = data[(n+1):(len-n)]
    print(output)
    return(output)

  } else{
    printf("body: Unknown data type %s", class(data))
    return (NA)
  }
}

#' Preforms the dot product of two lists. Unlike R unequal list lengths
#' that share a common factor will NOT multiply.
#'
#' @param listA the first numeric list we will preform the dot product
#' @param listB the second numeric list we will preform the dot product
#' @return a numeric containing the dot product
dotProduct = function ( listA, listB ){

  if (length(listA) != length(listB)){
    printf("Lists %s and %s are not identical in length",
      str(listA), str(listB))
    stop("Halting...")
  }

  return (sum(listA*listB))
}

#' Stops the program and prints what was passed in
#'
#' @param ... prints out anything passes
#' @return any input passed (should not happen)

halt = function ( ... ){

  print(...)
  stop("Halting execution...")

  # This should NOT happen
  return (...)
}

#' Installs the package, if it exists, and bypasses the interactive
#' prompt.
#'
#' The default location, if not specified, is at .libPaths()[1] which is
#; usually /usr/lib/R/site-library
#'
#' @param pack the package that will be installed
#' @param ... any other arguments passed for install.packages
#' @return NULL this is a statement. Use other functions to check if
#'  install works
#' @examples
#' install('e1071')
#' @seealso \code{\link{lib}}
install = function (pack, ...) {

  install.packages(pack,
    dependencies=TRUE, repos='http://cran.us.r-project.org',
    ...
  )
}
inst = install # Function alias

#' Checks if a package is installed
#'
#' @param pack the package we will check
#' @param ... any other arguments for library
#' @return a boolean value if it is installed correctly
#' @seealso \code{\link{lib}}
libCheck = function (pack, ...){

  # Load a lib from .libPaths()[1]

  return (suppressWarnings(
    library(pack,
      logical.return = TRUE, character.only = TRUE,
    ...)
    )
  )
}

#' Checks if a package is installed and loads it. If not, it will install and then
#' try to load it
#'
#' @param pack the package that will be checked
#' @param ... other arguments passed into libCheck
#' @return a boolean stating if it is loaded
lib = function (pack, ...){

  if (libCheck(pack, ...)){
    # Loaded successfully
    return (TRUE)
  }
  else{
    # Try to install and load
    install(pack)
    return (libCheck(pack, ...))
  }
}

#' Computes the magnitude of a complex number of list
#'
#' @param x input numeric vector(list)
#' @return the computed magnitude
#' @examples
#' mag(3,4) -> 5
#' mag(5+12i) -> 13
#' mag(c(6,8)) -> 10
mag = function(x) {

  # Computes the magnitude

  if (class(x) == "numeric"){
    return (x)
  }
  else if (class(x) == "complex"){
    return (sqrt(Re(x)^2 + Im(x)^2))
  }
  else if ((class(x) == "list") || (class(x) == "numeric") ||
           (class(x) == "integer")){
    return (sqrt(sum(sapply(x, function(x) x^2))))
  }
  else{
    stop("Unknown datatype passed")
  }
}

#' Checks if a variable (object) exists
#'
#' @param obj the object it will check
#' @return a boolean if it does exist
#' @examples
#' object.exists(mtcars) -> TRUE
#' object.exists(1) -> FALSE
#' object.exists(NA) -> FALSE
object.exists = function(obj) {

  # Check if an object(variable) exists

  return (exists(as.character(substitute(obj))))

}

#' Removes a column from a given frame if it exists
#' This is analogous to frame[-n] where n is the column number
#' Reference https://stackoverflow.com/questions/11940605/printing-a-subset-of-columns-in-a-data-table-r
#'
#' @param frame the input data.frame
#' @param colName a string that it will search for
#' @return the data.frame with the specified column removed
#' @examples
#' removeColumn(mtcars, 'mpg')
#' removeColumn(rock, 'perm')
removeColumn = function( frame , colName ){


  logicVector = unlist(lapply(colnames(frame),
    function(x) (!grepl(colName, x))))

  return (frame[logicVector])
}

#' Sorts a data.frame by the column specified or the first column if not.
#'
#' @param frame the input data frame we will sort on
#' @param col the column we will sort by or the first column is not passed
#' @return the sorted data frame
#' @examples
#' sort.data.frame(mtcars, 'wt')
#' sort.data.frame(rock, 'shape')
sort.data.frame = function ( frame, col = NULL ){

  if (class(frame) == "data.frame"){
    if (is.null(col)){
      return (frame[order(frame[1]),])
    }
    else if (col %in% colnames(frame)){
      return (frame[order(frame[col]),])
    }
    else{
      stop("sort: Col %s passed does not exist in data frame %s",
        str(col), str(frame)
      )
      return (-1)
    }
  }
  else if(class(frame) == "list"){
    return (frame[order(unlist(frame))])
  }
  else if(class(frame) == "numeric" || class(frame) == "character" ||
          class(frame) == "integer" )
        {
    #return (frame[order(frame)])
    return (sort(frame))
  }
  else{
    stop("sort: Unknown data type %s passed.", class(frame))
    return (-1)
  }
}

#' Squares the given input, be it a numeric or vector
#'
#' @param x the numberic input that will be squared
#' @return the input with all elements squared
#' @seealso \code{\link{mag}}
#' @examples
#' square(4) -> 16
#' square(list(3,4)) -> list(16,25)
square = function (x) {

  # Squares all elements passed

  if (class(x) == "numeric"){
    return (x^2)
  }
  else{
    return (lapply(x, function(x) x^2))
  }
}


#' A increment counter used to keep track of how many times something worked
#' DEBUG needs to be enabled for this to print.
#'
#' @param n the initial start value of the counter, should be an integer
#' @param startMsg a string that will be shown before the number is printed
#' @param endMsg a string that will be shown after the number is printed
#' @return a function that needs to be invoked to increment the number that
#'   will return the incremented number
#' @examples
#' a = successCount(1)
#' b = successCount(0)
#' a() -> 2
#' b() -> 0
#' b() -> 1
#' b() -> 2
successCount = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  # This is a factory function that creates an incrementing
  # counter from n onward. Note this returns a function so
  # invoke the return type as a function

  increment = function () {
    n <<- n + 1
    debugprintf("%s%d%s", startMsg, n, endMsg)
    return (n)
  }

  return (increment)
}

#' Prints the current data.frame passed into a file and passes it to the next
#' function. Useful for debugging
#'
#' @param csvData the data.frame that will be written to the file and passed
#' @param fileName the filename that the csvData will be written to
#' @return csvData
#' @examples
#' (...tee(function(... input)))
tee = function(csvData, fileName='outputDataFrame'){

  # Writes the current data in the stream to file and passes it
  # to the next invoked function

  write.csv(csvData, file=fileName)

  return (csvData)
}

#' Converts a list of lists (matrix) into a data.frame
#'
#' @param mat the input matrix that will be coverted
#' @return the data.frame
to.data.frame = function ( mat ){

  # Converts a list of lists to a data.frame

  return (do.call(rbind.data.frame, mat))
}
