#
# Bash script for calculating WDSI from BARRA data
#
# Usage: bash wsdi_cmip6.sh {flags}
#
#   flags:           optional flags (e.g. -e for execute; -c for clean up)
#

flags=$1

python=/g/data/xv83/dbi599/miniconda3/envs/unseen/bin/python

indir=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/tasmax/latest
outdir=/g/data/xv83/dbi599/rba/WSDI/BARRA-R2

infiles1=(`ls ${indir}/*_19[8,9]???-??????.nc`)
infiles2=(`ls ${indir}/*_20[0,1]???-??????.nc`)
infiles3=(`ls ${indir}/*_202[0,1,2,3,4]??-??????.nc`)

infiles=( "${infiles1[@]}" "${infiles2[@]}" "${infiles3[@]}" )

nc_outfile=wsdi_yr_BARRA-R2_AUS-11_1980-2024.nc
csv_outfile=wsdi_yr_BARRA-R2_aus-states-cities_1980-2024.csv
    
nc_command="${python} /home/599/dbi599/rba/wsdi.py ${infiles[@]} ${outdir}/${nc_outfile}"
csv_command="${python} /home/599/dbi599/rba/nc_to_csv.py ${outdir}/${nc_outfile} WSDI ${outdir}/${csv_outfile} --add_cities"
if [[ "${flags}" == "-e" ]] ; then
    mkdir -p ${outdir}
    echo ${nc_command}
    ${nc_command}
    echo ${csv_command}
    ${csv_command}
else
    echo ${nc_command}
    echo ${csv_command}
fi

if [[ "${flags}" == "-c" ]] ; then
    rm ${outdir}/${nc_outfile}
fi
