#!/bin/bash
#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 1
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pfam_finalize.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_finalize
#BSUB -m hh
#BSUB -w "done(pfam_hhmake) && done(pfam_cstranslate)"

source /etc/profile
source $HOME/.bashrc
set -ex
source paths.sh

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

exit 0
#ssh compbiol@login.gwdg.de "mv -f /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs/pfamA*.tgz /usr/users/a/soeding"
scp "${pfam_build_dir}/${tar_name}" compbiol@login.gwdg.de:/usr/users/compbiol
ssh compbiol@login.gwdg.de "mv /usr/users/compbiol/${tar_name} /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs"
#ssh compbiol@login.gwdg.de "ln -fs /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs/${tar_name} /usr/users/compbiol/current_pfamA.tgz"

#rm -f ${pfam_build_dir}/${tar_name}
#rm -f ${pfam_lock_file}
