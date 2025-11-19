## Example files

The file naming convention for data files uses the following descriptors:

- `{metric}` is:  
  - `spei`: Standardised Precipitation Evapotranspiration Index (SPEI)  
  - `wsdi`: Warm Spell Duration Index (WSDI) 
  - `ffdix`: Annual maximum daily Forest Fire Danger Index (FFDI)
  - `ffdigt90p`: Days per year above the reference 99th percentile FFDI   
- `{timescale}` is annual (`yr`) or monthly (`mon`)  
- `{model}` is the name of a CMIP6 global climte model or BARRA-R2 for observations  
- `{experiment}` is a future emissions scenario (`ssp126`, `ssp245`, `ssp370` or `ssp585`)  
- `{run}` is a specific model run (e.g. `r1i1p1f1`) or all runs for that model (`ensemble`)  
- `{locations}` is Australian states (`aus-states`) or Australian states and cities (`aus-states-cities`)  
- `{period}` is the time period spanned by the data (e.g. `1850-2100`)  
- `{percentile}` the threshold percentile used in likelihood calculations:
  - `99-0p` is the 99.0 percentile or 1-in-100 year high event
  - `98-0p` is the 98.0 percentile or 1-in-50 year high event
  - `97-5p` is the 97.5 percentile or 1-in-40 year high event
  - `97-0p` is the 97.0 percentile or 1-in-33 year high event
  - `96-7p` is the 96.7 percentile or 1-in-30 year high event
  - `96-0p` is the 96.0 percentile or 1-in-25 year high event
  - `95-0p` is the 95.0 percentile or 1-in-20 year high event
  - `94-0p` is the 94.0 percentile or 1-in-17 year high event
  - `93-0p` is the 93.0 percentile or 1-in-14 year high event
  - `92-0p` is the 92.0 percentile or 1-in-13 year high event
  - `99-0p` is the 91.0 percentile or 1-in-11 year high event
  - `90-0p` is the 90.0 percentile or 1-in-10 year high event
  - `10-0p` is the 10.0 percentile or 1-in-10 year low event
  - `09-0p` is the 9.0 percentile or 1-in-11 year low event
  - `08-0p` is the 8.0 percentile or 1-in-13 year low event
  - `07-0p` is the 7.0 percentile or 1-in-14 year low event
  - `06-0p` is the 6.0 percentile or 1-in-17 year low event
  - `05-0p` is the 5.0 percentile or 1-in-20 year low event
  - `04-0p` is the 4.0 percentile or 1-in-25 year low event
  - `03-3p` is the 3.3 percentile or 1-in-30 year low event
  - `03-0p` is the 3.0 percentile or 1-in-33 year low event
  - `02-5p` is the 2.5 percentile or 1-in-40 year low event
  - `02-0p` is the 2.0 percentile or 1-in-50 year low event
  - `01-0p` is the 1.0 percentile or 1-in-100 year low event


#### Raw data

Format:
```
{metric}_{timescale}_{model}_{experiment}_{run}_{locations}_{period}.csv
```
Examples:
```
wsdi_yr_ACCESS-CM2_ssp245_ensemble_aus-states-cities_1850-2100.csv
wsdi_yr_BARRA-R2_aus-states-cities_1980-2024.csv
```

#### Likelihoods

Format:
```
{metric}_{timescale}_{percentile}-likelihood_{model}_{experiment}_{locations}_{period}.csv
```

Example:
```
wsdi_yr_98-0p-likelihood_ACCESS-CM2_ssp245_aus-states-cities_1860-2091.csv
```

The threshold value corresponding to a given percentile can be found in a corresponding percentiles file. e.g:
```
wsdi_yr_percentiles_ACCESS-CM2_ssp245_aus-states-cities_1950-2014.csv
```


