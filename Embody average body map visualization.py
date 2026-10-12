from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

npz_folder = Path("/Users/hagrid/Desktop/ML/Embody/Test")

base_image_path = Path("/Users/hagrid/Desktop/ML/Embody/base.png")

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
    "anger_l",]

# Same crop used when creating resmat.
LEFT_X1 = 0
LEFT_X2 = 235

def average_subject_maps(npz_folder):
    npz_folder = Path(npz_folder)

    # Find all subject result files
    npz_files = sorted(npz_folder.glob("*.npz"))

    if not npz_files:
        raise FileNotFoundError(
            f"No files matching '*.npz' were found in:\n"
            f"{npz_folder}")

    subject_maps = []
    subject_ids = []
    expected_shape = None

    for file_path in npz_files:
        with np.load(file_path) as saved:
            if "resmat" not in saved:
                print(f"Skipping {file_path.name}: no 'resmat' variable")
                continue

            resmat = saved["resmat"].astype(np.float32)

        # Make sure every subject has the same dimensions
        if expected_shape is None:
            expected_shape = resmat.shape

        if resmat.shape != expected_shape:
            print(
                f"Skipping {file_path.name}: "
                f"shape {resmat.shape}, expected {expected_shape}")
            continue

        subject_maps.append(resmat)

        # Extract the subject ID from a name such as 16907_resmat.npz
        subject_ids.append(file_path.name)

    if not subject_maps:
        raise ValueError(
            f"No valid resmat arrays found in {npz_folder}")

    all_subjects = np.stack(
        subject_maps,
        axis=0)

    # Average over the first dimension, which is subjects
    average_resmat = np.nanmean(
        all_subjects,
        axis=0)

    print(f"Stacked shape: {all_subjects.shape}")

    return average_resmat, all_subjects, subject_ids

def visualize_average_maps(
    average_resmat,
    base_image_path,
    labels,
    number_of_subjects,
    plot_columns=7):
    base_image_path = Path(base_image_path)

    if not base_image_path.exists():
        raise FileNotFoundError(
            f"Base image does not exist:\n{base_image_path}")

    base_image = np.asarray(
        Image.open(base_image_path).convert("RGB"))

    # Crop the left body background using the same coordinates
    # as the left-minus-right resmat.
    base_crop = base_image[:, LEFT_X1:LEFT_X2, :]

    height, width, number_of_emotions = average_resmat.shape

    if base_crop.shape[:2] != (height, width):
        raise ValueError(
            "The base-image crop and average_resmat do not match.\n"
            f"Base crop shape: {base_crop.shape[:2]}\n"
            f"Average map shape: {(height, width)}")

    # One symmetric scale for all emotion maps
    maximum = np.nanmax(
        np.abs(average_resmat))

    if not np.isfinite(maximum) or maximum == 0:
        maximum = 1

    plot_rows = int(
        np.ceil(number_of_emotions / plot_columns))

    fig, axes = plt.subplots(
        plot_rows,
        plot_columns,
        figsize=(
            3 * plot_columns,
            5 * plot_rows),
        constrained_layout=True)

    axes = np.atleast_1d(axes).ravel()

    heatmap = None

    for n in range(number_of_emotions):
        axis = axes[n]

        # Draw body background first
        axis.imshow(base_crop)

        # Draw the average left-minus-right result over it
        heatmap = axis.imshow(
            average_resmat[:, :, n],
            cmap="seismic",
            vmin=-maximum,
            vmax=maximum,
            alpha=0.65,
            interpolation="nearest")

        label = labels[n] if n < len(labels) else f"condition_{n}"

        axis.set_title(
            label,
            fontsize=10)

        axis.axis("off")

    # Turn off unused grid positions
    for axis in axes[number_of_emotions:]:
        axis.axis("off")

    fig.colorbar(
        heatmap,
        ax=axes[:number_of_emotions].tolist(),
        shrink=0.7,
        label="Mean activation intensity",)

    fig.suptitle(
        f"Average emotion body maps "
        f"(N = {number_of_subjects} subjects)",
        fontsize=16)

    plt.show()
    return fig

average_resmat, all_subjects, subject_ids = average_subject_maps(
    npz_folder)

fig = visualize_average_maps(
    average_resmat=average_resmat,
    base_image_path=base_image_path,
    labels=LABELS,
    number_of_subjects=len(subject_ids),
    plot_columns=7)