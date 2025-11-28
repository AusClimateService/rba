"""Take a dataset and produce a chunked zarr collection."""

import argparse

import numpy as np
import xesmf as xe
import xarray as xr
import cmdline_provenance as cmdprov


def xesmf_regrid(ds, variable=None):
    """Regrid data using xesmf directly.
    
    Parameters
    ----------
    ds : xarray Dataset
        Dataset to be regridded
    ds_grid : xarray Dataset
        Dataset containing target horizontal grid
    variable : str, optional
        Variable to restore attributes for
    method : str, default bilinear
        Method for regridding
    
    Returns
    -------
    ds : xarray Dataset
    
    """
    
    global_attrs = ds.attrs
    if variable:
        var_attrs = ds[variable].attrs
    #ds_grid = xc.regridder.grid.create_uniform_grid(-90, 90.1, 1.25, 0, 359.9, 1.875)
    lat_attrs = {
        'units': 'degrees_north',
        'axis': 'Y',
        'long_name': 'Latitude',
        'standard_name': 'latitude'
    }
    lon_attrs = {
        'units': 'degrees_east',
        'axis': 'X',
        'long_name': 'Longitude',
        'standard_name': 'longitude'
    }
    ds_grid = xr.Dataset(
        {
            "lat": (["lat"], np.arange(-90, 90.1, 1.25), lat_attrs),
            "lon": (["lon"], np.arange(0, 359.9, 1.875), lon_attrs),
        }
    )
    regridder = xe.Regridder(ds, ds_grid, 'bilinear')
    ds = regridder(ds)
    ds.attrs = global_attrs
    if variable:
        ds[variable].attrs = var_attrs

    return ds


def drop_vars(ds):
    """Drop unwanted variables"""

    if (ds.attrs['source_id'] == 'ACCESS-ESM1-5'):
        nlats = len(ds['lat'])
        if nlats == 144:
            ds = xesmf_regrid(ds, variable=ds.attrs['variable_id'])

    for var in ['height', 'sigma', 'model_level_number', 'level_height', 'crs', 'lat_bnds', 'lon_bnds']:
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
    
