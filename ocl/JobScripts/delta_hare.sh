#!/usr/bin/sh

#CCS -N delta_hare85
#CCS --res=rset=1:ncpus=1:mem=120g
#CCS -t 6h
#CCS -o delta_hare85.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r

#ncpus=1,
Rscript R/wddelta_hare_ocl.R
