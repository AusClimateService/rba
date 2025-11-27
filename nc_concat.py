"""Take a dataset and produce a chunked zarr collection."""

import argparse

import xarray as xr
import cmdline_provenance as cmdprov


def drop_vars(ds):
    """Drop unwanted variables"""

    for var in ['height', 'lat_bnds', 'lon_bnds', 'sigma', 'model_level_number', 'level_height', 'crs']:
        try:
            ds = ds.drop_vars(var)
        except ValueError:
            pass

    return ds


def main(args):
    """Run the command line program."""

    ds = xr.open_mfdataset(args.infiles, preprocess=drop_vars, attrs_file=args.infiles[-1])
    if args.ausclip:
        ds = ds.sel({'lat': slice(-44.5, -10), 'lon': slice(112, 156.25)})
    ds.attrs['history'] = cmdprov.new_log(
        infile_logs={args.infiles[0]: ds.attrs['history']}
    )
    ds.to_netcdf(args.outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )        
    parser.add_argument("infiles", type=str, nargs='*', help="Input files")
    parser.add_argument("outfile", type=str, help="Output file")
    parser.add_argument("--ausclip", action="store_true", default=False, help="Clip lat and lon bounds to Australia")
    args = parser.parse_args()
    main(args)
    
