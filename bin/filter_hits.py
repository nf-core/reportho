#!/usr/bin/env python3

import csv
import sys

def load_data_from_csv(file_path):
    data = []
    print(file_path, file=sys.stderr)
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            data.append({
                'ID': row[0],
                'oma': row[1],
                'panther': row[2],
                'inspector': row[3],
                'score': row[4]
            })
    return data


def filter_data(data, threshold):
    filtered_data = []
    for row in data:
        if float(row['score']) >= threshold:
            filtered_data.append(row)
    return filtered_data


def filter_centroid(data):
    oma_count = 0
    oma_score = 0
    panther_count = 0
    panther_score = 0
    inspector_count = 0
    inspector_score = 0
    for row in data:
        oma_count += int(row['oma'])
        oma_score += int(row['oma']) if int(row['panther']) or int(row['inspector']) else 0
        panther_count += int(row['panther'])
        panther_score += int(row['panther']) if int(row['oma']) or int(row['inspector']) else 0
        inspector_count += int(row['inspector'])
        inspector_score += int(row['inspector']) if int(row['oma']) or int(row['panther']) else 0
    oma_ratio = oma_score / oma_count if oma_count else 0
    panther_ratio = panther_score / panther_count if panther_count else 0
    inspector_ratio = inspector_score / inspector_count if inspector_count else 0
    # select the source with the highest ratio and filter the data by it
    if oma_ratio >= panther_ratio and oma_ratio >= inspector_ratio:
        return [row for row in data if int(row['oma'])]
    elif panther_ratio >= oma_ratio and panther_ratio >= inspector_ratio:
        return [row for row in data if int(row['panther'])]
    else:
        return [row for row in data if int(row['inspector'])]


def main():
    # arg check
    if len(sys.argv) < 3:
        print("Usage: python filter_hits.py <input_file> <strategy>")
        sys.exit(1)
    # load data
    data = load_data_from_csv(sys.argv[1])
    # filter data
    # strategies: intersection, majority, union, centroid
    if sys.argv[2] == 'intersection':
        filtered_data = filter_data(data, 3)
    elif sys.argv[2] == 'majority':
        filtered_data = filter_data(data, 2)
    elif sys.argv[2] == 'union':
        filtered_data = filter_data(data, 1)
    elif sys.argv[2] == 'centroid':
        filtered_data = filter_centroid(data)
    else:
        print("Invalid strategy. Choose from: intersection, majority, union, centroid")
        sys.exit(1)
    # print filtered data
    for row in filtered_data:
        print(row['ID'])

if __name__ == "__main__":
    main()
