# 18/3/2018

name="wd13062018"
# savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
# loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
savepath="/home/AbdelmoneimDesouki/mats/nc8/"
loadpath="/home/AbdelmoneimDesouki/wd/nc8/"

    ncores=8
	require(parallel)
	require(doParallel)
	cluster <- makeCluster(ncores)
	registerDoParallel(cluster)

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
print("Adding blocks of FW40...")
library(Matrix)
# p1_sz=80000000  #Work around the limit of max nnz(2^31)
Pind=c(0,1e6*c(30,60,90,120,350))# P2ind=160000000
# for(ch in seq(40,120,40)){
get_chunk_FW40<-function(ch){
	t1=proc.time()
	print(ch)
	print(load(paste0(savepath,"P_",name,"_",ch-30,"_",ch-20,".RData")))
	P_ch1=P
	# p2_sz=nrow(P)-p1_sz
	rm(P)
	gc()
	print(load(paste0(savepath,"P_",name,"_",ch-10,"_",ch,".RData")))
    nnz=NULL
    for(i in 1:length(Pind)){
       P_st=Pind[i]+1
       if(i==length(Pind)){
            P_end=nrow(P)
       }else{
            P_end=Pind[i+1]
       }
        t2=proc.time()
        Pi = P[P_st:P_end,] + P_ch1[P_st:P_end,]
        t3 = proc.time()
        print(sprintf("Chunk:%d,  time FW:%.3f, memPi:%.1f,nnz:%d",ch,
                (t3-t2)[3],object.size(Pi)/(1024*1024), length(Pi@x)))
        print("Saving Pi ...")
        save(file=paste0(savepath,"P",i,"_",name,"_",ch-30,"_",ch,".RData"),Pi)#should be ch-30
        nnz=c(nnz,length(Pi@x))
        rm(Pi)
        gc()
    }
	rm(P)
	rm(P_ch1)
	gc()
    return(cbind(nnz))
}

## to be in 9 parts
t0=proc.time()
		tmp2 <- foreach(i = seq(40,120,40),.packages='Matrix', .combine="rbind") %dopar% {
       # for(i in seq(40,120,40)){
            print(i)
            tmp=get_chunk_FW40(i);
            print(tmp)
        }
    tf=proc.time()
    print(tf-t0)
stopCluster(cluster)



#######
	
    # P1ind=30000000
    # pp=P_ch1[1:P1ind,]
    # pp2=P[1:P1ind,]
    # length(pp@x)+length(pp2@x)
    
    