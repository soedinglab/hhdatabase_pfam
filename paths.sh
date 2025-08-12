#!/bin/bash

export root_dir=/usr/users/jsoedin/git/hhdatabase_pfam
export pfam_build_dir=/cbscratch/${USER}/hhpred_pfam_build
#export uniprot=/cbscratch/${USER}/databases/uniclust30_2018_08/uniclust30_2018_08
#export uniprot=/cbscratch/jsoedin/databases/UniRef30_2020_03/UniRef30_2020_03
export uniprot=/cbscratch/jsoedin/databases/UniRef30_2021_03/UniRef30_2021_03
export PATH="$HOME/git/hh-suite/build/src:$PATH"

export NO_PROXY="localhost,127.0.0.1"
export no_proxy="localhost,127.0.0.1"
export HTTP_PROXY="http://www-cache.gwdg.de:3128"
export http_proxy="http://www-cache.gwdg.de:3128"
export HTTPS_PROXY="https://www-cache.gwdg.de:3128"
export https_proxy="https://www-cache.gwdg.de:3128"
export FTP_PROXY="www-cache.gwdg.de:3128"
export ftp_proxy="www-cache.gwdg.de:3128"
export ALL_PROXY="www-cache.gwdg.de:3128"
export all_proxy="www-cache.gwdg.de:3128"

export LOCAL=/nvme/n00
export NCORES=256
export LOG_DIR=/usr/users/jsoedin/jobs

ulimit -u 65536
