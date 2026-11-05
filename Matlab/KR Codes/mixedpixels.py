import numpy as np
import scipy.io as sio
import pandas as pd
import os

# Set your working directory
os.chdir("/Users/lebovija/Desktop/body mapping")

print("Loading cold data (SZ_N.mat)...")
T1 = sio.loadmat("SZ_N.mat")
mat_key = [k for k in T1.keys() if not k.startswith('__')][0]
print(f"Variable name in cold file: {mat_key}")
A = T1[mat_key]  # Shape: (50364, 221, 22)

# Free memory
del T1

print("Loading hot data (SZ_P.mat)...")
K1 = sio.loadmat("SZ_P.mat")
mat_key = [k for k in K1.keys() if not k.startswith('__')][0]
print(f"Variable name in hot file: {mat_key}")
B = K1[mat_key]  # Shape: (50364, 221, 22)

# Free memory
del K1

print("Computing mixed pixels...")
# Calculate mixed pixels (where both > 0)
H = ((A > 0) & (B > 0)).astype(int)

# Free memory
del A, B

print("Calculating sums per participant...")
# Sum across pixels (axis 0) to get (221, 22) - participants x conditions
W = H.sum(axis=0)

print(f"Output shape: {W.shape}")  # Should be (221, 22)

# Column names
column_names = ['mixedpixel_neutral', 'mixedpixel_fear', 'mixedpixel_anger', 
                'mixedpixel_disgust', 'mixedpixel_sadness', 'mixedpixel_happiness', 
                'mixedpixel_anxiety', 'mixedpixel_love', 'mixedpixel_depression', 
                'mixedpixel_pride', 'mixedpixel_shame', 'mixedpixel_stress', 
                'mixedpixel_loneliness', 'mixedpixel_rejection', 'mixedpixel_acceptance', 
                'mixedpixel_motivation', 'mixedpixel_regret', 'mixedpixel_trauma', 
                'mixedpixel_isolation', 'mixedpixel_disconnection', 'mixedpixel_grief', 
                'mixedpixel_hope']

# Create dataframe
df = pd.DataFrame(W, columns=column_names)

print("Saving results...")
df.to_csv("SD_mixedpixels.csv", index=False)

print("Done! File saved as SD_mixedpixels.csv")
print(f"Output dimensions: {df.shape}")
print("\nFirst few rows:")
print(df.head())

