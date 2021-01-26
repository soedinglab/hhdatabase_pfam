#!/bin/bash
#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 160
#BSUB -a openmpi
#BSUB -o /usr/users/jsoedin/jobs/pfam_hhblits.log
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_hhblits
#BSUB -m hh
#BSUB -w "done(pfam_a3m_prep)"

source /etc/profile
source $HOME/.bashrc
source paths.sh

rm -f ${pfam_build_dir}/pfam_a3m_without_ss.ffdata ${pfam_build_dir}/pfam_a3m_without_ss.ffindex
#mpirun -np 160 ffindex_apply_mpi ${pfam_build_dir}/pfam_a3m_seed.ff{data,index} -i ${pfam_build_dir}/pfam_a3m_without_ss.ffindex -d ${pfam_build_dir}/pfam_a3m_without_ss.ffdata -- hhblits -i stdin -oa3m stdout -o /dev/null -cpu 1 -d ${uniprot} -n 3 -v 0
hhblits_omp -i ${pfam_build_dir}/pfam_a3m_seed -oa3m ${pfam_build_dir}/pfam_a3m_without_ss -cpu $(nproc --all) -d ${uniprot} -n 3 -v 0

