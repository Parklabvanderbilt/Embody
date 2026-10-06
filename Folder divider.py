from pathlib import Path
import shutil

# CHANGE THESE PATHS
source_folder = Path(r"/Users/hagrid/Desktop/ML/Data/All in-person data/Anne v5")
destination_folder = Path(r"/Users/hagrid/Desktop/ML/Data/interoception patient")

numbers = {
    "54890", "652164", "317207", "562029", "87032", "25392", "1150", "891632", "153158", "870231", "890673", "801248", "91938", "560016", "233610"
}

# Confirm the source folder is valid
if not source_folder.exists():
    raise FileNotFoundError(f"Source folder does not exist:\n{source_folder}")

if not source_folder.is_dir():
    raise NotADirectoryError(f"Source path is not a folder:\n{source_folder}")

destination_folder.mkdir(parents=True, exist_ok=True)

found_numbers = set()
copied_count = 0
files_checked = 0

for source_file in source_folder.rglob("*"):
    if not source_file.is_file():
        continue

    # Avoid searching files already copied into the destination
    try:
        source_file.relative_to(destination_folder)
        continue
    except ValueError:
        pass

    files_checked += 1

    # Search the filename and its relative folder path
    relative_path = source_file.relative_to(source_folder)
    searchable_text = str(relative_path).lower()

    matched_numbers = [
        number for number in numbers
        if number in searchable_text
    ]

    if not matched_numbers:
        continue

    print(f"FOUND: {source_file}")
    print(f"  Matched: {', '.join(matched_numbers)}")

    # Preserve existing subfolder structure
    destination_file = destination_folder / relative_path
    destination_file.parent.mkdir(parents=True, exist_ok=True)

    # Handle an existing file without overwriting it
    if destination_file.exists():
        stem = destination_file.stem
        suffix = destination_file.suffix
        counter = 2

        while destination_file.exists():
            destination_file = (
                destination_file.parent
                / f"{stem}_copy{counter}{suffix}"
            )
            counter += 1

    try:
        shutil.copy2(source_file, destination_file)
        print(f"  COPIED TO: {destination_file}")
        copied_count += 1
        found_numbers.update(matched_numbers)

    except Exception as error:
        print(f"  COPY ERROR: {error}")

missing_numbers = numbers - found_numbers

print("\n" + "=" * 60)
print(f"Files checked: {files_checked}")
print(f"Files copied:  {copied_count}")

if missing_numbers:
    print("\nNo matches found for:")
    for number in sorted(missing_numbers, key=int):
        print(f"  {number}")
else:
    print("\nAll numbers were found.")