get_letterlist <- function(ocr.true.error.nonempty, candidates.list.nonempty) {
  lowerletters = c("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
  upperletters = toupper(lowerletters)
  numbers = c("0","1","2","3","4","5","6","7","8","9")
  letters = c(lowerletters, upperletters, numbers)
  
  other_letters = list()
  for (i in 1:length(candidates.list.nonempty)) {
    add = unique(unlist(strsplit(ocr.true.error.nonempty[[i]], "")))
    other_letters = unique(c(other_letters, add))
    for (j in 1:length(candidates.list.nonempty[[i]])) {
      #print(strsplit(candidates.list.nonempty[[i]][j], ""))
      add = unique(unlist(strsplit(candidates.list.nonempty[[i]][j], "")))
      other_letters = unique(c(other_letters, add))
    }
  }
  
  letters = unique(c(letters, other_letters))
  return(unlist(letters))
}