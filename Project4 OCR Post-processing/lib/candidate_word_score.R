

get.probability.word = function(word, beta.matrix){
  candidate.matrix = filter(beta.matrix, beta.matrix$term == word)
  candidate.matrix = arrange(candidate.matrix, topic)
  probability.word.in.topic = candidate.matrix$beta
  return(probability.word.in.topic) #P(w|t_k)vector of 13 conditional probabilities
}

get.confusion.score = function(ocr_word, candidate_word, confusion.prob) {
  prob = 1
  for (i in 1:nchar(ocr_word)) {
    ocr_char = substr(ocr_word, i, i)
    candidate_char = substr(candidate_word, i, i)
    prob = prob * confusion.prob[ocr_char, candidate_char]
  }
  return(prob)
}

candidate.word.score = function(ocr_word, candidate_list_nonempty, probability.topic, confusion.prob, beta.matrix){
  score = list()
  for (i in 1:length(candidate_list_nonempty)) {
    candidate_word = candidate_list_nonempty[i]
    prob.confusion.matrix = get.confusion.score(ocr_word, candidate_word, confusion.prob)
    prb.word.in.topic = get.probability.word(candidate_word, beta.matrix)
    score = c(score, sum(prb.word.in.topic*probability.topic)*(prob.confusion.matrix))
  }

  return(unlist(score))
  #return(score)
}
