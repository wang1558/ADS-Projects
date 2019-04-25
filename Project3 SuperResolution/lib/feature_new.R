#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Zixiao Wang
### Project 3

# functions for helping getting feature
get_pixel <- function(IMG, row, col){
  if(row >=1 && row <= dim(IMG)[1] && col >= 1 && col <= dim(IMG)[2]){
    return(as.numeric(IMG[row, col]))
  }
  else{
    return(0)
  }
}

## LR
## x1  x4  x6
## x2  ct  x7
## x3  x5  x8

## HR
## y2  y1
## y3  y4

neighbor_and_label <- function(Index, LR_Data, HR_Data, Sample){
  row <- arrayInd(Sample[Index], dim(LR_Data))[1]
  col <- arrayInd(Sample[Index], dim(LR_Data))[2]
  
  x1 <- get_pixel(LR_Data, row-1, col-1)
  x2 <- get_pixel(LR_Data, row, col-1)
  x3 <- get_pixel(LR_Data, row+1, col-1)
  x4 <- get_pixel(LR_Data, row-1, col)
  ct <- get_pixel(LR_Data, row, col)
  x5 <- get_pixel(LR_Data, row+1, col)
  x6 <- get_pixel(LR_Data, row-1, col+1)
  x7 <- get_pixel(LR_Data, row, col+1)
  x8 <- get_pixel(LR_Data, row+1, col+1)
  
  neighbor_value <- c(x1, x2, x3, x4, x5, x6, x7, x8)
  neighbor_value <- neighbor_value - ct
  
  y1 <- get_pixel(HR_Data, 2*row-1, 2*col-1)
  y2 <- get_pixel(HR_Data, 2*row, 2*col-1)
  y3 <- get_pixel(HR_Data, 2*row-1, 2*col)
  y4 <- get_pixel(HR_Data, 2*row, 2*col)
  
  label_pixels <- c(y1, y2, y3, y4)
  label_pixels <- label_pixels - ct
  return(list(neighbor = neighbor_value, labelpix = label_pixels))
}


get_feature <- function(LR, HR, Channel, n){
  LR_channel <- LR[ , , Channel]
  HR_channel <- HR[ , , Channel]
  
  Sample_Points <- sample(c(1:length(LR_channel)), n)
  
  neighbor_value <- matrix(nrow = n, ncol = 8)
  sub_pixels <- matrix(nrow = n, ncol = 4)
  
  for (k in c(1:n)) {
    Result <- neighbor_and_label(k, LR_channel, HR_channel, Sample_Points)
    neighbor_value[k, ] <- Result$neighbor
    sub_pixels[k,] <- Result$labelpix
  }
  
  return(list(neighbor_value = neighbor_value, label = sub_pixels))
}



feature <- function(LR_dir, HR_dir, n_points=1000){

  ### load libraries
  library("EBImage")
  n_files <- length(list.files(LR_dir))
  
  ### store feature and responses
  featMat <- array(NA, c(n_files * n_points, 8, 3))
  colnames(featMat) <- c("v1","v2","v3","v4","v5","v6","v7","v8")
  labMat <- array(NA, c(n_files * n_points, 4, 3))
  colnames(labMat) <- c("v1","v2","v3","v4")
  
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    
    imgLR <- as.array(imgLR)
    imgHR <- as.array(imgHR)
    ### step 1. sample n_points from imgLR
    
    ### step 2. for each sampled point in imgLR,
    
    ### step 2.1. save (the neighbor 8 pixels - central pixel) in featMat
    ###           tips: padding zeros for boundary points
    
    ### step 2.2. save the corresponding 4 sub-pixels of imgHR in labMat
    
    ### step 3. repeat above for three channels
    
    for(c in 1:3){
      featMat[(n_points*(i-1)+1):(n_points*i), , c] <- get_feature(imgLR, imgHR, c, n_points)$neighbor_value
      labMat[(n_points*(i-1)+1):(n_points*i), , c] <- get_feature(imgLR, imgHR, c, n_points)$label
    }
  }
  return(list(feature = featMat, label = labMat))
}
