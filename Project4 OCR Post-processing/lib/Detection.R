##############################
## Garbage detection
## Ref: first three rules in the paper
##      'On Retrieving Legal Files: Shortening Documents and Weeding Out Garbage'
## Input: one word -- token
## Output: bool -- if the token is clean or not
##############################

Detection <- function(cur_token){
  now <- 1
  if_clean <- TRUE
  
  ## in order to accelerate the computation, conduct ealy stopping
  rule_list <- c(# Rule 1: More than 20 characters in length
                 "nchar(cur_token) > 20",
                 
                 # Rule 2: The number of punctuation characters in a string is greater than the number of alphanumeric characters
                 "str_count(cur_token, pattern = '[A-Za-z0-9]') <= 0.5*nchar(cur_token)",
                 # Use complement of punctuation characters, which includes Alphabetic characters and digits (i.e. [A-Za-z0-9])
                 
                 # Rule 3: There are two or more different punctuation characters in the string (ignoring the first and last characters)
                 "length(unique(strsplit(gsub('[A-Za-z0-9]','',substr(cur_token, 2, nchar(cur_token)-1)),'')[[1]]))>1",
                 
                 # Rule 4: There are three or more identical characters in a row in a string
                 "grepl(pattern = '(.)\\1{2,}', cur_token)",
                 # "." stands for any character, "\\1" refers to the first identical characters,
                 # and "{2,}" means that there are at least two more the same ones after that (the first identical characters).
                 # In other words, there are at least three or more in total.
                 # For example,
                 # > grepl(pattern = '(.)\\1{2,}', "coool")
                 # [1] TRUE
                 # > grepl(pattern = '(.)\\1{2,}', "cool")
                 # [1] FALSE
                 # > grepl(pattern = '(.)\\1{2,}', "great!!!")
                 # [1] TRUE
                 # > grepl(pattern = '(.)\\1{2,}', "great!!")
                 # [1] FALSE
                 
                 # Rule 5: The number of uppercase characters in a string is greater than the number of lowercase characters,
                 #         and the number of uppercase characters is less than the total number of characters in the string
                 "((str_count(cur_token, pattern = '[A-Z]') > str_count(cur_token, pattern = '[a-z]'))
                 & (str_count(cur_token, pattern = '[A-Z]') < str_count(cur_token, pattern = '[:graph:]')))",
                 # "[:graph:]" denotes any character defined as a printable character except those defined as part of the 
                 # space character class, which helps to give the same meaning of the total number of characters in the string
                 
                 # Rule 6: All the characters in a string are alphabetic,
                 #         and the number of consonants in the string is greater than 8 times the number of vowels in the string,
                 #         or vice-versa
                 "((grepl(pattern = '^[:alpha:]+$', cur_token))
                 & ((str_count(cur_token, pattern = '[B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z]') > 8*str_count(cur_token, pattern = '[aeiouAEIOU]'))
                 | (str_count(cur_token, pattern = '[aeiouAEIOU]') > 8*str_count(cur_token,pattern = '[B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z]'))))",
                 # "^" matches the starting position, "$" matches the ending position.
                 # "[:alpha:]" means Alphabetic characters, and "+" stands for repeating one or more times
                 
                 # Rule 7: There are four or more consecutive vowels in the string
                 #         or five or more consecutive consonants in the string
                 "((grepl(pattern = '[aeiouAEIOU]{4,}', cur_token))
                 | (grepl(pattern = '[B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z]{5,}', cur_token)))",
                 # "[aeiouAEIOU]{4,}" refers to four or more consecutive vowels in the string
                 # For example,
                 # > grepl(pattern = '[aeiouAEIOU]{4,}', "cooool")
                 # [1] TRUE
                 # > grepl(pattern = '[aeiouAEIOU]{4,}', "coool")
                 # [1] FALSE
                 # Similarly,
                 # > grepl(pattern = '[B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z]{5,}', "coolllll")
                 # [1] TRUE
                 # > grepl(pattern = '[B-DF-HJ-NP-TV-Zb-df-hj-np-tv-z]{5,}', "coollll")
                 # [1] FALSE
                 
                 # Rule 8: The first and last characters in a string are both lowercase
                 #         and any other character is uppercase
                 "((grepl('^[a-z].*[a-z]$', cur_token))
                 & (grepl('[A-Z]', substr(cur_token, 2, nchar(cur_token)-1))))")
                 # "*" stands for repeating zero or more times
  
  while((if_clean == TRUE)&now<=length(rule_list)){
    if(eval(parse(text = rule_list[now]))){
      if_clean <- FALSE
    }
    now <- now + 1
  }
  return(if_clean)
}