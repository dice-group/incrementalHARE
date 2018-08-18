# 18/3/2018

name="wd022018"
savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
P1_fn=c("P1_wd022018_30_40","P1_wd022018_70_80","P1_wd022018_90_105")#size 100,000,000

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
print("Adding blocks of FW105P1...")
library(Matrix)
p1_sz=10000000#c(10000000,rep(20000000,3),30000000)#c(50000000,50000000)  #Work around the limit of max nnz(2^31)
P1_sz=100000000
#P2_fn=c("P2_wd022018_30_40","P2_wd022018_70_80","P2_wd022018_90_105")#size 379,414,243
#P1
for(ch in 1:ceiling(P1_sz/p1_sz)){#P1_wd022018_xx_xx
	t1=proc.time()
	index_st = 1 + (ch-1)*p1_sz
	index_end = ch *p1_sz
	print(ch)
	print(load(paste0(savepath,P1_fn[1],".RData")))
	P_ch1=P1[index_st:index_end,]
	rm(P1)
	gc()
	print(paste0("loading:",savepath,P1_fn[2],".RData"))
	print(load(paste0(savepath,P1_fn[2],".RData")))
	t2=proc.time()
	P_ch2=P1[index_st:index_end,]
	rm(P1)
	gc()
	print("Adding ch1,ch2")
	Pch = P_ch1 + P_ch2
	rm(P_ch1)
	rm(P_ch2)
	gc()
	print(paste0("loading:",savepath,P1_fn[3],".RData"))
	print(load(paste0(savepath,P1_fn[3],".RData")))
	P_ch3 = P1[index_st:index_end,]
	print("Adding ch3...")
	Pch = Pch + P_ch3
	rm(P1)
	gc()
	
	print("Saving Pch ...")
	save(file=paste0(savepath,"Pch_",name,"_",ch,".RData"),Pch)
	t3 = proc.time()
	print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, memP_ch1:%.1f,nnz:%d",ch,(t3-t1)[3],
		(t2-t1)[3],object.size(Pch)/(1024*1024),length(Pch@x)))
	rm(P_ch3)
	gc()
}

print("Ok.")