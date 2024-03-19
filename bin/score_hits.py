#!/usr/bin/env python3

import csv
import sys

def load_data_from_csv(file_path):
    with open(file_path, "r") as f:
        reader = csv.DictReader(f)
        data = list(reader)
    return data


def filter_data(data, threshold):
    filtered_data = []
    for row in data:
        if float(row['score']) >= threshold:
            filtered_data.append(row)
    return filtered_data


def filter_centroid(data):
    # get columns except first and last into a list of lists
    columns = [[float(list(row.values())[i]) for row in data] for i in range(1, len(data[0])-1)]
    # calculate agreement
    scores = [0 for column in columns]
    for i in range(len(columns)):
        if sum([column[i] for column in columns]) > 1:
            for j in range(len(columns[i])):
                scores[i] += columns[i][j]
    ratios = [scores[i] / sum(columns[i]) for i in range(len(columns))]
    # get index of highest ratio
    centroid = ratios.index(max(ratios))
    # filter data
    filtered_data = []
    for i in range(len(data)):
        if list(data[i].values())[centroid+1] == '1':
            filtered_data.append(data[i])
    return filtered_data


def main():
    # arg check
    if len(sys.argv) < 4:
        print("Usage: python filter_hits.py <input_file> <prefix> <query>")
        sys.exit(1)
    # load data
    data = load_data_from_csv(sys.argv[1])
    prefix = sys.argv[2]
    with open(sys.argv[3], 'r') as f:
        query = f.read().strip()
    # filter data
    for score in range(1, max([int(row['score']) for row in data])+1):
        f = open(f"{prefix}_minscore_{score}.txt", 'w')
        filtered_data = filter_data(data, score)
        print(query, file=f)
        for row in filtered_data:
            print(row['id'], file=f)
        f.close()

    filtered_data = filter_centroid(data)
    f = open(f"{prefix}_centroid.txt", 'w')
    print(query, file=f)
    for row in filtered_data:
        print(row['id'], file=f)
    f.close()

if __name__ == "__main__":
    main()
