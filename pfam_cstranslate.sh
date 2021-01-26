#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pfam_cstranslate.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_cstranslate
#BSUB -m hh
#BSUB -w "done(pfam_hhblits)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})
OMP_NUM_THREADS=$(nproc --all) cstranslate -b -x 0.3 -c 4 -i ${pfam_build_dir}/pfam_a3m_without_ss -o ${MYLOCAL}/pfam_cs219 -I a3m --ffindex

ffindex_build -as ${MYLOCAL}/pfam_cs219.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_cs219.opt.ff{data,index} -d ${MYLOCAL}/pfam_cs219.ffdata -i ${MYLOCAL}/pfam_cs219.ffindex
rm -f ${pfam_build_dir}/pfam_cs219.ffdata ${pfam_build_dir}/pfam_cs219.ffindex
mv ${MYLOCAL}/pfam_cs219.opt.ffdata ${pfam_build_dir}/pfam_cs219.ffdata
mv ${MYLOCAL}/pfam_cs219.opt.ffindex ${pfam_build_dir}/pfam_cs219.ffindex
