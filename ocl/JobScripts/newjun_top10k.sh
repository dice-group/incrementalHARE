#!/usr/bin/sh

#CCS -N newjun_top10k99
#CCS --res=rset=1:ncpus=1:mem=120g
#CCS -t 2h
#CCS -o wdnewjun_top10k99.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r


#ncpus=1,
Rscript R/calc_top_10k.R
