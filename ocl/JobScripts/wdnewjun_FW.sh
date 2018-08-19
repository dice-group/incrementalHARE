#!/usr/bin/sh

#CCS -N wdnewjun_FW10
#CCS --res=rset=1:ncpus=4:mem=120g
#CCS -t 2h
#CCS -o wdnewjunlogFW10.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r

# ncpus=1:mem=120g 12h
Rscript R/wdnewjun_FW10_nc1.R

