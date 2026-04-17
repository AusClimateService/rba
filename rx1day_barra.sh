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
rx1day_dir=/g/data/xv83/dbi599/rba/Rx1day/BARRA-R2

pr_files1=(`ls ${indir}/pr/latest/*_19[8,9]???-??????.nc`)
pr_files2=(`ls ${indir}/pr/latest/*_20[0,1]???-??????.nc`)
pr_files3=(`ls ${indir}/pr/latest/*_202[0,1,2,3,4]??-??????.nc`)
pr_files=( "${pr_files1[@]}" "${pr_files2[@]}" "${pr_files3[@]}" )

rx1day_path=${rx1day_dir}/Rx1day_BARRA-R2_AUST-11_1980-2024.nc
rx1day_command="${python} /home/599/dbi599/rba/rx1day.py ${rx1day_path} ${pr_files[@]}"
if [[ "${flags}" == "-e" ]] ; then
    mkdir -p ${rx1day_dir}
    echo ${rx1day_command}
    ${rx1day_command}
else
    echo ${rx1day_command}
fi

