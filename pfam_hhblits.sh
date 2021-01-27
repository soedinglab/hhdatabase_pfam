#!/bin/bash
source paths.sh
source ~/.bashrc

set -e

mkdir -p "${LOCAL}/${USER}"
MYLOCAL=$(mktemp -d --tmpdir=${LOCAL}/${USER})
trap "if [ -d \"${MYLOCAL}\" ] && [ \"${MYLOCAL}\" != \"/\" ]; then rm -rf -- \"${MYLOCAL}\"; fi" EXIT

# copy database to local ssd
db=${uniprot}
db_bn=$(basename $db)
cp ${db}*.ff* ${MYLOCAL}
DB=${MYLOCAL}/${db_bn}

hhblits_omp -i ${pfam_build_dir}/pfam_a3m_seed -oa3m ${MYLOCAL}/pfam_a3m -o /dev/null -cpu ${NCORES} -d "${DB}" -n 3 -v 0
cp -f ${MYLOCAL}/pfam_a3m.ff{data,index} ${pfam_build_dir}
