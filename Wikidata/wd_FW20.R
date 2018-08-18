# 18/3/2018

name="wd022018"
savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
print("Adding blocks of FW...")
library(Matrix)
for(ch in seq(40,100,20)){
	t1=proc.time()
	print(ch)
	print(load(paste0(savepath,"FW_",name,"_",ch-10,".RData")))
	P = FW
	rm(FW)
	gc()
	print(load(paste0(savepath,"FW_",name,"_",ch,".RData")))
	t2=proc.time()
	P = P + FW
	t3=proc.time()
	print("Saving ...")
	save(file=paste0(savepath,"P_",name,"_",ch-10,"_",ch,".RData"),P)
	t4=proc.time()
	print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, time FW:%.3f, time P:%.3f,memFW:%.1f,memP:%.1f",ch,(t4-t1)[3],(t2-t1)[3],(t3-t2)[3],
				(t4-t3)[3],object.size(FW)/(1024*1024), object.size(P)/(1024*1024)))
	rm(FW)
	rm(P)
	gc()
}
