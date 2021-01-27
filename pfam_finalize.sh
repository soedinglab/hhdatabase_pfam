#!/bin/bash
source $HOME/.bashrc
source paths.sh
set -ex

pfam_version="$(grep "  RELEASE" ${pfam_build_dir}/old_relnotes.txt | sed "s/RELEASE//" | sed "s/ //g")"
tar_name="pfamA_${pfam_version}.tar.gz"

cd "${pfam_build_dir}"
rm -f pfamA_*.tar.gz

sed -i "s/.a3m//" pfam_a3m.ffindex
sed -i "s/.a3m//" pfam_hhm.ffindex
sed -i "s/.a3m//" pfam_cs219.ffindex

md5sum pfam_hhm.ff* pfam_cs219.ff* pfam_a3m.ff* > pfam.md5sum
tar czvf "${tar_name}" pfam_{a3m,hhm,cs219}.ff{index,data} pfam.md5sum
chmod a+r "${pfam_build_dir}/${tar_name}"

scp "${pfam_build_dir}/${tar_name}" compbiol@login.gwdg.de:/usr/users/compbiol
ssh compbiol@login.gwdg.de "mv /usr/users/compbiol/${tar_name} /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs"
#rm -f ${pfam_lock_file}
