################################################################
# Purpose: Obtain Mixed Scores for a Single Group's Body Mapping
# Author: Matthew Snodgress
# Date: 10/8/2018
################################################################


setwd("/Users/lebovija/Desktop/body mapping")

# Make sure matrices are in current working directory, and change
# file names below. Works with any number of subjects. Also
# change output name at the end 

# Install and/or load R package 'R.matlab'
if(!require(R.matlab)){
  install.packages("R.matlab")
  library(R.matlab)
}

NC= 17 #set NC depending on the version of BM you used

# Import data cold
T1 <- readMat("highdp_N.mat") #change name
T2 <- unlist(T1)
T3 <- matrix(T2, nrow = 50364*33, ncol = 17)
A = T3[,c(1:17)]

# Import data hot
K1 <- readMat("highdp_P.mat") #change name
K2 <- unlist(K1)
K3 <- matrix(K2, nrow = 50364*33, ncol = 17)
B = K3[,c(1:17)]

# If the matrices are in, run the code below:

############

# For a pixel, for a subject, for an emotion condition, if
# its value is greater than 0 for both matrices, recode it
# with 1, otherwise with 0
H <- matrix(rep(0, nrow(A)*ncol(A)), nrow(A), ncol(A))
for(i in 1:nrow(A)){
  for(j in 1:ncol(A)){
    if(A[i,j] > 0 & B[i,j] > 0){
      H[i,j] <- 1
    } else{
      H[i,j] <- 0
    }
  }
}
colset <- ncol(H)
rowset <- 50364
num <- nrow(H)/rowset
c <- 0

# Sweep through the new matrix H of 1s and 0s by subject; take
# the sum of all 50,364 pixels within each emotion condition
# for each subject, creating a final matrix
W <- matrix(rep(0, num*colset), num, colset)
for(k in 1:num){
    d <- k * rowset
    X <- H[(c + 1):d, ]
    c <- d
    val <- apply(X, 2, sum)
    W[k,] <- val
}
############

# This function writes the W matrix as a .csv file into your
# current working directory. You can change your working 
# directory in RStudio under "Session-->Set Working Directory
# --> Choose Directory":

write.csv(W, file="highDP_matrix.csv") # change name

# Also, if you were interested in applying this to regions of 
# interest, I'd recommend changing 'sum' in line 61 to 'mean'
# in the event you do cross-regions comparisons (as some regions
# have less or more pixels than others, distorting comparisons)






