# 6/8/2018

# ce
# extLinks
# HARE d12
# HARE all
# error
# loadpath="/home/AbdelmoneimDesouki/ParseNT/ocl/"
# loadpath="~/abd/ParseNT/"
print("Loading wdjan..")
    con <- file(paste("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wdjan/wd04012018_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
    # ------------
    print("Loading wddelta..")
    con <- file(paste("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wddelta/wd13062018delta_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent_delta = readLines(con)
	close(con)
	Ent_delta=Ent_delta[-1]
    # ------------
    # ------------
    print("Loading wdjun Ent...")
    con <- file(paste("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wdnewjun/wdnewjun_Ent.txt",sep=''), "r", blocking = FALSE)
	Entnj = readLines(con)
	close(con)
	Entnj=Entnj[-1]
    # --------
    # t1=proc.time()
    # ce=intersect(Ent,Ent_delta)
    # t2=proc.time()
    # print(t2-t1)
##--------------
damping=0.85
print(sprintf('damping=%f',damping))
tl0=proc.time()
 nt1= 681596142
 nt2=2416986129

 ext1=686312297
 ext2=5041110266

#P=matrix(0,2,2)
#P[1,1]=(3*nt1)/(3*nt1+ext2 )
#P[1,2]=ext2/(3*nt1+ext2)
#P[2,2]=(3*nt2)/(3*nt2+ext1)
#P[2,1]=ext1/(3*nt2+ext1)

P=matrix(0,2,2)
P[1,1]=(3*nt1-ext1)/(3*nt1 )
P[1,2]=ext1/(3*nt1)
P[2,2]=(3*nt2-ext2)/(3*nt2)
P[2,1]=ext2/(3*nt2)

source('/upb/departments/pc2/users/d/desouki/abd/R/pageRank_loop.R')
res=pageRank_loop(P,damping=damping,epsilon=1e-6)
rG=res$Sn
#rG1=0.2571
#rG=c(rG1,1-rG1)
# savepath="/home/AbdelmoneimDesouki/shared/mats/ocl/"
# savepath="~/abd/mats/"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdnewjun/"

    print(load(paste0("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdjan/","Sn_wd04012018_20_d",damping*100,".RData")))
    Sn_jan=previous
    print(load(paste0("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wddelta/","Sn_wd13062018delta_20_d",damping*100,".RData")))
    Sn_delta=previous
    print(load(paste0("/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdnewjun/","Sn_wdnewjun_20_d",damping*100,".RData")))
    Sn_newjun=previous
    tl=proc.time()
    print(tl-tl0)
 ti0=proc.time()
el=rep(0,length(Entnj))
p1hr=Sn_delta*rG[1]
p2hr=Sn_jan*rG[2]
ix1=match(Ent_delta,Entnj)
ix2=match(Ent,Entnj)
el[ix1]=el[ix1]+p1hr
el[ix2[!is.na(ix2)]]=el[ix2[!is.na(ix2)]]+p2hr[!is.na(ix2)]
ti1=proc.time()
print(ti1-ti0)
### Sn_incnewjun
# Error
SE=(el-Sn_newjun)*(el-Sn_newjun)
rMSE=sqrt(mean(SE))
print(rMSE)
ti2=proc.time()
print(ti2-ti1)
###
rm(Entnj)
rm(Ent)
rm(Ent_delta)
gc()
ti3=proc.time()
print("Calc inc_order ...")
inc_order=order(el,decreasing=TRUE)
newjun_order=order(Sn_newjun,decreasing=TRUE)
avgorderDiff=mean(abs(newjun_order-inc_order))
medorderDiff=median(abs(newjun_order-inc_order))
print(sprintf('rMSE=%11.5e, avgorderDiff=%.3f, medorderDiff=%d',rMSE,avgorderDiff,medorderDiff))
print("Calc inc_rank ...")
incRank=rank(-el,ties.method="min")
newjunRank=rank(-Sn_newjun,ties.method="min")
avgRnkDiff=mean(abs(newjunRank-incRank))
medRnkDiff=median(abs(newjunRank-incRank))
ti4=proc.time()
print(ti4-ti3)
print(sprintf('rMSE=%11.5e, avgRnkDiff=%.3f, medRnkDiff=%d, avgorderDiff=%.3f, medorderDiff=%d',rMSE,avgRnkDiff,medRnkDiff,avgorderDiff,medorderDiff))
print(sprintf('max SE=%11.5e, max incRank=%.2f,max newjunRank=%.2f',max(SE),max(incRank),max(newjunRank)))
save(file=paste0(savepath,"Sn_wd13062018_incHARE_d",damping*100,".RData"),el,SE,incRank,newjunRank)

