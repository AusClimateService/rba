## Example files

The file naming convention for data files is as follows:

```
{metric}_{timescale}_{model}_{experiment}_{run}_{locations}_{period}.csv
```

- `{metric}` is:  
  - `spei`: Standardised Precipitation Evapotranspiration Index (SPEI)  
  - `wsdi`: Warm Spell Duration Index (WSDI) 
  - `FFDIx`: Annual maximum daily Forest Fire Danger Index (FFDI)
  - `FFDIgt90p`: Days per year above the reference 99th percentile FFDI   
- `{timescale}` is annual (`yr`) or monthly (`mon`)  
- `{model}` is the name of a CMIP6 global climte model  
- `{experiment}` is a future emissions scenario (`ssp126`, `ssp245`, `ssp370` or `ssp585`)  
- `{run}` is a specific model run (e.g. `r1i1p1f1`) or all runs for that model (`ensemble`)  
- `{locations}` is Australian states (`aus-states`) or Australian states and cities (`aus-states-cities`)  
- `{period}` is the time period spanned by the data (e.g. `1850-2100`)  
