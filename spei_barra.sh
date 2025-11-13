#
# Bash script for calculating SPEI from BARRA data
#
# Usage: bash spei_barra.sh {flags}
#
#   flags:           optional flags (e.g. -e for execute; -c for clean up)
#

flags=$1

python=/g/data/xv83/dbi599/miniconda3/envs/unseen/bin/python

indir=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day
spei_dir=/g/data/xv83/dbi599/rba/SPEI/BARRA-R2

# Potential evapotranspiration (evspsblpot)

tasmin_files1=(`ls ${indir}/tasmin/latest/*_19[8,9]???-??????.nc`)
tasmin_files2=(`ls ${indir}/tasmin/latest/*_20[0,1]???-??????.nc`)
tasmin_files3=(`ls ${indir}/tasmin/latest/*_202[0,1,2,3,4]??-??????.nc`)
tasmin_files=( "${tasmin_files1[@]}" "${tasmin_files2[@]}" "${tasmin_files3[@]}" )

method=hargreaves85
evspsblpot_files=()
for tasmin_path in "${tasmin_files[@]}"; do
    tasmax_path=`echo ${tasmin_path} | sed s:tasmin:tasmax:g`
    evspsblpot_file=`basename ${tasmin_path} | sed s:tasmin:evspsblpot-${method}:g`
    evspsblpot_path=${spei_dir}/${evspsblpot_file}
    evspsblpot_files+=(${evspsblpot_path})
    command="${python} /home/599/dbi599/rba/evspsblpot.py ${evspsblpot_path} ${method} --tasmin_file ${tasmin_path} --tasmax_file ${tasmax_path}"
    if [[ "${flags}" == "-e" ]] ; then
        mkdir -p ${spei_dir}
        echo ${command}
        ${command}
    else
        echo ${command}
    fi 
done

# SPEI

pr_files1=(`ls ${indir}/pr/latest/*_19[8,9]???-??????.nc`)
pr_files2=(`ls ${indir}/pr/latest/*_20[0,1]???-??????.nc`)
pr_files3=(`ls ${indir}/pr/latest/*_202[0,1,2,3,4]??-??????.nc`)
pr_files=( "${pr_files1[@]}" "${pr_files2[@]}" "${pr_files3[@]}" )

spei_path=${spei_dir}/spei_mon_BARRA-R2_AUS-11_1980-2024.nc
csv_path=${spei_dir}/spei_mon_BARRA-R2_aus-states_1980-2024.csv

spei_command="${python} /home/599/dbi599/rba/spei.py ${spei_path} --dist fisk --pr_files ${pr_files[@]} --evspsblpot_files ${evspsblpot_files[@]}"
csv_command="${python} /home/599/dbi599/rba/nc_to_csv.py ${spei_path} SPEI ${csv_path}"
if [[ "${flags}" == "-e" ]] ; then
    echo ${spei_command}
    ${spei_command}
    echo ${csv_command}
    ${csv_command}
else
    echo ${spei_command}
    echo ${csv_command}
fi

if [[ "${flags}" == "-c" ]] ; then
    rm ${evspsblpot_files[@]}
    rm ${spei_path}
fi

