#!/bin/bash
source $HOME/.bashrc
source paths.sh
set -e

mkdir -p "${LOCAL}/${USER}"
MYLOCAL=$(mktemp -d --tmpdir=${LOCAL}/${USER})
trap "if [ -d \"${MYLOCAL}\" ] && [ \"${MYLOCAL}\" != \"/\" ]; then rm -rf -- \"${MYLOCAL}\"; fi" EXIT

python2 "${root_dir}/deconcatenate_seed.py" -i "${pfam_build_dir}/Pfam-A.seed" -o "${MYLOCAL}"

mkdir -p "${MYLOCAL}/a3m"
for f in ${MYLOCAL}/*.sto
do
  bn="$(basename "$f" .sto)"
  reformat.pl sto a3m "$f" "${MYLOCAL}/a3m/$bn.a3m" -noss
  python2 "${root_dir}/add_annotation_line.py" "${MYLOCAL}/a3m/$bn.a3m" "${MYLOCAL}/$bn.sto"
done

rm -f "${pfam_build_dir}/pfam_a3m_seed.ffdata" "${pfam_build_dir}/pfam_a3m_seed.ffindex"
(cd "${MYLOCAL}/a3m"; ffindex_build -as "${pfam_build_dir}/pfam_a3m_seed.ffdata" "${pfam_build_dir}/pfam_a3m_seed.ffindex" .)
