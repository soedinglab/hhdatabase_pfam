#!/bin/bash
source $HOME/.bashrc
source paths.sh
set -e

mkdir -p "${LOCAL}/${USER}"
MYLOCAL=$(mktemp -d --tmpdir=${LOCAL}/${USER})
trap "if [ -d \"${MYLOCAL}\" ] && [ \"${MYLOCAL}\" != \"/\" ]; then rm -rf -- \"${MYLOCAL}\"; fi" EXIT

src_input="${pfam_build_dir}/pfam_a3m"
input_basename=$(basename ${src_input})
cp ${src_input}.ff* ${MYLOCAL}
input=${MYLOCAL}/${input_basename}

cstranslate -A ${HHLIB}/data/cs219.lib -D ${HHLIB}/data/context_data.lib -x 0.3 -c 4 -f -i ${input} -o ${MYLOCAL}/pfam_cs219 -I a3m

ffindex_build -as ${MYLOCAL}/pfam_cs219.ff{data,index}
rm -f ${pfam_build_dir}/pfam_cs219.ffdata ${pfam_build_dir}/pfam_cs219.ffindex
cp ${MYLOCAL}/pfam_cs219.ffdata ${MYLOCAL}/pfam_cs219.ffindex ${pfam_build_dir}/
