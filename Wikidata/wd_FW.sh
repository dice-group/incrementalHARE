#!/usr/bin/sh

#CCS -N WikiData_P_T
#CCS --res=rset=1:ncpus=1:mem=190g
#CCS -t 3h
#CCS -o wdlogFW.txt
#CCS -M desouki@mail.uni-paderborn.de
## specify when to send email: begin , abort,end
#CCS -meab

cd /upb/departments/pc2/users/d/desouki/abd

cat $CCS_NODEFILE

module add r

# ncpus=4:mem=100g
#Rscript wikidata_FW.R

#120g
#Rscript wd_FW20.R


#180g
#Rscript wd_FW40.R
#Rscript wd_FW40p2.R

#Rscript wd_FW105p1.R
#Rscript wd_FW105p2.R

#Rscript wd_calc_P_T.R

#150, actual main object: 110GB
#Rscript test_hare_ch.R

##190G, 3h
#Rscript wd_hare.R

Rscript wd_hare_res.R