# 25/6/2018

name="wd13062018"
# savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
# loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
savepath="/home/AbdelmoneimDesouki/mats/nc16/"
loadpath="/home/AbdelmoneimDesouki/wd/nc16/"

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
    ncores=8
	require(parallel)
	require(doParallel)
	cluster <- makeCluster(ncores)
	registerDoParallel(cluster)

print("Adding blocks of FW...")
library(Matrix)
# for(ch in seq(20,120,20)){
get_chunk_FW20<-function(ch){
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
	nnz=length(P@x)
    rm(FW)
	rm(P)
	gc()
    return(nnz)
}

    t0=proc.time()
		tmp2 <- foreach(i = seq(20,120,20),.packages='Matrix', .combine="c") %dopar% {
       # for(i in seq(20,120,20)){
            print(i)
            tmp=get_chunk_FW20(i);
            print(tmp)
        }
    tf=proc.time()
    print(tf-t0)
stopCluster(cluster)
