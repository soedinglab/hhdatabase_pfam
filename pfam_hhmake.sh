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
module load gcc/4.9.1
module load openmpi/1.8.7
module load intel/compiler/64/14.0/2013_sp1.3.174
module load python/3.4.2

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

echo "get huge a3m"
ffindex_apply_mpi ${input}.ff{data,index} -- python3.4 ${HHLIB}/scripts/is_huge_a3m.py stdin 50 > ${MYLOCAL}/huge.dat
echo "cat processing"
cat ${MYLOCAL}/huge.dat | grep "0$" | cut -f1,2,3 > ${MYLOCAL}/is_huge.ffindex
echo "calculate hhm"
mpirun -np 1 ffindex_apply_mpi ${input}.ffdata ${MYLOCAL}/is_huge.ffindex -i ${MYLOCAL}/pfam_hhm.ffindex -d ${MYLOCAL}/pfam_hhm.ffdata -- hhmake -i stdin -o stdout

echo "optimization"
ffindex_build -as ${MYLOCAL}/pfam_hhm.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_hhm.opt.ff{data,index} -d ${MYLOCAL}/pfam_hhm.ffdata -i ${MYLOCAL}/pfam_hhm.ffindex
rm -f ${pfam_build_dir}/pfam_hhm.ffdata ${pfam_build_dir}/pfam_hhm.ffindex
mv ${MYLOCAL}/pfam_hhm.opt.ffdata ${pfam_build_dir}/pfam_hhm.ffdata
mv ${MYLOCAL}/pfam_hhm.opt.ffindex ${pfam_build_dir}/pfam_hhm.ffindex
