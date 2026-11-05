import numpy as np
import scipy.io as sio
import os

os.chdir("/Users/lebovija/Desktop/body mapping")

# Load data
T1 = sio.loadmat("SZ_N.mat")
mat_key = [k for k in T1.keys() if not k.startswith('__')][0]
A = T1[mat_key]  # Shape: (50364, 221, 22)

K1 = sio.loadmat("SZ_P.mat")
mat_key = [k for k in K1.keys() if not k.startswith('__')][0]
B = K1[mat_key]  # Shape: (50364, 221, 22)

print("Data shape:", A.shape)
print("Total pixels per participant per emotion:", A.shape[0])

# Look at participant 0, neutral emotion (condition 0)
print("\n--- Participant 0, Neutral ---")
print(f"Cold pixels > 0: {(A[:, 0, 0] > 0).sum()}")
print(f"Hot pixels > 0: {(B[:, 0, 0] > 0).sum()}")
print(f"Mixed pixels: {((A[:, 0, 0] > 0) & (B[:, 0, 0] > 0)).sum()}")

print("\nFirst 30 cold values for participant 0, neutral:")
print(A[:30, 0, 0])
print("\nFirst 30 hot values for participant 0, neutral:")
print(B[:30, 0, 0])