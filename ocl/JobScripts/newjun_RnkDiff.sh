#!/usr/bin/sh

#CCS -N newjun_RnkDiff85_2
#CCS --res=rset=1:ncpus=1:mem=160g
#CCS -t 5h
#CCS -o wdnewjun_RnkDiff85_1.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r


#ncpus=1,
Rscript R/wd_Sn_incHARE_85.R
