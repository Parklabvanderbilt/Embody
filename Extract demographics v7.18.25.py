import os
import csv
from pathlib import Path
from datetime import datetime
import re
import unicodedata

def read_text(path):
    raw = Path(path).read_bytes()
    for enc in ('utf-8-sig', 'cp949'):
        try:
            text = raw.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    else:
        text = raw.decode('utf-8', errors='replace')
    return unicodedata.normalize('NFC', text)


def extract_data_from_txt(file_path):
    """
    Extract data from a single data.txt file.
    Modify this function based on your specific data format.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = read_text(file_path).splitlines()

        # Example extraction logic - modify based on your data format
        data = {}
        data['Embody_id'] = file_path.parent.name
        data['Submission_time'] = extract_submission_time(file_path.parent)

        # Example: Extract second line as description
        if len(lines) >= 2:
            data['description'] = lines[1].strip()

        # Parse comma-separated values from all lines
        all_values = []
        for line in lines:
            line = line.strip()
            if line:  # Only process non-empty lines
                # Split by comma and add to all_values
                values = [value.strip() for value in line.split(',')]
                all_values.extend(values)

        # Create individual columns for each value
        for i, value in enumerate(all_values):
            if value:  # Only add non-empty values
                if i == 0:
                    data['Subject_id'] = value
                elif i == 2:
                    data['Age'] = value
                elif i == 1:
                    # Convert gender code to readable format
                    if value == '0':
                        data['Gender'] = 'Male'
                    elif value == '1':
                        data['Gender'] = 'Female'
                    else:
                        data['Gender'] = value  # Keep original if not 0 or 1
                elif i == 3:
                    data['Weight_kg'] = value
                elif i == 4:
                    data['Weight_lb'] = value
                elif i == 5:
                    data['Height_cm'] = value
                elif i == 6:
                    # Store feet value temporarily
                    feet_value = value
                elif i == 7:
                    # Combine feet and inches
                    inches_value = value
                    data['Height_ft_in'] = f"{feet_value}'{inches_value}\""
                elif i == 8:
                    # Convert handedness code to readable format
                    if value == '0':
                        data['Handedness'] = 'Left'
                    elif value == '1':
                        data['Handedness'] = 'Right'
                    else:
                        data['Handedness'] = value  # Keep original if not 0 or 1
                elif i == 9:
                    # Convert education code to readable format
                    education_map = {
                        '0': 'Middle School',
                        '1': 'High School',
                        '2': "Associate's",
                        '3': "Bachelor's",
                        '4': "Master's",
                        '5': 'Doctoral'
                    }
                    data['Education'] = education_map.get(value, value)  # Use mapping or keep original
                elif i == 10:
                    # Convert psychologist code to readable format
                    if value == '0':
                        data['Psychologist'] = 'No'
                    elif value == '1':
                        data['Psychologist'] = 'Yes'
                    else:
                        data['Psychologist'] = value  # Keep original if not 0 or 1
                elif i == 11:
                    # Convert psychiatrist code to readable format
                    if value == '0':
                        data['Psychiatrist'] = 'No'
                    elif value == '1':
                        data['Psychiatrist'] = 'Yes'
                    else:
                        data['Psychiatrist'] = value  # Keep original if not 0 or 1
                elif i == 12:
                    # Convert neurologist code to readable format
                    if value == '0':
                        data['Neurologist'] = 'No'
                    elif value == '1':
                        data['Neurologist'] = 'Yes'
                    else:
                        data['Neurologist'] = value  # Keep original if not 0 or 1
                else:
                    data[f'value_{i + 1}'] = value

        return data

    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def extract_submission_time(folder_path):
    """
    Read REQUEST_TIME out of techdata.txt (same folder as data.txt)
    and convert it to a readable timestamp.
    """
    techdata_path = folder_path / 'techdata.txt'
    if not techdata_path.exists():
        return None
    try:
        with open(techdata_path, 'r', encoding='utf-8') as f:
            content = f.read()
        match = re.search(r"'REQUEST_TIME'\s*=>\s*'?(\d+)'?", content)
        if match:
            return datetime.fromtimestamp(int(match.group(1))).strftime('%Y-%m-%d %H:%M:%S')
    except Exception as e:
        print(f"Error reading techdata.txt in {folder_path}: {e}")
    return None

def find_all_data_files(root_folder):
    """
    Recursively find all data.txt files in subfolders.
    """
    root_path = Path(root_folder)
    data_files = []

    # Use glob to find all data.txt files recursively
    for file_path in root_path.rglob('data.txt'):
        data_files.append(file_path)

    return data_files


def extract_to_csv(root_folder, output_csv='extracted_data.csv'):
    """
    Main function to extract data from all data.txt files and save to CSV.
    """
    # Find all data.txt files
    data_files = find_all_data_files(root_folder)

    if not data_files:
        print("No data.txt files found in the specified folder structure.")
        return

    print(f"Found {len(data_files)} data.txt files")

    # Extract data from all files
    all_data = []
    for file_path in data_files:
        print(f"Processing: {file_path}")
        extracted_data = extract_data_from_txt(file_path)
        if extracted_data:
            all_data.append(extracted_data)

    # Write to CSV
    if all_data:
        # Define the desired column order
        column_order = [
            'Embody_id', 'Subject_id', 'Submission_time','Gender', 'Age', 'Weight_kg', 'Weight_lb',
            'Height_cm', 'Height_ft_in', 'Handedness', 'Education',
            'Psychologist', 'Psychiatrist', 'Neurologist'
        ]

        # Get all possible field names and add any extra columns not in the predefined order
        all_fieldnames = set()
        for data in all_data:
            all_fieldnames.update(data.keys())

        # Add any additional fields not in the predefined order
        extra_fields = sorted([field for field in all_fieldnames if field not in column_order])
        fieldnames = column_order + extra_fields

        with open(output_csv, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(all_data)

        print(f"Data extracted to {output_csv}")
        print(f"Processed {len(all_data)} files successfully")
    else:
        print("No data was extracted from any files.")


# Example usage
if __name__ == "__main__":
    # Specify your root folder path
    root_folder = "/Users/hagrid/Desktop/ICPR - Gui/wave1&2&3/low paranoia wave 1&2&3 total"
    run_timestamp = datetime.now().strftime("%Y%m%d_%H%M")   

    # Specify output CSV file name
    output_file = f"/Users/hagrid/Desktop/ML/Demographics {run_timestamp}.csv"

    # Run the extraction
    extract_to_csv(root_folder, output_file)