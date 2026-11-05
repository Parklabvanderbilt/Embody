import csv
import math
from pathlib import Path
import numpy as np
from scipy.ndimage import gaussian_filter
import os
import shutil
from send2trash import send2trash

CANVAS_WIDTH = 900
CANVAS_HEIGHT = 600

# Original left region: 33:203
# Add 32 pixels on both sides
LEFT_X1 = 0
LEFT_X2 = 235

# Original right region: 696:866
# Add 32 pixels on both sides
RIGHT_X1 = 663
RIGHT_X2 = 898

def check_and_delete_incomplete_folders(parent_folder, N, dry_run=True):
    required_files = {f"{i}.csv" for i in range(N)}

    if not os.path.exists(parent_folder):
        print(f"Error: Parent folder '{parent_folder}' does not exist")
        return []

    # Collect first, delete after, so we never modify the tree while walking it
    to_delete = []
    for root, dirs, files in os.walk(parent_folder):
        if root == parent_folder:
            continue  # never delete the parent itself

        csv_files = {f for f in files if f.endswith(".csv")}
        if not csv_files:
            continue  # container folder or unrelated folder, skip

        missing_files = required_files - csv_files
        if missing_files:
            print(f"'{root}' is missing: {sorted(missing_files)}")
            to_delete.append(root)

    deleted_folders = []
    for folder in to_delete:
        if dry_run:
            print(f"[dry run] Would delete: {folder}")
            continue
        try:
            send2trash(folder)
            print(f"Deleted: {folder}")
            deleted_folders.append(folder)
        except Exception as e:
            print(f"Error deleting {folder}: {e}")

    print(f"\nTotal folders {'flagged' if dry_run else 'deleted'}: "
          f"{len(to_delete) if dry_run else len(deleted_folders)}")
    return to_delete if dry_run else deleted_folders

def load_subject(folder, N):
    all_paint = []

    for n in range(N):
        with open(Path(folder) / f"{n}.csv", newline="") as file:
            rows = [
                [float(value) if value.strip() else math.nan for value in row]
                for row in csv.reader(file)]

        sections = [[]]

        for row in rows:
            if row and row[0] == -1:
                sections.append([])
            else:
                sections[-1].append(row)

        paint = sections[1] if len(sections) > 1 else []
        all_paint.append(paint)

    return all_paint

def reconstruct_subject(subject_folder, N,include):
    """
    Reconstruct the painting maps and compute left minus right.

    Returns
    -------
    resmat : numpy.ndarray
        Array with shape (600, 235, N), containing left - right.
    """
    subject_folder = Path(subject_folder)
    data = load_subject(subject_folder, N)

    full_maps = np.zeros((CANVAS_HEIGHT, CANVAS_WIDTH, len(include)),dtype=float)
    a=0
    for n in range(N):
        if n in include:
            over = np.zeros((CANVAS_HEIGHT, CANVAS_WIDTH),dtype=float)

            for row in data[n]:
                if len(row) < 3:
                    continue

                x = row[1]
                y = row[2]

                if np.isnan(x) or np.isnan(y):
                    continue

                # Coordinates are already zero-based for Python indexing
                x_index = int(np.ceil(x))
                y_index = int(np.ceil(y))

                # Keep coordinates within the complete canvas
                x_index = np.clip(x_index, 0, CANVAS_WIDTH - 1)
                y_index = np.clip(y_index, 0, CANVAS_HEIGHT - 1)

                over[y_index, x_index] += 1

            # Approximate MATLAB's 15 x 15 Gaussian with sigma 5
            over = gaussian_filter(
                over,
                sigma=5,
                truncate=1.4,
                mode="constant")

            full_maps[:, :, a] = over
            a += 1
        else:
            continue
    # Full 600-pixel height and 32 extra pixels around each body
    left_maps = full_maps[:, LEFT_X1:LEFT_X2, :]
    right_maps = full_maps[:, RIGHT_X1:RIGHT_X2, :]

    # Same logic as the original MATLAB code
    resmat = left_maps - right_maps
    return resmat

def run(basepath,output_folder,N,include_indices,labels):

    deleted_list = check_and_delete_incomplete_folders(basepath,N)
    for folder in deleted_list:
        print(f"  - {folder}")

    subjects = sorted(
        (
            path for path in basepath.iterdir()
            if path.is_dir() and not path.name.startswith(".")),
        key=lambda path: int(path.name))

    for subject_folder in subjects:
        maps = reconstruct_subject(
            subject_folder,
            N,
            include_indices)
        output_file = output_folder / f"{subject_folder.name}.npz"
        np.savez_compressed(output_file, resmat=maps, labels=np.array(labels))

'''
============================================================================
Change below
============================================================================
'''

full_labels = LABELS = [
    "anger_m", "fear_l", "happy_m", "fear_m", "sad_l", "happy_l", "disgust_l",
    "anxiety_l", "headache", "disgust_m", "anxiety_m", "sad_m", "anger_l","happiness"
]

N=len(full_labels)

#Add emotions you want to exclude
exclude_labels=[]

include_indices = [i for i, val in enumerate(full_labels) if val not in exclude_labels]

labels = [full_labels[i] for i in include_indices]

basepath = Path("/Users/hagrid/Desktop/ML/Embody/Data/All in-person data/Anne v5")
output_folder = Path("/Users/hagrid/Desktop/ML/Embody/Preprocessed/")
output_folder.mkdir(parents=True, exist_ok=True)

run(basepath,output_folder,N,include_indices,labels)