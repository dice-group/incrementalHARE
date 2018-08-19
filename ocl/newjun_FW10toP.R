
# 13/7/2018

name="wdnewjun"
# savepath="~/abd/mats/"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdnewjun/"

Beta=3098582271#length(S)
Alpha=617563887#without the first
ch_sz=1e5*c(5,15,rep(100,10),rep(600,8))
    ch_sz=c(ch_sz,Alpha-sum(ch_sz))
chnkLen=25000000
NChnks=as.integer(ceiling(Beta/chnkLen))
NCH=10
library(Matrix)
print('Reading FW to memory...')
	FW_all <- list()
    t1=proc.time()
    nnz=NULL
    mx=NULL
    for(ch in 1:ceiling(NChnks/NCH)){
		    print(sprintf("ch:%d",ch))
			# read chunk
			t2 = proc.time()
			print(load(paste0(savepath,"FW_",name,"_",min(NCH*ch,NChnks),".RData")))
			t3 = proc.time()
			FW_all[[ch]]<-FW
            nnz=rbind(nnz,sum(FW@x>0))
            mx=rbind(mx,max(FW@x))
			print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d",(t3-t2)[3],object.size(FW)/(1024*1024),sum(FW@x>0)))
    }
    tl=(proc.time()-t1)[3]
    print(sprintf("Time to load:%.1f sec,FW_all Memory:%.2f MB",tl,object.size(FW_all)/(1024*1024)))
rm(FW)
gc()    
    ###-------------------
    t0=proc.time()
    for(i in 12:length(ch_sz)){#12
        i_st=1+ifelse(i==1,0,sum(ch_sz[1:(i-1)]))
        i_end=sum(ch_sz[1:i])
        t1=proc.time()
        P_ch=FW_all[[1]][i_st:i_end,]
        for(j in 2:length(FW_all)){
            print(sprintf(" adding FW: %d, size Pch:%.1f MB",j,object.size(P_ch)/(1024*1024)))
            P_ch=P_ch+FW_all[[j]][i_st:i_end,]
            gc()
        }
        
        print(paste0("Saving Pch ...",i," nnz:",sum(P_ch@x>0)))
        save(file=paste0(savepath,"Pch_",name,"_",i,".RData"),P_ch)
rm(P_ch)
gc()
	t2=proc.time()
	print(sprintf("Pch:%d, time:%.2f",i,(t2-t1)[3]))
    }
    tf=proc.time()
print(sprintf("time loading:%.2f, time addinf:%.2f, total:%.2f",tl,(tf-t0)[3],tl+(tf-t0)[3]))
print('Ok.')

