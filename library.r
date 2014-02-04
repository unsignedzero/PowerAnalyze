# Library support functions for PowerAnalyze repo
#
# Created by David Tran
# Version 0.4.0.0
# Last Modified 02-01-2014

# Background Functions
body = function ( data, n = 20 ){

  # As oppose to head and tail, we grab all but the first nth
  # and last nth elements of the data, if it is possible.
  # We quit otherwise.

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
      printf("Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    return (data[n:(len-n),])

  } else if (class(data) == "list"){
    len = length(data)
    if ( n > len - n ){
      printf("Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    output = apply(data, (function(x) x[n:(len-n)]))

    return (if (isVectorFlag) unlist(output) else output)

  } else{
    printf("Unknown data type %s", class(data))
    return (NA)
  }
}

successCount = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  # This is a factory function that creates an incrementing
  # counter from n onward. Note this returns a function so
  # invoke the data type with ()

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
