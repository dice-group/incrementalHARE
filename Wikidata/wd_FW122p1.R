# 27/6/2018

name="wd13062018"
savepath="/home/AbdelmoneimDesouki/mats/nc8/"
loadpath="/home/AbdelmoneimDesouki/wd/nc8/"
## Dimension of Pi is different, dim of FW is Alpha x Alpha

    ncores=8
	require(parallel)
	require(doParallel)
	cluster <- makeCluster(ncores)
	registerDoParallel(cluster)

#print(load(paste0(savepath,"P_",name,"_",20,".RData")))
print("Adding blocks of FW122...")
library(Matrix)
Pind=c(0,1e6*c(30,60,90,120,350))
nPch=3
# nPch1=1e5*c(5,95,200)
# nPch1=1e6*c(10,10,10)
# nPch1=1e6*c(10,100,120)#5
nPch1=c(90e6,90e6,593688915-180e6-350e6)#6 593688915
#each part to 5

print(load(paste0(savepath,"FW_",name,"_",122,".RData")))

get_chunk_P<-function(ch){#1 to 6
# for(ch in 1:length(Pchind)){#P1_wd13062018_xx_xx
    Pi_all<-list()
    for(prv_ch in c(40,80,120)){
        # for(i in 1:length(Pind)){
            t2 = proc.time()
            print(load(paste0(savepath,"P",ch,"_",name,"_",prv_ch-30,"_",prv_ch,".RData")))
            # Pch=Pch + Pi[Pi_st:Pi_end,,drop=FALSE]
            Pi_all[[prv_ch]]=Pi
            # i=i+1
            print(sprintf('prv_ch:%d, nnz:%d, time:%.1f',prv_ch,length(Pi@x),(proc.time()-t2)[3]))
        # }
    }

    t1 = proc.time()
    nnz=NULL
    for(j in 1:nPch){# divide each Pi into nPch new (last) chunks
        ix=(ch-1)*nPch+j
            
        # if(ch==length(Pind)){
            # FW_st=Pind[ch]+1+(j-1)*(nrow(FW)-Pind[ch])/nPch
            # FW_end=Pind[ch]+j*(nrow(FW)-Pind[ch])/nPch
          # }else{
            # FW_st=Pind[ch]+1+(j-1)*(Pind[ch+1]-Pind[ch])/nPch
            # FW_end=Pind[ch]+j*(Pind[ch+1]-Pind[ch])/nPch
        # }
        if(j==1){
            FW_st=Pind[ch]+1
            FW_end=Pind[ch]+nPch1[j]
        }else{
            FW_st=Pind[ch]+1+sum(nPch1[1:(j-1)])
            FW_end=Pind[ch]+sum(nPch1[1:j])
        }
        Pi_st=FW_st-Pind[ch]  
        Pi_end=FW_end-Pind[ch]  
        Pch=FW[FW_st:FW_end,,drop=FALSE]
        print(sprintf("FW_st:%d,FW_end:%d,Pi_st:%d,Pi_end:%d,nnz:%d",FW_st,FW_end,Pi_st,Pi_end,length(Pch@x)))
        for(prv_ch in c(40,80,120)){
            # for(i in 1:length(Pind)){
                t2 = proc.time()
                # print(load(paste0(savepath,"P",ch,"_",name,"_",prv_ch-30,"_",prv_ch,".RData")))
                Pch=Pch + Pi_all[[prv_ch]][Pi_st:Pi_end,,drop=FALSE]
                print(sprintf('prv_ch:%d, nnz:%d, time:%.1f',prv_ch,length(Pch@x),(proc.time()-t2)[3]))
            # }
        }
	
        print(sprintf("Saving Pch:%d ...",ix))
        save(file=paste0(savepath,"Pch_",name,"_",ix,".RData"),Pch)
        t3 = proc.time()
        nnz=rbind(nnz,length(Pch@x))
        print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, memP_ch1:%.1f,nnz:%d",ch,(t3-t1)[3],
            (t2-t1)[3],object.size(Pch)/(1024*1024),length(Pch@x)))
    }
    return(nnz)
}


t0=proc.time()
		# tmp2 <- foreach(i = 1:length(Pind),.packages='Matrix', .combine="rbind") %dopar% {
       # for(i in 1:length(Pind)){
     i=6
        print(i)
            tmp=get_chunk_P(i);
            print(tmp)
        # }
    tf=proc.time()
    print(tf-t0)
stopCluster(cluster)

print("Ok.")
