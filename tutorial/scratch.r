
p.filter <- function ( inputVector, f ) {
  return(inputVector[f(x)])
}

p.not.filter <- function ( inputVector, f ) {
  return(inputVector[!f(x)])
}

p.curry.2.1 <- function ( f, a ) {
  return(function ( b ) {
    return(f(a, b))
  })
}

p_removeNA <- function ( inputVector ) {
  return(inputVector[!is.na(x)])
}

p_isFile <- function ( inputVector ) {
  return(inputVector[file.exists(x)])
}
