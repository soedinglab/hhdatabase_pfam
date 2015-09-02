#!/bin/zsh

source paths.sh

pfam_lock_file=${pfam_dir}/lock_pfam.txt

if [ -e ${pfam_lock_file} ] && kill -0 `cat ${pfam_lock_file}`; then
  echo "already running"
  exit
fi

export $pfam_lock_file

curl -o ${pfam_build_dir}/new_relnotes.txt ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/relnotes.txt
cmp --silent ${pfam_build_dir}/new_relnotes.txt ${pfam_build_dir}/old_relnotes.txt > /dev/null && exit 0
mv -f ${pfam_build_dir}/new_relnotes.txt ${pfam_build_dir}/old_relnotes.txt

pfam_version=$(grep "  RELEASE" ${pfam_build_dir}/old_relnotes.txt | sed "s/RELEASE//" | sed "s/ //g")
export ${pfam_version}

curl -o ${pfam_build_dir}/Pfam-A.seed.gz ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.seed.gz

bsub < pfam_prepare_input.sh

bsub < pfam_hhblits.sh

bsub < pfam_cstranslate.sh

bsub < pfam_cstranslate_old.sh

bsub < pfam_hhmake.sh

bsub < pfam_finalize.sh


