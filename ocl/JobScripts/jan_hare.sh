#!/usr/bin/sh

#CCS -N jan_hare85
#CCS --res=rset=1:ncpus=1:mem=250g
#CCS -t 6h
#CCS -o wdjan_hare85.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r


#ncpus=1,
Rscript R/wdjan_hare_ocl.R
