#!/bin/bash

source /etc/profile
source ~/.bashrc

source paths.sh

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

rm -f ${pfam_build_dir}/Pfam-A.seed.gz
curl -o ${pfam_build_dir}/Pfam-A.seed.gz ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.seed.gz

bsub < pfam_prepare_input.sh

bsub < pfam_hhblits.sh

bsub < pfam_cstranslate.sh

bsub < pfam_cstranslate_old.sh

bsub < pfam_hhmake.sh

bsub < pfam_finalize.sh


