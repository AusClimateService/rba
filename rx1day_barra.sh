#
# Bash script for calculating Rx1day from BARRA data
#
# Usage: bash rx1day_barra.sh {flags}
#
#   flags:  optional flags (e.g. -e for execute)
#

flags=$1

python=/g/data/xv83/dbi599/miniconda3/envs/unseen/bin/python

indir=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day
outdir=/g/data/xv83/dbi599/rba/Rx1day/BARRA-R2

pr_files1=(`ls ${indir}/pr/latest/*_19[8,9]???-??????.nc`)
pr_files2=(`ls ${indir}/pr/latest/*_20[0,1]???-??????.nc`)
pr_files3=(`ls ${indir}/pr/latest/*_202[0,1,2,3,4]??-??????.nc`)
pr_files=( "${pr_files1[@]}" "${pr_files2[@]}" "${pr_files3[@]}" )

nc_outfile=${outdir}/Rx1day_yr_BARRA-R2_AUST-11_1980-2024.nc
csv_outfile=${outdir}/Rx1day_yr_BARRA-R2_aus-states-cities_1980-2024.csv
nc_command="${python} /home/599/dbi599/rba/rx1day.py ${rx1day_path} ${pr_files[@]}"
csv_command="${python} /home/599/dbi599/rba/nc_to_csv.py ${nc_outfile} Rx1day ${csv_outfile} --add_cities"
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
    rm ${nc_outfile}
fi


