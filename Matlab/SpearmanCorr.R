library(R.matlab)
setwd("/Users/lebovija/Desktop/body mapping")

# A and B are 50364x14 matrices for your groups 
# to obtain them, run embody.m to get proprocessed folders, then run embody_stats.m
# your target object in MATLAB is 'data' (50364xNx14 matrix)
#In MATLAB, type: M=mean(data, 2)
#In MATLAB, type: A=squeeze(M) -> this is matrix A you will use here. Do the same for the other group, and call it B
#save A and B files - save('A.mat', 'A');
#save('B.mat', 'B');

library(R.matlab)

# Load .mat files
A <- readMat("A.mat")
B <- readMat("B.mat")

# Extract matrices
A1 <- unlist(A, use.names = TRUE)
B1 <- unlist(B, use.names = TRUE)

# Ensure correct dimensions
A1 <- matrix(A1, nrow = 50364, ncol = 17)
B1 <- matrix(B1, nrow = 50364, ncol = 17)

# Compute Spearman correlations and p-values for each condition
s_values <- numeric(17)
p_values <- numeric(17)

for (i in 1:17) {
  cor_test <- cor.test(A1[, i], B1[, i], use = "complete.obs", method = "spearman", exact = FALSE)
  s_values[i] <- cor_test$estimate  # Spearman's rho
  p_values[i] <- cor_test$p.value   # p-value
}

# Define condition names
conditions <- c('Nothing special (neutral)', 'Fear', 'Anger', 'Disgust', 'Sadness', 
                'Happiness', 'Lonely', 'Anxiety', 'Love', 'Depression', 'Pride', 
                'Shame', 'Jealousy', 'Stress', 'Migraine', 'Nausea', 'Sense of Self')

# Combine into a dataframe
results <- data.frame(Condition = conditions, Spearman_r = s_values, P_value = p_values)

# Save results as CSV
write.csv(results, "Spearman_Results_With_PValues.csv", row.names = FALSE)

# Print results
print(results)







