"""Command line program for calculating the Keetch-Byram Drought Index (KBDI)"""

import argparse

import numpy as np
import xarray as xr
import xclim as xc
import dask.diagnostics
import cmdline_provenance as cmdprov
    

dask.diagnostics.ProgressBar().register()


def fix_metadata(ds, input_ds):
    """Fix KBDI metadata"""

    try:
        ds = ds.drop_vars(['height',])
    except:
        pass

    ds.attrs = input_ds.attrs
    ds['lat'].attrs = input_ds['lat'].attrs
    ds['lon'].attrs = input_ds['lon'].attrs
    ds['time'].attrs = input_ds['time'].attrs
    ds['KBDI'].attrs['long_name'] = 'Keetch-Byram Drought Index'
    ds['KBDI'].attrs['standard_name'] = 'keetch_byram_drought_index'

    ds.attrs['variable_id'] = 'KBDI'
    ds.attrs['history'] = cmdprov.new_log()

    return ds


def main(args):
    """Run the program."""

    tasmax_ds = xr.open_dataset(args.tasmax_file)
    if args.ausclip:
        tasmax_ds = tasmax_ds.sel({'lat': slice(-44.5, -10), 'lon': slice(112, 156.25)})
    tasmax_ds['tasmax'] = xc.core.units.convert_units_to(tasmax_ds['tasmax'], 'degC')

    pr_ds = xr.open_dataset(args.pr_file)
    if args.ausclip:
        pr_ds = pr_ds.sel({'lat': slice(-44.5, -10), 'lon': slice(112, 156.25)})
    pr_ds['pr'] = xc.core.units.convert_units_to(pr_ds['pr'], 'mm/day')
    
    pr_annual_clim_ds = xr.open_dataset(args.pr_annual_clim_file)
    if args.ausclip:
        pr_annual_clim_ds = pr_annual_clim_ds.sel({'lat': slice(-44.5, -10), 'lon': slice(112, 156.25)})

    kbdi_da = xc.indices.keetch_byram_drought_index(
        pr_ds['pr'],
        tasmax_ds['tasmax'],
        pr_annual_clim_ds['pr'],
    )

    kbdi_ds = kbdi_da.to_dataset(name='KBDI')
    kbdi_ds = fix_metadata(kbdi_ds, tasmax_ds)
    kbdi_ds.to_netcdf(args.outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("pr_file", type=str, help="input daily precipitation file")
    parser.add_argument("tasmax_file", type=str, help="input daily maximum temperature file")
    parser.add_argument("pr_annual_clim_file", type=str, help="input annual precipitation climatology file")
    parser.add_argument("outfile", type=str, help="output file name")
    parser.add_argument("--ausclip", action="store_true", default=False, help="Clip lat and lon bounds to Australia")
    args = parser.parse_args()
    main(args)
