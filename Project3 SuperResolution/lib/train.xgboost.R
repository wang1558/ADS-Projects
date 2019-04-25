#########################################################
### Train a classification model with training features ###
#########################################################

### Project 3


train <- function(dat_train, label_train, par=NULL){
  
  ### Train a XGBoost using processed features from training images
  
  ### Input: 
  ###  -  features from LR images 
  ###  -  responses from HR images
  ### Output: a list for trained models
  
  ### load libraries
  library("xgboost")
  
  ### creat model list
  modelList <- list()
  
  ### Train with XGBoost
  if(is.null(par)){
    dp <- 5
    nr <- 10
  } 
  else {
    dp <- par$dp
    nr <- par$nr
  }
  
  ### the dimension of response arrat is * x 4 x 3, which requires 12 classifiers
  ### this part can be parallelized
  for (i in 1:12){
    ## calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_train[, , c2]
    labMat <- label_train[, c1, c2]
    
    #need to convert data into a xgb.Dmatrix type for faster computation
    dt_DM = xgb.DMatrix(featMat, label = labMat)
    fit_xgb <- xgboost(data = dt_DM, verbose=0, booster = "gblinear", seed = 1, lambda = 1, alpha = 0,
                       max_depth=dp, nrounds = nr)
    
    modelList[[i]] <- list(fit=fit_xgb)
  }
  
  return(modelList)
}
