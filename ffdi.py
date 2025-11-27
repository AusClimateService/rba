"""Command line program for calculating the Forest Fire Danger Index (FFDI)"""

import argparse

import numpy as np
import xarray as xr
import xclim as xc
import dask.diagnostics
import cmdline_provenance as cmdprov
    

dask.diagnostics.ProgressBar().register()


def fix_metadata(ds, input_ds):
    """Fix FFDI metadata"""

    try:
        ds = ds.drop_vars(['height',])
    except:
        pass

    ds.attrs = input_ds.attrs
    ds['lat'].attrs = input_ds['lat'].attrs
    ds['lon'].attrs = input_ds['lon'].attrs
    ds['time'].attrs = input_ds['time'].attrs
    ds['FFDI'].attrs['long_name'] = 'Forest Fire Danger Index'
    ds['FFDI'].attrs['standard_name'] = 'forest_fire_danger_index'

    ds.attrs['variable_id'] = 'FFDI'
    ds.attrs['history'] = cmdprov.new_log()

    return ds


def main(args):
    """Run the program."""

    nyears = (args.end_year - args.start_year) + 1

    # Drought Factor
    kbdi_ds = xr.open_mfdataset(args.kbdi_files, attrs_file=args.kbdi_files[-1])
    kbdi_ds = kbdi_ds.sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31'))
    if args.test_region:
        kbdi_ds = kbdi_ds.sel({'lat': slice(-30, -25), 'lon': slice(130, 135)})
    assert len(np.unique(kbdi_ds['time'].dt.year)) == nyears
    ntime = len(kbdi_ds['KBDI'].time)
    nlat = len(kbdi_ds['KBDI'].lat)
    nlon = len(kbdi_ds['KBDI'].lon)
    kbdi_ds = kbdi_ds.chunk({'time': ntime, 'lat': nlat, 'lon': nlon})
    
    pr_ds = xr.open_dataset(args.pr_data)
    pr_ds = pr_ds.sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31'))
    if args.test_region:
        pr_ds = pr_ds.sel({'lat': slice(-30, -25), 'lon': slice(130, 135)})
    assert len(np.unique(pr_ds['time'].dt.year)) == nyears
    pr_ds['pr'] = xc.core.units.convert_units_to(pr_ds['pr'], 'mm/day')
    
    df_da = xc.indices.griffiths_drought_factor(pr_ds['pr'], kbdi_ds['KBDI'])

    # FFDI
    tasmax_ds = xr.open_dataset(args.tasmax_data)
    #tasmax_ds['tasmax'] = xc.core.units.convert_units_to(tasmax_ds['tasmax'], 'degC')
    tasmax_ds = tasmax_ds.sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31'))
    if args.test_region:
        tasmax_ds = tasmax_ds.sel({'lat': slice(-30, -25), 'lon': slice(130, 135)})
    assert len(np.unique(tasmax_ds['time'].dt.year)) == nyears
    tasmax_ds['time'] = df_da['time']

    hursmin_ds = xr.open_dataset(args.hursmin_data)
    hursmin_ds = hursmin_ds.sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31'))
    if args.test_region:
        hursmin_ds = hursmin_ds.sel({'lat': slice(-30, -25), 'lon': slice(130, 135)})
    assert len(np.unique(hursmin_ds['time'].dt.year)) == nyears
    hursmin_ds['time'] = df_da['time']

    sfcWindmax_ds = xr.open_dataset(args.sfcWindmax_data)
    sfcWindmax_ds = sfcWindmax_ds.sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31'))
    if args.test_region:
        sfcWindmax_ds = sfcWindmax_ds.sel({'lat': slice(-30, -25), 'lon': slice(130, 135)})
    assert len(np.unique(sfcWindmax_ds['time'].dt.year)) == nyears
    sfcWindmax_ds['time'] = df_da['time']

    ffdi_da = xc.indices.mcarthur_forest_fire_danger_index(
        df_da,
        tasmax_ds['tasmax'],
        hursmin_ds['hursmin'],
        sfcWindmax_ds['sfcWindmax']
    )
    ffdi_ds = ffdi_da.to_dataset(name='FFDI')
    ffdi_ds = fix_metadata(ffdi_ds, tasmax_ds)

    # Metrics
    FFDIx_da = ffdi_ds['FFDI'].resample({'time': 'YE'}).max('time', keep_attrs=True)
    FFDIx_ds = FFDIx_da.to_dataset(name='FFDIx')
    FFDIx_ds.attrs = ffdi_ds.attrs
    FFDIx_ds.to_netcdf(args.FFDIx_outfile)

    FFDI99p_da = ffdi_ds['FFDI'].sel(time=slice(f'{args.start_year}-01-01', f'{args.end_year}-12-31')).quantile(0.99, dim='time')
    FFDIgt99p_da = ffdi_ds['FFDI'] > FFDI99p_da
    FFDIgt99p_da = FFDIgt99p_da.resample({'time': 'YE'}).sum('time', keep_attrs=True)
    FFDIgt99p_ds = FFDIgt99p_da.to_dataset(name='FFDIgt99p')
    FFDIgt99p_ds.attrs = ffdi_ds.attrs
    FFDIgt99p_ds.to_netcdf(args.FFDIgt99p_outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("FFDIx_outfile", type=str, help="FFDIx output file name")
    parser.add_argument("FFDIgt99p_outfile", type=str, help="FFDIgt99p output file name")
    parser.add_argument("--start_year", default=1850, type=int, help="Start year")
    parser.add_argument("--end_year", default=2100, type=int, help="End year")
    parser.add_argument("--pr_data", type=str, required=True, help="input daily precipitation data (single netCDF file or zarr collection)")
    parser.add_argument("--tasmax_data", type=str, required=True, help="input daily maximum temperature data (single netCDF file or zarr collection)")
    parser.add_argument("--hursmin_data", type=str, required=True, help="input daily minimum relative humidity data (single netCDF file or zarr collection)")
    parser.add_argument("--sfcWindmax_data", type=str, required=True, help="input daily maximum surface wind speed data (single netCDF file or zarr collection)")
    parser.add_argument("--kbdi_files", type=str, required=True, nargs='*', help="input daily Keetch-Byram Drought Index files")
    parser.add_argument("--test_region", action="store_true", default=False, help="process a small test region")
    args = parser.parse_args()
    main(args)
