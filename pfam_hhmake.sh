#!/bin/bash
source $HOME/.bashrc
source paths.sh

set -e

mkdir -p "${LOCAL}/${USER}"
MYLOCAL=$(mktemp -d --tmpdir=${LOCAL}/${USER})
trap "if [ -d \"${MYLOCAL}\" ] && [ \"${MYLOCAL}\" != \"/\" ]; then rm -rf -- \"${MYLOCAL}\"; fi" EXIT

src_input=${pfam_build_dir}/pfam_a3m
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

mpirun -np ${NCORES} ffindex_apply_mpi ${input}.ff{data,index} -d ${MYLOCAL}/pfam_hhm.ffdata -i ${MYLOCAL}/pfam_hhm.ffindex -- hhmake -i stdin -o stdout -v 0

ffindex_build -as ${MYLOCAL}/pfam_hhm.ff{data,index}
rm -f ${pfam_build_dir}/pfam_hhm.ff{data,index}
cp ${MYLOCAL}/pfam_hhm.ff{data,index} ${pfam_build_dir}/
