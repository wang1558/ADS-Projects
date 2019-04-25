cv.function <- function(X.train, y.train, dp, nr, eta,K){
  
  n <- dim(y.train)[1]
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- X.train[s != i, ,]
    train.label <- y.train[s != i, ,]
    test.data <- X.train[s == i, ,]
    test.label <- y.train[s == i, ,]
    
    par <- list(dp = dp, nr = nr)
    dtrain = xgb.DMatrix(data=data.matrix(train.data),label=train.label)
    #fit <- train(train.data, train.label, par)
    fit <- xgb.train(data = dtrain, params = par,eta,
                     gamma, nthread,num_class = num_class)
    pred <- matrix(test(fit, as.matrix(test.data)), ncol=3,byrow=T)
    pred_labels <- max.col(pred) - 1
    cv.error[i] <- mean(pred_labels != test.label) 
    
  }			
  return(c(mean(cv.error)))
}


