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

source paths.sh


pfam_version=$(grep "  RELEASE" ${pfam_build_dir}/old_relnotes.txt | sed "s/RELEASE//" | sed "s/ //g")


cd ${pfam_build_dir}

rm -f pfamA_*.tgz

tar_name=pfamA_${pfam_version}.tgz

rm -f pfam.cs219.sizes pfam_hhm_db.index pfam_a3m_db.index
nr_proteins=$(wc -l pfam_cs219.ffindex | cut -f1 -d" ")
nr_aa=$(cut -f3 pfam_cs219.ffindex | awk '{x+=$0}END{print x}')
echo "${nr_proteins} ${nr_aa}" > pfam.cs219.sizes

ln -sf pfam_hhm.ffdata pfam_hhm_db
sed "s/.a3m/.hhm/" pfam_hhm.ffindex > pfam_hhm_db.index

ln -sf pfam_a3m.ffdata pfam_a3m_db
cp pfam_a3m.ffindex pfam_a3m_db.index

md5sum pfam_hhm.ff* pfam_cs219.ff* pfam_a3m.ff* pfam_a3m_db.index pfam_hhm_db.index > md5sum

tar -zcvf pfamA_${pfam_version}.tgz pfam_hhm_db* pfam_hhm.ff* pfam_cs219.ff* pfam_a3m_db* pfam_a3m.ff* pfam.cs219 pfam.cs219.sizes md5sum
chmod og+r ${pfam_build_dir}/${tar_name}

ssh compbiol@login.gwdg.de "rm -f /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs/pfamA*.tgz"
scp ${pfam_build_dir}/${tar_name} compbiol@login.gwdg.de:/usr/users/compbiol
ssh compbiol@login.gwdg.de "mv /usr/users/compbiol/${tar_name} /usr/users/compbiol/www/data/hhsuite/databases/hhsuite_dbs"

rm -f ${pfam_build_dir}/${tar_name}
rm -f ${pfam_lock_file}
