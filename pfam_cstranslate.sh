#!/bin/zsh

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/mmeier/jobs/pfam_cstranslate.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_cstranslate
#BSUB -m hh
#BSUB -w "done(pfam_hhblits)"

source paths.sh
source /etc/profile
source $HOME/.zshrc

module use-append $HOME/modulefiles/
module load intel/compiler/64/15.0/2015.3.187
module load openmpi/intel/64/1.8.5

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

cstranslate -A ${HHLIB}/data/cs219.lib -D ${HHLIB}/data/context_data.lib -x 0.3 -c 4 -i ${input} -o ${MYLOCAL}/pfam_cs219 -I a3m -b --ffindex

ffindex_build -as ${MYLOCAL}/pfam_cs219.ff{data,index}
ffindex_build -as ${MYLOCAL}/pfam_cs219.opt.ff{data,index} -d ${MYLOCAL}/pfam_cs219.ffdata -i ${MYLOCAL}/pfam_cs219.ffindex
rm -f ${pfam_build_dir}/pfam_cs219.ffdata ${pfam_build_dir}/pfam_cs219.ffindex
mv ${MYLOCAL}/pfam_cs219.opt.ffdata ${pfam_build_dir}/pfam_cs219.ffdata
mv ${MYLOCAL}/pfam_cs219.opt.ffindex ${pfam_build_dir}/pfam_cs219.ffindex
