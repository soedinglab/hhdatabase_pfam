#!/bin/zsh

#BSUB -q mpi
#BSUB -W 47:50
#BSUB -n 1
#BSUB -a openmp
#BSUB -o /usr/users/mmeier/jobs/pfam_a3m_prep.log
#BSUB -R "span[hosts=1]"
#BSUB -R np16
#BSUB -R haswell
#BSUB -R cbscratch
#BSUB -J pfam_a3m_prep
#BSUB -m hh

source paths.sh
source /etc/profile
source $HOME/.zshrc

module use-append $HOME/modulefiles/
module load gcc/4.9.1
module load intel/compiler/64/14.0/2013_sp1.3.174

rm -f ${pfam_build_dir}/Pfam-A.seed
gunzip ${pfam_build_dir}/Pfam-A.seed.gz

mkdir -p /local/${USER}
tmp_dir=$(mktemp -d --tmpdir=/local/${USER})
python2.6 ./deconcatenate_seed.py -i ${pfam_build_dir}/Pfam-A.seed -o ${tmp_dir}

for f in ${tmp_dir}/*.sto
do
  bn=$(basename $f .sto)
  reformat.pl sto a3m $f ${tmp_dir}/$bn.a3m -noss
  ${root_dir}/add_annotation_line.py ${tmp_dir}/$bn.a3m ${tmp_dir}/$bn.sto
done

rm -f ${pfam_build_dir}/pfam_a3m_seed.ff{data,index}
cd ${tmp_dir}
ffindex_build -as ${pfam_build_dir}/pfam_a3m_seed.ff{data,index} *.a3m

cd ${pfam_build_dir}
rm -rf ${tmp_dir}