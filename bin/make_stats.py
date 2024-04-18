#!/usr/bin/env python3

import csv
import sys


def make_stats(score_table: str):
    # csv schema: id, [some columns], score
    # read csv
    max_score = 0
    with open(score_table) as f:
        reader = csv.reader(f)
        header = next(reader) # skip header
        max_score = len(header) - 3
        scores = [float(row[-1]) for row in reader]

    # calculate stats
    n = len(scores)
    mode = max(set(scores), key=scores.count)
    mean = sum(scores) / n
    goodness = mean / max_score
    percent_max = sum(score == max_score for score in scores) / n
    percent_privates = sum(score == 1 for score in scores) / n

    # print stats as yaml
    print(f"n: {n}")
    print(f"mode: {mode}")
    print(f"mean: {round(mean,3)}")
    print(f"goodness: {round(goodness,3)}")
    print(f"percent_max: {round(percent_max,3)}")
    print(f"percent_privates: {round(percent_privates,3)}")

def main():
    if len(sys.argv) < 2:
        print("Usage: make_stats.py <score_table>")
        sys.exit(1)
    score_table = sys.argv[1]
    make_stats(score_table)

if __name__ == "__main__":
    main()
