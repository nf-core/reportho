#!/usr/bin/env python3

import sys
import csv

def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python make_score_table.py <merged_csv>")
        sys.exit(1)

    # Read the CSV into a list of lists, it has a header
    with open(sys.argv[1], "r") as f:
        reader = csv.reader(f)
        data = list(reader)

    # Get the header and the data
    header = data[0]
    data = data[1:]

    # Calculate a score column, i.e. the sum of all the columns except the first
    scores = [sum([int(i) for i in row[1:]]) for row in data]

    # Print the header
    print("id," + ",".join(header[1:]) + ",score")

    # Print the data
    for i, row in enumerate(data):
        print(row[0] + "," + ",".join(row[1:]) + "," + str(scores[i]))


if __name__ == "__main__":
    main()
