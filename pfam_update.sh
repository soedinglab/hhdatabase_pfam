#!/bin/bash
source ~/.bashrc
source paths.sh
set -ex

mkdir -p ${pfam_build_dir}
pfam_lock_file=${pfam_build_dir}/lock_pfam.txt

if [ -e ${pfam_lock_file} ] && kill -0 `cat ${pfam_lock_file}`; then
  echo "already running"
  exit
fi
rm -f ${pfam_build_dir}/new_relnotes.txt
curl -o ${pfam_build_dir}/new_relnotes.txt ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/relnotes.txt
cmp --silent ${pfam_build_dir}/new_relnotes.txt ${pfam_build_dir}/old_relnotes.txt > /dev/null && rm -f ${pfam_lock_file} && exit 0
mv -f ${pfam_build_dir}/new_relnotes.txt ${pfam_build_dir}/old_relnotes.txt

rm -f ${pfam_build_dir}/Pfam-A.seed.gz ${pfam_build_dir}/Pfam-A.seed
curl -o ${pfam_build_dir}/Pfam-A.seed.gz ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.seed.gz
gunzip ${pfam_build_dir}/Pfam-A.seed.gz

JOB_ID=$(sbatch -p hh -t 2-0 -n ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_prepare_input.log" --kill-on-invalid-dep=yes ./pfam_prepare_input.sh)
HH_JOB_ID=$(sbatch -p hh -t 2-0 -n ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_hhblits.log" -d "afterok:$JOB_ID" --kill-on-invalid-dep=yes ./pfam_hhblits_lock.sh)
#HH_JOB_ID=$(sbatch -p hh -t 2-0 -c ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_hhblits.log" -d "afterok:$JOB_ID" --kill-on-invalid-dep=yes ./pfam_hhblits.sh)
SS_JOB_ID=$(sbatch -p hh -t 2-0 -n ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_addss.log" -d "afterok:$HH_JOB_ID" --kill-on-invalid-dep=yes ./pfam_addss.sh)
CS_JOB_ID=$(sbatch -p hh -t 2-0 -c ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_cstranslate.log" -d "afterok:$SS_JOB_ID" --kill-on-invalid-dep=yes ./pfam_cstranslate.sh)
HM_JOB_ID=$(sbatch -p hh --exclude=hh003 -t 2-0 -n ${NCORES} -N 1 --parsable -o "${LOG_DIR}/pfam_hhmake.log" -d "afterok:$SS_JOB_ID" --kill-on-invalid-dep=yes ./pfam_hhmake.sh)

sbatch -p hh -t 2-0 -n 1 -N 1 -o "${LOG_DIR}/pfam_finalize.log" -d "afterok:${HM_JOB_ID}:${CS_JOB_ID}" --kill-on-invalid-dep=yes ./pfam_finalize.sh
