"""Command line program for calculating the annual maximum 1-day precipitation (Rx1day)"""

import argparse

import numpy as np
import xarray as xr
import xclim as xc
import dask.diagnostics
import cmdline_provenance as cmdprov
    

dask.diagnostics.ProgressBar().register()


def main(args):
    """Run the program."""

    pr_file1 = args.pr_files[0]
    if 'zarr' in pr_file1:
        pr_ds = xr.open_dataset(args.pr_files[0], engine='zarr')
    else:
        pr_ds = xr.open_mfdataset(args.pr_files, attrs_file=args.pr_files[-1])

    pr_ds['pr'] = xc.core.units.convert_units_to(pr_ds['pr'], 'mm/day')

    rx1day_da = xc.indices.max_1day_precipitation_amount(pr_ds['pr'], freq='YS')   

    rx1day_ds = rx1day_da.to_dataset(name='Rx1day')
    rx1day_ds.attrs = pr_ds.attrs
    rx1day_ds.attrs['history'] = cmdprov.new_log()
    rx1day_ds.to_netcdf(args.outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("outfile", type=str, help="output file name")
    parser.add_argument("pr_files", type=str, nargs='*', help="input daily precipitation files")
    args = parser.parse_args()
    main(args)
