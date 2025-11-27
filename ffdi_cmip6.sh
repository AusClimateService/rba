#
# Bash script for calculating FFDI from CMIP6 data
#
# Usage: bash ffdi_cmip6.sh {model} {ssp} {run} {grid} {hversion} {sversion} {flags}
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
    start=1950
elif [[ "${model}" == "ACCESS-CM2" ]] ; then
    indir=/g/data/fs38/publications
    start=1850
else
    indir=/g/data/oi10/replicas
    start=1850
fi
ffdi_dir=/g/data/xv83/dbi599/rba/FFDI/${model}/${ssp}

# Keetch-Byram Drought Index (KBDI)

pr_hist_files=(`ls ${indir}/CMIP6/CMIP/*/${model}/historical/${run}/day/pr/${grid}/${hversion}/*.nc`)
pr_ssp_files=(`ls ${indir}/CMIP6/ScenarioMIP/*/${model}/${ssp}/${run}/day/pr/${grid}/${sversion}/*_20??????-????????.nc`)
pr_files=( "${pr_hist_files[@]}" "${pr_ssp_files[@]}" )

pr_clim_path=${ffdi_dir}/pr_yr-climatology_${model}_historical_${run}_${grid}_1950-2014.nc
pr_clim_command="${python} /home/599/dbi599/rba/pr_climatology.py ${pr_hist_files[@]} 1950-01-01 2014-12-31 ${pr_clim_path} --ausclip"
if [[ "${flags}" == "-e" ]] ; then
    mkdir -p ${ffdi_dir}
    echo ${pr_clim_command}
    ${pr_clim_command}
else
    echo ${pr_clim_command}
fi

kbdi_files=()
for pr_path in "${pr_files[@]}"; do
    tasmax_path=`echo ${pr_path} | sed s:pr:tasmax:g`
    kbdi_file=`basename ${pr_path} | sed s:pr:kbdi:g`
    kbdi_path=${ffdi_dir}/${kbdi_file}
    kbdi_files+=(${kbdi_path})
    kbdi_command="${python} /home/599/dbi599/rba/kbdi.py ${pr_path} ${tasmax_path} ${pr_clim_path} ${kbdi_path} --ausclip"
    if [[ "${flags}" == "-e" ]] ; then
        echo ${kbdi_command}
        ${kbdi_command}
    else
        echo ${kbdi_command}
    fi 
done

# Concat netCDF files

for var in pr tasmax hursmin sfcWindmax; do
    hist_files=(`ls ${indir}/CMIP6/CMIP/*/${model}/historical/${run}/day/${var}/${grid}/${hversion}/*.nc`)
    ssp_files=(`ls ${indir}/CMIP6/ScenarioMIP/*/${model}/${ssp}/${run}/day/${var}/${grid}/${sversion}/*_20??????-????????.nc`)
    hist_dates=`basename "${hist_files[0]}" | cut -d _ -f 7`
    start_date=`echo ${hist_dates} | cut -d - -f 1`
    ssp_dates=`basename "${ssp_files[-1]}" | cut -d _ -f 7`
    end_date=`echo ${ssp_dates} | cut -d - -f 2`
    end_date=`echo ${end_date} | cut -d . -f 1`
    concat_file=${ffdi_dir}/${var}_day_${model}_${ssp}_${run}_${grid}_${start_date}-${end_date}.nc
    declare ${var}_file=${concat_file}
    concat_command="/g/data/xv83/dbi599/miniconda3/envs/agcd/bin/python /home/599/dbi599/rba/nc_concat.py ${hist_files[@]} ${ssp_files[@]} ${concat_file} --ausclip"
    if [[ "${flags}" == "-e" ]] ; then
        echo ${concat_command}
        ${concat_command}
    else
        echo ${concat_command}
    fi
done

# FFDI

FFDIx_nc_path=${ffdi_dir}/FFDIx_yr_${model}_${ssp}_${run}_${grid}_${start}-2100.nc
FFDIgt99p_nc_path=${ffdi_dir}/FFDIgt99p_yr_${model}_${ssp}_${run}_${grid}_${start}-2100.nc
FFDIx_csv_path=${ffdi_dir}/FFDIx_yr_${model}_${ssp}_${run}_aus-states_${start}-2100.csv
FFDIgt99p_csv_path=${ffdi_dir}/FFDIgt99p_yr_${model}_${ssp}_${run}_aus-states_${start}-2100.csv

ffdi_command="${python} /home/599/dbi599/rba/ffdi.py ${FFDIx_nc_path} ${FFDIgt99p_nc_path} --pr_data ${pr_file} --tasmax_data ${tasmax_file} --hursmin_data ${hursmin_file} --sfcWindmax_data ${sfcWindmax_file} --kbdi_files ${kbdi_files[@]} --start_year ${start}"
FFDIx_csv_command="${python} /home/599/dbi599/rba/nc_to_csv.py ${FFDIx_nc_path} FFDIx ${FFDIx_csv_path} --mask_arid"
FFDIgt99p_csv_command="${python} /home/599/dbi599/rba/nc_to_csv.py ${FFDIgt99p_nc_path} FFDIgt99p ${FFDIgt99p_csv_path} --mask_arid"
if [[ "${flags}" == "-e" ]] ; then
    echo ${ffdi_command}
    ${ffdi_command}
    echo ${FFDIx_csv_command}
    ${FFDIx_csv_command}
    echo ${FFDIgt99p_csv_command}
    ${FFDIgt99p_csv_command}
else
    echo ${ffdi_command}
    echo ${FFDIx_csv_command}
    echo ${FFDIgt99p_csv_command}
fi

# Clean up

if [[ "${flags}" == "-c" ]] ; then
    rm ${pr_clim_path}
    rm ${kbdi_files[@]}
    rm -r ${pr_file}
    rm -r ${tasmax_file}
    rm -r ${hursmin_file}
    rm -r ${sfcWindmax_file}
    rm ${FFDIx_nc_path}
    rm ${FFDIgt99p_nc_path}
    rm ${FFDIx_csv_path}
    rm ${FFDIgt99p_csv_path}
else
    echo rm ${pr_clim_path}
    echo rm ${kbdi_files[@]}
    echo rm -r ${pr_file}
    echo rm -r ${tasmax_file}
    echo rm -r ${hursmin_file}
    echo rm -r ${sfcWindmax_file}
    echo rm ${FFDIx_nc_path}
    echo rm ${FFDIgt99p_nc_path}
    echo rm ${FFDIx_csv_path}
    echo rm ${FFDIgt99p_csv_path}
fi


