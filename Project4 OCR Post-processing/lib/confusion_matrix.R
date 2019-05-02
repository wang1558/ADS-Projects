# letterlist_add_on <- function(letterlist, filelist) {
#   punctuation = list()
#   for (file in filelist) {
#     lines = readLines(file, warn=FALSE, encoding = "UTF-8")
#     add = unique(unlist(strsplit(lines, "")))
#     punctuation = unique(c(punctuation, add))
#   }
#   
#   punctuation = punctuation[!(punctuation%in%letterlist)]
#   punctuation_int = charToInt(punctuation)
#   # remove NAs
#   if (NA%in%punctuation_int) {
#     ind = which(is.na(punctuation_int))
#     punctuation = punctuation[-ind]
#     punctuation_int = punctuation_int[-ind]
#   }
#   # remove characters with ascii code <= 32 '\n'
#   ind = which(punctuation_int<=32)
#   punctuation = punctuation[-ind]
# 
#   return (unlist(punctuation))
# }


confusion_count_num <- function(truth_list, ocr_list, letterlist) {
  # lowerletters = c("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
  # upperletters = toupper(lowerletters)
  # numbers = c("0","1","2","3","4","5","6","7","8","9")
  # letters = c(lowerletters, upperletters, numbers)
  # 
  # punctuation = letterlist_add_on(letters, truth_list)
  # letterlist = c(letters, punctuation)
  # print(letterlist)
  
  d = length(letterlist)
  mat = matrix(0, nrow=d, ncol=d)
  letter_mat = rep(0, d)
    
  # iterate through each file
  for (index in 1:length(truth_list)) {
    # read files
    truth_txt = readLines(truth_list[index], warn=FALSE, encoding="UTF-8")
    ocr_txt = readLines(ocr_list[index], warn=FALSE, encoding="UTF-8")
    
    # count the total number of appearence of each character in file
    file_all_characters = unlist(strsplit(truth_txt, ""))
    #print(file_all_characters)
    for (char in file_all_characters) {
      ind = which(letterlist==char)
      letter_mat[ind] = letter_mat[ind] + 1
    }
    
    # split files by lines
    truth_lines = unlist(strsplit(truth_txt, "\n"))
    ocr_lines = unlist(strsplit(ocr_txt, "\n"))
    # if number of lines in files are different, skip this file
    if (length(truth_lines)!=length(ocr_lines)) {
      #print(index)
      next;
    }
    
    # iterate by each line
    for (i in 1:length(truth_lines)) {
      # split lines by words
      truth_words = unlist(strsplit(truth_lines[i], " "))
      ocr_words = unlist(strsplit(ocr_lines[i], " "))
      # if number of words in lines are different, skip this line
      if (length(truth_words)!=length(ocr_words)) {
        next;
      } 
      
      # iterate by each word
      for (j in 1:length(truth_words)) {
        # if number of characters in words are different, skip this word
        if (nchar(truth_words[j])!=nchar(ocr_words[j])) {
          next;
        }

        # iterate by each character
        for (k in 1:nchar(truth_words[j])) {
          truth_ind = which(letterlist==substr(truth_words[j], k, k))
          ocr_ind = which(letterlist==substr(ocr_words[j], k, k))
          mat[ocr_ind, truth_ind] = mat[ocr_ind, truth_ind] + 1
        }
      }
    }
  }

  #removed_vec = rowSums(mat)==0&colSums(mat)==0
  #print(removed_vec)
  #letterlist = letterlist[!removed_vec]
  #mat = mat[!removed_vec,!removed_vec]
  
  
  rownames(mat) <- letterlist
  colnames(mat) <- letterlist
  #print(letter_mat)
  #print(mat)
  
  # sum1 = 0
  # sum2 = 0
  # for (i in 1:d) {
  #   sum2 = sum2 + letter_mat[i]
  #   for (j in 1:d) {
  #     sum1 = sum1 + mat[i, j]
  #   }
  # }
  # print(sum1/sum2)
  
  #mat = mat/colSums(mat)
  #mat[is.na(mat)] = 0
  # smooth zero entry of the matrix
  smooth_mat = mat
  for (i in 1:d) {
    for (j in 1:d) {
      if (mat[i,j] == 0) {
        smooth_mat[i,j] = 0.1
      }
    }
  }
  
  prob_mat = smooth_mat
  for (i in 1:d) {
    for (j in 1:d) {
      prob_mat[i,j] = smooth_mat[i,j]/letter_mat[j]
    }
  }
  
  #new_list <- list("mat" = prob_mat, "letterlist" = letterlist)
  #return(new_list)
  return(prob_mat)
}
