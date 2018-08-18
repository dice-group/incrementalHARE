# 18/3/2018

name="wd022018"
savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
print("Adding blocks of FW40...")
library(Matrix)
p1_sz=100000000  #Work around the limit of max nnz(2^31)
for(ch in seq(40,80,40)){
	t1=proc.time()
	print(ch)
	print(load(paste0(savepath,"P_",name,"_",ch-30,"_",ch-20,".RData")))
	P_ch1=P
	p2_sz=nrow(P)-p1_sz
	rm(P)
	gc()
	print(load(paste0(savepath,"P_",name,"_",ch-10,"_",ch,".RData")))
	t2=proc.time()
	P1 = P[1:p1_sz,] + P_ch1[1:p1_sz,]
	print("Saving P1 ...")
	save(file=paste0(savepath,"P1_",name,"_",ch-10,"_",ch,".RData"),P1)
	rm(P1)
	gc()
	t3 = proc.time()
	P2 = P[(p1_sz+1):nrow(P),] + P_ch1[(p1_sz+1):nrow(P),]#wrong, should be to nrow(P)
	t4 = proc.time()
	print("Saving P2 ...")
	save(file=paste0(savepath,"P2_",name,"_",ch-10,"_",ch,".RData"),P2)
	t5=proc.time()
	print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, time FW:%.3f, time P:%.3f,memP2:%.1f,memP:%.1f, memP_ch1:%.1f,nnz:%d",ch,(t5-t1)[3],
		(t2-t1)[3],(t3-t2)[3],(t4-t3)[3],object.size(P2)/(1024*1024), object.size(P)/(1024*1024), object.size(P_ch1)/(1024*1024),length(P2@x)))
	rm(P2)
	rm(P)
	rm(P_ch1)
	gc()
}

#######
print("ch: 81 to 105,p2")
print(load(paste0(savepath,"P_",name,"_",90,"_",100,".RData")))
	P_ch1=P
	p2_sz=nrow(P)-p1_sz
	rm(P)
	gc()
	
	print(load(paste0(savepath,"FW_",name,"_",105,".RData")))
	t2=proc.time()
	P1 = P_ch1[1:p1_sz,] + FW[1:p1_sz,]
	print(sprintf("Saving P1, nnz:%d, memP1:%.1f ...",length(P1@x), object.size(P1)/(1024*1024)))
	save(file=paste0(savepath,"P1_",name,"_",90,"_",105,".RData"),P1)
	rm(P1)
	gc()
	
	t3=proc.time()
	P2 = P_ch1[(p1_sz+1):nrow(P_ch1),] + FW[(p1_sz+1):nrow(P_ch1),]
	t4 = proc.time()
	print("Saving P2 ...")
	save(file=paste0(savepath,"P2_",name,"_",90,"_",105,".RData"),P2)
	t5=proc.time()
print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, time FW:%.3f, time P:%.3f,memFW:%.1f,memP2:%.1f",105,(t4-t1)[3],(t2-t1)[3],(t3-t2)[3],
				(t4-t3)[3],object.size(FW)/(1024*1024), object.size(P2)/(1024*1024)))
	