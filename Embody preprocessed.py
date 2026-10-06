import csv
import math
from pathlib import Path
import numpy as np
from scipy.ndimage import gaussian_filter
import os
import shutil

basepath = Path("/Users/hagrid/Desktop/ML/Test")

'''
output_folder_activation = Path("/Users/hagrid/Desktop/ML/preprocessed/preprocessed activation")
output_folder_activation.mkdir(parents=True, exist_ok=True)

output_folder_deactivation = Path("/Users/hagrid/Desktop/ML/preprocessed/preprocessed deactivation")
output_folder_deactivation.mkdir(parents=True, exist_ok=True)
'''

output_folder = Path("/Users/hagrid/Desktop/ML/preprocessed/preprocessed_interoception_all")
output_folder.mkdir(parents=True, exist_ok=True)

LABELS = [
    "anger_m",
    "fear_l",
    "happy_m",
    "fear_m",
    "sad_l",
    "happy_l",
    "disgust_l",
    "anxiety_l",
    "headache",
    "disgust_m",
    "anxiety_m",
    "sad_m",
    "anger_l",
]

N=len(LABELS)

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

def check_and_delete_incomplete_folders(parent_folder,N):
    """
    Check each subfolder for CSV files named 0.csv through 15.csv
    Delete subfolders that don't contain all required CSV files

    Args:
        parent_folder (str): Path to parent folder containing subfolders
        dry_run (bool): If True, only shows what would be deleted

    Returns:
        list: List of deleted folder paths
    """

    # Required CSV files (0.csv through 15.csv)
    required_files = {f"{i}.csv" for i in range(N)}

    if not os.path.exists(parent_folder):
        print(f"Error: Parent folder '{parent_folder}' does not exist")
        return []

    deleted_folders = []

    # Go through each item in the parent folder
    for item in os.listdir(parent_folder):
        item_path = os.path.join(parent_folder, item)

        # Only check directories
        if os.path.isdir(item_path):
            # Get all CSV files in the subfolder
            csv_files = {f for f in os.listdir(item_path) if f.endswith('.csv')}

            # Check if all required files are present
            missing_files = required_files - csv_files

            if missing_files:
                print(f"Subfolder '{item}' is missing: {sorted(missing_files)}")


                try:
                    shutil.rmtree(item_path)
                    print(f"Deleted: {item_path}")
                    deleted_folders.append(item_path)
                except Exception as e:
                    print(f"Error deleting {item_path}: {e}")

    print(f"\nTotal folders deleted: {len(deleted_folders)}")

    return deleted_folders


def load_subject(folder, N):
    all_paint = []

    for n in range(N):
        with open(Path(folder) / f"{n}.csv", newline="") as file:
            rows = [
                [float(value) if value.strip() else math.nan for value in row]
                for row in csv.reader(file)
            ]

        sections = [[]]

        for row in rows:
            if row and row[0] == -1:
                sections.append([])
            else:
                sections[-1].append(row)

        paint = sections[1] if len(sections) > 1 else []
        all_paint.append(paint)

    return all_paint

def reconstruct_subject(subject_folder, N):
    """
    Reconstruct the painting maps and compute left minus right.

    Returns
    -------
    resmat : numpy.ndarray
        Array with shape (600, 234, N), containing left - right.

    left_maps : numpy.ndarray
        Left painting regions.

    right_maps : numpy.ndarray
        Right painting regions.

    full_maps : numpy.ndarray
        Painting maps over the full 900 x 600 canvas.
    """
    subject_folder = Path(subject_folder)
    data = load_subject(subject_folder, N)

    full_maps = np.zeros(
        (CANVAS_HEIGHT, CANVAS_WIDTH, N),
        dtype=float
    )

    for n in range(N):
        over = np.zeros(
            (CANVAS_HEIGHT, CANVAS_WIDTH),
            dtype=float
        )

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
            mode="constant"
        )

        full_maps[:, :, n] = over

    # Full 600-pixel height and 32 extra pixels around each body
    left_maps = full_maps[:, LEFT_X1:LEFT_X2, :]
    right_maps = full_maps[:, RIGHT_X1:RIGHT_X2, :]

    # Same logic as the original MATLAB code
    resmat = left_maps - right_maps

    return resmat

deleted_list = check_and_delete_incomplete_folders(basepath,N)
for folder in deleted_list:
    print(f"  - {folder}")

subjects = sorted(
    (
        path for path in basepath.iterdir()
        if path.is_dir() and not path.name.startswith(".")
    ),
    key=lambda path: int(path.name.split("_")[-1])
)

for subject_folder in subjects:
    maps= reconstruct_subject(
        subject_folder,
        N
    )
    output_file = output_folder / f"{subject_folder.name.split("_")[-1]}.npz"
    np.savez_compressed(output_file,resmat = maps,labels = np.array(LABELS))

    '''
    output_file_activation = output_folder_activation / f"{subject_folder.name.split("_")[-1]}.npz"
    np.savez_compressed(output_file_activation,resmat = left_maps,labels = np.array(LABELS))
    output_file_deactivation = output_folder_deactivation / f"{subject_folder.name.split("_")[-1]}.npz"
    np.savez_compressed(output_file_deactivation,resmat = right_maps,labels = np.array(LABELS))
    '''


#Add emotions you want to exclude
exclude_labels=[]

include_indices = [i for i, val in enumerate(full_labels) if val not in exclude_labels]

labels = [full_labels[i] for i in include_indices]

basepath = Path("/Users/bb/Documents/Park lab/Embody/Data/In person/All in-person data organized 9.16.26/Control/test")
output_folder = Path("/Users/bb/Documents/Park lab/Embody/Preprocessed/test1")
output_folder.mkdir(parents=True, exist_ok=True)

run(basepath,output_folder,N,include_indices,labels)