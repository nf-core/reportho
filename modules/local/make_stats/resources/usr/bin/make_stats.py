#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Calculate statistics from a score table."""

import argparse
import csv


def make_stats(score_table: str) -> None:
    """Calculate statistics from a score table."""
    # read csv
    max_score = 0
    with open(score_table) as f:
        reader = csv.reader(f)
        try:
            header = next(reader)  # skip header
        except StopIteration:
            return
        max_score = len(header) - 3
        scores = [float(row[-1]) for row in reader]

    # calculate stats
    n = len(scores)
    mode = max(set(scores), key=scores.count) if scores else 0
    mean = sum(scores) / n if n else 0
    goodness = mean / max_score
    percent_max = sum(score == max_score for score in scores) / n if n else 0
    percent_privates = sum(score == 1 for score in scores) / n if n else 0

    # print stats as yaml
    print(f"n: {n}")
    print(f"mode: {mode}")
    print(f"mean: {round(mean, 3)}")
    print(f"goodness: {round(goodness, 3)}")
    print(f"percent_max: {round(percent_max, 3)}")
    print(f"percent_privates: {round(percent_privates, 3)}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Calculate statistics from a score table.")
    parser.add_argument(
        "-s",
        "--score-table",
        required=True,
        help="Path to score table CSV file.",
    )
    args = parser.parse_args()
    make_stats(args.score_table)


if __name__ == "__main__":
    main()
