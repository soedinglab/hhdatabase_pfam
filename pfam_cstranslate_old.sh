#!/bin/bash

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 16
#BSUB -a openmp
#BSUB -o /usr/users/jsoedin/jobs/pfam_cstranslate_old.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J jsoedin_cstranslate_old
#BSUB -m hh
#BSUB -w "done(pfam_hhblits)"

source /etc/profile
source $HOME/.bashrc

source paths.sh

mkdir -p /local/${USER}
MYLOCAL=$(mktemp -d --tmpdir=/local/${USER})

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

cstranslate -A ${HHLIB}/data/cs219.lib -D ${HHLIB}/data/context_data.lib -x 0.3 -c 4 -i ${input} -o ${MYLOCAL}/pfam_cs219_old -I a3m --ffindex
sed "s/\x0//" ${MYLOCAL}/pfam_cs219_old.ffdata > ${MYLOCAL}/pfam.cs219

nr_proteins=$(wc -l ${MYLOCAL}/pfam_cs219_old.ffindex)
nr_aa=$(cut -f3 ${MYLOCAL}/pfam_cs219_old.ffindex | awk '{x+=$0}END{print x}')
echo "${nr_proteins} ${nr_aa}" > ${MYLOCAL}/pfam.cs219.sizes

rm -f ${pfam_build_dir}/pfam.cs219
mv ${MYLOCAL}/pfam.cs219 ${pfam_build_dir}/pfam.cs219
