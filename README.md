## Data for Reserve Bank of Australia (RBA) economic modelling

The RBA requires climate data out to 2100 relating to heatwaves, droughts and bushfires.

### Metrics

The following metrics were selected:
- *Warm Spell Duration Index (WSDI)*:
  The number of days in a sequence of at least six consecutive days
  during which the value of the daily maximum temperature (tasmax)
  is greater than the 90th percentile of tasmax calculated for a five-day window centered on each calendar day,
  using all data for the given calendar daypentad from the data period for a reference climate (1950-2014). 
- *Standardised Precipitation Evapotranspiration Index (SPEI)*:
  A measure of the integrated water deficit in a location,
  taking into account the contributions of both precipitation (pr) and temperature dependent evapotranspiration.
  The integration period for this production is 12 months (i.e. the SPEI-12).
- *Forest Fire Danger Index (FFDI)*:
  A numeric indicator of the potential danger of a forest fire,
  based on the weather conditions only
  (temperature, rainfall deficit, humidity and wind speed).
  We calculate the maximum daily FFDI value for the year (FFDIx)
  and the number of days per year above the 99th percentile (FFDIgt99p)
  of the reference period (1950-2014).

The WSDI and SPEI were partly selected because they are also available from the
[Climate Data Knowledge Portal](https://climateknowledgeportal.worldbank.org/country/australia/climate-data-projections),
which allows for comparisons against other countries.

### CMIP6 models

In order to calculate empirical likelihoods and how they are changing over time,
large model ensembles were required.
In other words, it was preferable to use data from CMIP6 climate models that performed
multiple simulations (i.e. multiple ensemble members) for each future emission scenario.

For the WSDI (which requires tasmax data)
and SPEI (which requires tasmax, tasmin and pr data),
we selected all CMIP6 models that archived daily data for at least five common runs
across the ssp126, ssp245, ssp370 and ssp585 future emissions scenarios:
- EC-Earth3 (57 runs)
- CanESM (50)
- ACCESS-ESM1-5 (40)
- MPI-ESM1-2-LR (10)
- ACCESS-CM2 (10)
- IPSL-CM6A-LR (6)
- UK-ESM1-0-LL (5)
- EC-Earth3-Veg (5)

For the FFDI (which requires pr, tasmax, hursmin, sfcWindmax),
we selected any models at all that archived the required daily variables:
- ACCESS-ESM1-5 (40)
- EC-Earth-Veg (2)
- EC-Earth3 (1)
- CNRM-ESM2-1 (1)
- CMCC-ESM2 (1)

### Spatial aggregation

Each metric is calculated on the native grid of the climate model.
For state and national values, a weighted mean is then calculated
where the weight for each grid cell is the area of the cell multiplied
by the fraction of the cell that overlaps
with the geopgraphic shape (e.g. state) of interest. 
See [development/wsdi_cmip6.ipynb](https://github.com/AusClimateService/rba/blob/master/development/wsdi_cmip6.ipynb)
for an illustrated example.

For spatial aggregation of FFDI values,
grid points in arid climate zones are excluded since those areas
do not experience large scale fires.
See [development/koppen_climate_zones.ipynb](https://github.com/AusClimateService/rba/blob/master/development/koppen_climate_zones.ipynb)
and [development/ffdi-cmip6.ipynb](https://github.com/AusClimateService/rba/blob/master/development/ffdi-cmip6.ipynb) for details.

### Computation

To generate the data submit a job:

```
qsub -v metric=wsdi,model=MPI-ESM1-2-LR,ssp=ssp370,run=r25i1p1f1,grid=gn,version='v*' cmip6.job
```

The csv files from numerous runs can then be merged using `concat_csv.py`.

Don't forget to clean up afterwards (i.e. delete all files except the final csv files):

```
bash wsdi_cmip6.sh MPI-ESM1-2-LR ssp370 r25i1p1f1 gn 'v*' -c 
```

(The data generation and clean up steps can be achived by running `run.sh`.)
