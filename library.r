# PowerAnalyze Library Module
# Library support functions for PowerAnalyze repo
#
# Created by David Tran
# Version 0.4.3.0
# Last Modified 02-04-2014

# Background Functions
body = function ( data, n = 20 ){

  # As oppose to head and tail, we grab all but the first nth
  # and last nth elements of the data, if it is possible.
  # We return the empty container if it is not possible.

  isVectorFlag = FALSE

  # We want to iterate over lists, not elements in a vector
  if (class(data) == "integer" | class(data) == "numeric" |
      class(data) == "character" ){
    data = list(data)
    isVectorFlag = TRUE
  }

  if (class(data) == "data.frame"){
    len = nrow(data)
    if ( n > len - n ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (data[NULL,])
    }

    return (data[n:(len-n),])

  } else if (class(data) == "list"){
    len = length(data)
    if ( n > len - n ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (if (isVectorFlag) NULL else list())
    }

    output = apply(data, (function(x) x[n:(len-n)]))

    return (if (isVectorFlag) unlist(output) else output)

  } else{
    printf("body: Unknown data type %s", class(data))
    return (NA)
  }
}

halt = function ( ... ){

  # Stops the program and prints what it currently has

  print(...)
  stop("Halting execution...")

  # This should NOT happen
  return (...)
}

removeColumn = function( frame , colName ){

  # Removes one column from the data.frame
  # https://stackoverflow.com/questions/11940605/printing-a-subset-of-columns-in-a-data-table-r
  # didn't help due to with ERROR

  logicVector = unlist(lapply(colnames(frame),
    function(x) (!grepl(colName, x))))

  return (frame[logicVector])
}

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

tee = function(csvData, file='outputData'){

  # Writes the current data in the stream to file and passes it
  # to the next invoked function

  write.csv(csvData, file=file)

  return (csvData)
}

to.data.frame = function ( mat ){

  # Converts a list of lists to a data.frame

  return (do.call(rbind.data.frame, mat))
}
