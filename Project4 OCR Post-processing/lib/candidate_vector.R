#Paper reference: for each incorrect word w_i in the document, we generate a list of all strings 
#that differ from w_i by zero, one or two characters.

#option is to add numbers to the grid

get.candidate.vector = function(error.word, dictionary){ #dictionary_letters = letters
  # original version: expand.grid(letters.1 = dictionary_letters, letters.2 = dictionary_letters) 
  candidate.vector = c()
  letters.comb.grid = expand.grid(letters.1 = letters, letters.2 = letters)  
  error.word.vector = rep(error.word, nrow(letters.comb.grid))
  for (i in 1:nchar(error.word)){
    for (j in (i+1):(nchar(error.word)+1)){
      combinatorial.input = error.word.vector
      substr(combinatorial.input, i, i) = as.character(letters.comb.grid$letters.1)
      substr(combinatorial.input, j, j) = as.character(letters.comb.grid$letters.2)
      candidate.vector = c(candidate.vector, combinatorial.input)
    }
  }
  
  candidate.vector = unique(candidate.vector)
  boolean.in.dict = which(candidate.vector %in% dictionary)
  candidate.vector = candidate.vector[boolean.in.dict]
  
  return(candidate.vector)
}

