#!/bin/zsh

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/mmeier/jobs/pfam_hhblits.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_hhblits
#BSUB -m hh
#BSUB -w "done(pfam_a3m_prep)"

source paths.sh
source /etc/profile
source $HOME/.zshrc

module use-append $HOME/modulefiles/
module load gcc/4.9.1
module load intel/compiler/64/14.0/2013_sp1.3.174

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m_seed
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

src_database=${uniprot}
database_basename=$(basename ${src_database})
cp -r ${src_database}* ${MYLOCAL}
database=${MYLOCAL}/${database_basename}

hhblits_omp -i ${input} -oa3m ${MYLOCAL}/pfam_a3m -cpu 16 -d ${database} -n 3

ffindex_build -as ${MYLOCAL}/pfam_a3m.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_a3m.opt.ff{data,index} -d ${MYLOCAL}/pfam_a3m.ffdata -i ${MYLOCAL}/pfam_a3m.ffindex
rm -f ${pfam_build_dir}/pfam_a3m.ffdata ${pfam_build_dir}/pfam_a3m.ffindex
mv ${MYLOCAL}/pfam_a3m.opt.ffdata ${pfam_build_dir}/pfam_a3m.ffdata
mv ${MYLOCAL}/pfam_a3m.opt.ffindex ${pfam_build_dir}/pfam_a3m.ffindex
