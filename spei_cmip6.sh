#
# Bash script for calculating SPEI from CMIP6 data
#
# Usage: bash spei_cmip6.sh {model} {ssp} {run} {grid} {version} {flags}
#
#   model:           ACCESS-ESM1-5
#   ssp:             ssp126 ssp245 ssp370 ssp585
#   run:             r?i?p?i?
#   grid:            gn
#   hversion:        historical experiment version (vYYYYMMDD or 'v*')
#   sversion:        ssp experiment version (vYYYYMMDD or 'v*')
#   flags:           optional flags (e.g. -e for execute; -c for clean up)
#

model=$1
ssp=$2
run=$3
grid=$4
hversion=$5
sversion=$6
flags=$7

python=/g/data/xv83/dbi599/miniconda3/envs/unseen/bin/python

if [[ "${model}" == "ACCESS-ESM1-5" ]] ; then
    indir=/g/data/fs38/publications
elif [[ "${model}" == "ACCESS-CM2" ]] ; then
    indir=/g/data/fs38/publications
else
    indir=/g/data/oi10/replicas
fi
spei_dir=/g/data/xv83/dbi599/rba/SPEI/${model}/${ssp}

# Potential evapotranspiration (evspsblpot)

method=hargreaves85
evspsblpot_files=()

tasmin_hist_files=(`ls ${indir}/CMIP6/CMIP/*/${model}/historical/${run}/day/tasmin/${grid}/${hversion}/*.nc`)
for tasmin_path in "${tasmin_hist_files[@]}"; do
    vtasmin=`echo ${tasmin_path} | cut -d / -f 15`
    tasmax_path=`echo ${tasmin_path} | sed s:tasmin:tasmax:g`
    tasmax_path=`echo ${tasmax_path} | sed s:${vtasmin}:${hversion}:`
    tasmax_path=`ls ${tasmax_path}`
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

tasmin_ssp_files=(`ls ${indir}/CMIP6/ScenarioMIP/*/${model}/${ssp}/${run}/day/tasmin/${grid}/${sversion}/*20??????-????????.nc`)
for tasmin_path in "${tasmin_ssp_files[@]}"; do
    vtasmin=`echo ${tasmin_path} | cut -d / -f 15`
    tasmax_path=`echo ${tasmin_path} | sed s:tasmin:tasmax:g`
    tasmax_path=`echo ${tasmax_path} | sed s:${vtasmin}:${sversion}:`
    tasmax_path=`ls ${tasmax_path}`
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

pr_hist_files=(`ls ${indir}/CMIP6/CMIP/*/${model}/historical/${run}/day/pr/${grid}/${hversion}/*.nc`)
pr_ssp_files=(`ls ${indir}/CMIP6/ScenarioMIP/*/${model}/${ssp}/${run}/day/pr/${grid}/${sversion}/*20??????-????????.nc`)
spei_path=${spei_dir}/spei_mon_${model}_${ssp}_${run}_${grid}_1850-2100.nc
csv_path=${spei_dir}/spei_mon_${model}_${ssp}_${run}_aus-states_1850-2100.csv

spei_command="${python} /home/599/dbi599/rba/spei.py ${spei_path} --dist fisk --pr_files ${pr_hist_files[@]} ${pr_ssp_files[@]} --evspsblpot_files ${evspsblpot_files[@]}"
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
    rm ${csv_path}
else
    echo rm ${evspsblpot_files[@]}
    echo rm ${spei_path}
    echo rm ${csv_path}
fi

