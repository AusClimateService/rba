"""Command line program for calculating likleihoods"""

import argparse

import numpy as np
import pandas as pd


def main(args):
    """Run the program."""


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("infile", type=str, help="input file name")
    parser.add_argument("outfile", type=str, help="output file name")
    args = parser.parse_args()
    main(args)
