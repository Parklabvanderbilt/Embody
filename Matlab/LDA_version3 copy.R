################################################################
################################################################
# Linear Discriminant Analysis of 2D Body Mapping: Replication
# of Method from Hietanen et al., 2016 

# Author: Matthew Snodgress
# Date: 3/16/2018
# Version: 3.0

# Preprocessing: In matlab, run embody.m to get
# 'preprocessed' files, then  run embody_stats.m and then write
# in the console: "save file.mat data". 
#In RStudio, go to "Session --> Set Working Directory" and set it to the folder
# where "file.mat" was just saved. In RStudio, make sure the
# above packages are installed and activated. Then run the first
# three lines below. BUT instead of X insert the product of 50364
# and your sample size. There should now be a
# huge matrix A ready for processing. Define the function below
# (ldablast), then run it in the console with the
# correct arguments.

# Function Arguments: M is the unfolded mega-matrix of everyone's
# individual body mapping matrices stacked on top of one another
# that you just created iter is the number of iterations. Prior
# studies did 100. For replication, I recommend this value.

# Notes: It should run for awhile. Afterwards, it should give
# the average accuracies as well as the average standard deviations
# (error). If you need to access either again, just type in the
# console either avgall or sdall.

# Reference(s):
# Hietanen, J. K., Glerean, E., Hari, R., & Nummenmaa, L. (2016).
# Bodily maps of emotions across child development. Developmental science.

################################################################
################################################################

setwd("/Volumes/sheffield_lab/ResearchProjects/BAIS/Data/EMBODY/Body Mapping/")

# Import data
T <- readMat("HC.mat")
T2 <- unlist(T)
M <- matrix(T2, nrow = 2266380, ncol = 16) # nrow= 50364xN, ncol= #of emotions used, change as needed

# Define function
ldablast <- function(M, iter) {
  if (!require(MASS)) {
    install.packages("MASS")
    library(MASS)
  }
  if (!require(R.matlab)) {
    install.packages("R.matlab")
    library(R.matlab)
  }
  if (!require(caret)) {
    install.packages("caret")
    library(caret)
  }
  if (!require(plyr)) {
    install.packages("(plyr")
    library(plyr)
  }
  
  nc = ncol(M)
  nr = nrow(M)
  a <- rep(0, nc * nr)
  E <- matrix(a, nr, nc)
  for (k in 1:nc) {
    E[, k] <- rep(k, nr)
  }
  g <- as.vector(E)
  
  inner <- function(M, g) {
    nfold = 126
    m <- as.vector(M)
    X <- cbind(g, m)
    X <- as.data.frame(X)
    folds <- createFolds(factor(X$g), k = nfold, list = FALSE)
    X$fold <- folds
    FOLDED <- X[order(folds) , ]
    ni <- nrow(X) / nfold
    contain <- list()
    for (j in 1:nfold) {
      sub <- FOLDED[(((ni * j) - (ni - 1)):(ni * j)),]
      
      fit <- lda(g ~ m, data = sub, CV = TRUE)
      
      ct <- table(sub$g, fit$class)
      contain[[j]] <-
        c(sum(diag(prop.table(ct))), diag(prop.table(ct, 1)))
    }
    acc <- unlist(contain)
    acc2 <- matrix(acc, nrow = 15, ncol = 126) # changed nrow from 15 to 16? 2/24/25
    avgacc <- apply(acc2, 1, mean)
    return(avgacc)
  }
  
  emotions <- c('Neutral', 'Fear', 'Anger', 'Disgust', 'Sadness', 'Happiness', 
                'Surprise', 'Anxiety', 'Love', 'Depression', 'Contempt', 
                'Pride', 'Shame', 'Jealousy', 'Migraine', 'Nausea') 

  mc3 <- replicate(iter, inner(M, g))
  avgall <- round(apply(mc3, 1, mean), 6)
  sdall <- round(apply(mc3, 1, sd), 6)
  avgal <- as.matrix(avgall)
  sdal <- as.matrix(sdall)
  D <- cbind(avgal, sdal)
  rownames(D) <- emotions
  return(D)
}

# Run the function
D <- ldablast(M, 100)

# Output the results as a csv file
setwd("/Volumes/sheffield_lab/ResearchProjects/BAIS/Data/EMBODY/Body Mapping/")
write.csv(D, file = 'LDA3_HC_data.csv')
