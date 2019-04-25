########################
### Super-resolution ###
########################

### Author: Zixiao Wang
### Project 3

superResolution <- function(LR_dir, HR_dir, modelList){
  
  ### Construct high-resolution images from low-resolution images with trained predictor
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + a list for predictors
  
  ### load libraries
  library("EBImage")
  n_files <- length(list.files(LR_dir))
  #n_files <- 20
  PSNR <- NULL
  MSE <- NULL
  
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))
    #imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    pathHR <- paste0(HR_dir,  "img", "_", sprintf("%04d", i), ".jpg")
    featMat <- array(NA, c(dim(imgLR)[1] * dim(imgLR)[2], 8, 3))
    
    ### step 1. for each pixel and each channel in imgLR:
    ###           save (the neighbor 8 pixels - central pixel) in featMat
    ###           tips: padding zeros for boundary points
    
    row <- (1 : (dim(imgLR)[1] * dim(imgLR)[2]) - 1) %% dim(imgLR)[1] + 1
    col <- (1 : (dim(imgLR)[1] * dim(imgLR)[2]) - 1) %/% dim(imgLR)[1] + 1
    
    for (j in c(1:3)) {
      new_imgLR <- cbind(0, imgLR[ , , j], 0)
      new_imgLR <- rbind(0, new_imgLR, 0)
      
      center <- new_imgLR[cbind(row+1, col+1)]
      
      ### fill the featM 
      featMat[,  1, j] <- new_imgLR[cbind(row,col)] - center
      featMat[,  2, j] <- new_imgLR[cbind(row,col + 1)] - center
      featMat[,  3, j] <- new_imgLR[cbind(row,col + 2)] - center
      featMat[,  4, j] <- new_imgLR[cbind(row + 1,col)] - center
      featMat[,  5, j] <- new_imgLR[cbind(row + 1,col + 2)] - center
      featMat[,  6, j] <- new_imgLR[cbind(row + 2,col)] - center
      featMat[,  7, j] <- new_imgLR[cbind(row + 2,col + 1)] - center
      featMat[,  8, j] <- new_imgLR[cbind(row + 2,col + 2)] - center
    }
    
    ### step 2. apply the modelList over featMat
    predMat <- test(modelList, featMat)
    predMat <- array(predMat, dim = c(dim(imgLR)[1]*dim(imgLR)[2], 4, 3))
    ### step 3. recover high-resolution from predMat and save in HR_dir
    for (k in c(1:3)) {
      predMat[, , k] <- predMat[, , k] + imgLR[, ,k][cbind(row, col)]
    }
    
    imgHR_pred <- array(NA,c(dim(imgLR)[1]*2,dim(imgLR)[2]*2,3))
    base_row <- seq(1, 2 * dim(imgLR)[1], 2)
    base_col <- seq(1, 2 * dim(imgLR)[2], 2)
    imgHR_pred[base_row, base_col, ] <- predMat[, 1, ]
    imgHR_pred[base_row, base_col + 1, ] <- predMat[, 2, ]
    imgHR_pred[base_row + 1, base_col, ] <- predMat[, 3, ]
    imgHR_pred[base_row + 1, base_col + 1, ] <- predMat[, 4, ]
    
    # calculate MSE and PSNR
    # mse <- sum((imgHR - imgHR_pred)^2)/(3*dim(imgLR)[1]*dim(imgLR)[2])
    # psnr <- 20*log10(range(imgHR)[2]) - 10*log10(mse)
    # PSNR <- append(PSNR, psnr)
    imgHR <- Image(imgHR_pred, colormode="Color")
    writeImage(imgHR, pathHR)
  }
  # PSNR <- sum(PSNR)/n_files
  # return(PSNR)
}
