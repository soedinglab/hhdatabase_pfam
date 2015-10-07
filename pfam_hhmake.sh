#!/bin/zsh

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 1
#BSUB -a openmp
#BSUB -o /usr/users/mmeier/jobs/pfam_hhmake.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_hhmake
#BSUB -m hh
#BSUB -w "done(pfam_hhblits)"

source paths.sh
source /etc/profile
source $HOME/.zshrc

module use-append $HOME/modulefiles/
module load intel/compiler/64/15.0/2015.3.187
module load openmpi/intel/64/1.8.5
module load python/3.5.0

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

echo "calculate hhm"
mpirun -np 1 ffindex_apply_mpi ${input}.ffdata ${input}.ffindex -i ${MYLOCAL}/pfam_hhm.ffindex -d ${MYLOCAL}/pfam_hhm.ffdata -- hhmake -i stdin -o stdout -v 0

echo "optimization"
ffindex_build -as ${MYLOCAL}/pfam_hhm.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_hhm.opt.ff{data,index} -d ${MYLOCAL}/pfam_hhm.ffdata -i ${MYLOCAL}/pfam_hhm.ffindex
rm -f ${pfam_build_dir}/pfam_hhm.ffdata ${pfam_build_dir}/pfam_hhm.ffindex
mv ${MYLOCAL}/pfam_hhm.opt.ffdata ${pfam_build_dir}/pfam_hhm.ffdata
mv ${MYLOCAL}/pfam_hhm.opt.ffindex ${pfam_build_dir}/pfam_hhm.ffindex
