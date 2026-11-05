import numpy as np
import scipy.io as sio
import pandas as pd
import os
import glob

# Set your working directory
os.chdir("/Users/lebovija/Desktop/body mapping")

# Get subject IDs in the same order MATLAB processed them
preprocessed_files = sorted(glob.glob("preprocessed/*_preprocessed.mat"))
subject_ids = [os.path.basename(f).replace('_preprocessed.mat', '') for f in preprocessed_files]

print(f"Found {len(subject_ids)} subject files")
print(f"First 5 subjects: {subject_ids[:5]}")

print("\nLoading cold data (SZ_N.mat)...")
T1 = sio.loadmat("SZ_N.mat")
mat_key = [k for k in T1.keys() if not k.startswith('__')][0]
print(f"Variable name in cold file: {mat_key}")
A = T1[mat_key]

# Free memory
del T1

print("Loading hot data (SZ_P.mat)...")
K1 = sio.loadmat("SZ_P.mat")
mat_key = [k for k in K1.keys() if not k.startswith('__')][0]
print(f"Variable name in hot file: {mat_key}")
B = K1[mat_key]

# Free memory
del K1

print("Computing mixed pixels...")
# Calculate mixed pixels (where both > 0)
H = ((A > 0) & (B > 0)).astype(int)

# Free memory
del A, B

print("Calculating sums per participant...")
# Sum across pixels (axis 0) to get (participants x conditions)
W = H.sum(axis=0)

print(f"Output shape: {W.shape}")

# Check if number of subjects matches
if W.shape[0] != len(subject_ids):
    print(f"\nWARNING: Mismatch in participant count!")
    print(f"Matrix has {W.shape[0]} participants, but found {len(subject_ids)} preprocessed files")

# Column names - DPD conditions (17 conditions)
column_names = ['mixedpixel_neutral', 'mixedpixel_fear', 'mixedpixel_anger', 
                'mixedpixel_disgust', 'mixedpixel_sadness', 'mixedpixel_happiness', 
                'mixedpixel_loneliness', 'mixedpixel_anxiety', 'mixedpixel_love', 
                'mixedpixel_depression', 'mixedpixel_pride', 'mixedpixel_shame', 
                'mixedpixel_jealousy', 'mixedpixel_stress', 'mixedpixel_migraine', 
                'mixedpixel_nausea', 'mixedpixel_self']

# Create dataframe
df = pd.DataFrame(W, columns=column_names)

# Add SubjectID as first column
df.insert(0, 'SubjectID', subject_ids[:W.shape[0]])

print("Saving results...")
df.to_csv("DPD_mixedpixels.csv", index=False)

print("Done! File saved as DPD_mixedpixels.csv")
print(f"Output dimensions: {df.shape}")
print("\nFirst few rows:")
print(df.head())