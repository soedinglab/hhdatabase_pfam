#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pfam_hhmake.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_hhmake
#BSUB -m hh
#BSUB -w "done(pfam_addss)"

source /etc/profile
source $HOME/.bashrc
source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

mpirun -np 16 ffindex_apply_mpi ${input}.ffdata ${input}.ffindex -i ${MYLOCAL}/pfam_hhm.ffindex -d ${MYLOCAL}/pfam_hhm.ffdata -- hhmake -i stdin -o stdout -v 0

echo "optimization"
ffindex_build -as ${MYLOCAL}/pfam_hhm.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_hhm.opt.ff{data,index} -d ${MYLOCAL}/pfam_hhm.ffdata -i ${MYLOCAL}/pfam_hhm.ffindex
rm -f ${pfam_build_dir}/pfam_hhm.ffdata ${pfam_build_dir}/pfam_hhm.ffindex
mv ${MYLOCAL}/pfam_hhm.opt.ffdata ${pfam_build_dir}/pfam_hhm.ffdata
mv ${MYLOCAL}/pfam_hhm.opt.ffindex ${pfam_build_dir}/pfam_hhm.ffindex
