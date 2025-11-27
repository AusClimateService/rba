#
# Bash script for calculating FFDI from BARRA-R2 data
#
# Usage: bash ffdi_barra.sh {flags}
#
#   flags:  optional flags (e.g. -e for execute; -c for clean up)
#

flags=$1

python=/g/data/xv83/dbi599/miniconda3/envs/unseen/bin/python

indir=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day
indir2=/g/data/ia39/australian-climate-service/test-data/observations/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day
ffdi_dir=/g/data/xv83/dbi599/rba/FFDI/BARRA-R2

# Keetch-Byram Drought Index (KBDI)

pr_files1=(`ls ${indir}/pr/latest/*_19[8,9]???-??????.nc`)
pr_files2=(`ls ${indir}/pr/latest/*_20[0,1]???-??????.nc`)
pr_files3=(`ls ${indir}/pr/latest/*_202[0,1,2,3,4]??-??????.nc`)
pr_files=( "${pr_files1[@]}" "${pr_files2[@]}" "${pr_files3[@]}" )

pr_clim_path=${ffdi_dir}/pr_yr-climatology_BARRA-R2_AUST-11_1980-2024.nc
pr_clim_command="${python} /home/599/dbi599/rba/pr_climatology.py ${pr_files[@]} 1980-01-01 2024-12-31 ${pr_clim_path} --ausclip"
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

# Zarr

for var in pr tasmax hursmin sfcWindmax; do
    if [[ "${var}" == "hursmin" ]] ; then
        vardir=${indir2}
    else
        vardir=${indir}
    fi
    infiles1=(`ls ${vardir}/${var}/latest/*_19[8,9]???-??????.nc`)
    infiles2=(`ls ${vardir}/${var}/latest/*_20[0,1]???-??????.nc`)
    infiles3=(`ls ${vardir}/${var}/latest/*_202[0,1,2,3,4]??-??????.nc`)
    infiles=( "${infiles1[@]}" "${infiles2[@]}" "${infiles3[@]}" )
    zarr_file=${ffdi_dir}/${var}_day_BARRA-R2_AUST-11_1980-2024.zarr
    zarr_temp_file=${ffdi_dir}/${var}-temp_day_BARRA-R2_AUST-11_1980-2024.zarr
    declare ${var}_zarr_file=${zarr_file}
    zarr_command="/g/data/xv83/dbi599/miniconda3/envs/agcd/bin/python /home/599/dbi599/rba/nc_to_rechunked_zarr.py ${infiles[@]} ${var} ${zarr_file} ${zarr_temp_file} --ausclip"
    if [[ "${flags}" == "-e" ]] ; then
        echo ${zarr_command}
        ${zarr_command}
    else
        echo ${zarr_command}
    fi
done

# FFDI

FFDIx_nc_path=${ffdi_dir}/FFDIx_yr_BARRA-R2_AUST-11_1980-2024.nc
FFDIgt99p_nc_path=${ffdi_dir}/FFDIgt99p_yr_BARRA-R2_AUST-11_1980-2024.nc
FFDIx_csv_path=${ffdi_dir}/FFDIx_yr_BARRA-R2_aus-states_1980-2024.csv
FFDIgt99p_csv_path=${ffdi_dir}/FFDIgt99p_yr_BARRA-R2_aus-states_1980-2024.csv

ffdi_command="${python} /home/599/dbi599/rba/ffdi.py ${FFDIx_nc_path} ${FFDIgt99p_nc_path} --pr_data ${pr_zarr_file} --tasmax_data ${tasmax_zarr_file} --hursmin_data ${hursmin_zarr_file} --sfcWindmax_data ${sfcWindmax_zarr_file} --kbdi_files ${kbdi_files[@]} --start_year 1980 --end_year 2024"
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
    rm -r ${pr_zarr_file}
    rm -r ${tasmax_zarr_file}
    rm -r ${hursmin_zarr_file}
    rm -r ${sfcWindmax_zarr_file}
fi


