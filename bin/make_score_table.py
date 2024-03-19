#!/usr/bin/env python3

import sys

def main() -> None:
    if len(sys.argv) < 4:
        print("Usage: python make_comparison.py <oma_group_file> <panther_group_file> <inspector_group_file>")
        sys.exit(1)

    oma_ids = []
    panther_ids = []
    inspector_ids = []

    with open(sys.argv[1]) as f:
        for line in f:
            oma_ids.append(line.strip())

    with open(sys.argv[2]) as f:
        for line in f:
            panther_ids.append(line.strip())

    with open(sys.argv[3]) as f:
        for line in f:
            inspector_ids.append(line.strip())

    union = set(oma_ids).union(set(panther_ids)).union(set(inspector_ids))

    scores = dict()
    for i in union:
        scores[i] = 0
        if i in oma_ids:
            scores[i] += 1
        if i in panther_ids:
            scores[i] += 1
        if i in inspector_ids:
            scores[i] += 1

    sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

    print("ID,oma,panther,inspector,score")
    for k,v in sorted_scores:
        print(f"{k},{1 if k in oma_ids else 0},{1 if k in panther_ids else 0},{1 if k in inspector_ids else 0},{v}")

if __name__ == "__main__":
    main()
