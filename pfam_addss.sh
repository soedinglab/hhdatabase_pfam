#!/bin/bash
#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pfam_addss.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_addss
#BSUB -m hh
##SUB -w "done(pfam_hhblits)"

source /etc/profile
source $HOME/.bashrc
source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m_without_ss
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

mpirun -np 16 ffindex_apply_mpi ${input}.ff{data,index} -d ${MYLOCAL}/pfam_a3m.ffdata -i ${MYLOCAL}/pfam_a3m.ffindex -- ${HHLIB}/scripts/addss.pl stdin stdout -v 0

ffindex_build -as ${MYLOCAL}/pfam_a3m.ff{data,index}
rm -f ${pfam_build_dir}/pfam_a3m.ff{data,index}
cp ${MYLOCAL}/pfam_a3m.ff{data,index} ${pfam_build_dir}/

