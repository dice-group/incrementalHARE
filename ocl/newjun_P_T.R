#31/7/2018
# Computes transpose of P: could be done faster by reading Pch to list once but needs more memory.
    # calc_d_P_T 
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
## Dimension of Pi is different, dim of FW is Alpha x Alpha

    # ncores=8
	# require(parallel)
	# require(doParallel)
	# cluster <- makeCluster(ncores,outfile="")
	# registerDoParallel(cluster)

    NPch <-length(ch_sz)
    print('reading P to memory')
	Pch_all <- list()
    t1=proc.time()
    nnz=0.0
    for(ch in 1:NPch){
		    print(sprintf("ch:%d",ch))
			# read chunk
			t2 = proc.time()
			print(load(paste0(savepath,"Pch_",name,"_",ch,".RData")))
			t3 = proc.time()
			Pch_all[[ch]]<-P_ch
            nnz=nnz+as.numeric(length(P_ch@x))
			print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d",(t3-t2)[3],object.size(P_ch)/(1024*1024),sum(P_ch@x>0)))
    }
    print(sprintf("time load:%.3f, memP_ch1:%.1f, nnz:%.1f",(proc.time()-t1)[3],object.size(Pch_all)/(1024*1024),nnz))
    
	tch_sz = 1e5*c(4,15,rep(100,9),80,620,rep(600,7))
    tch_sz=c(tch_sz,Alpha-sum(tch_sz))
	# for(t_ch in 1:length(tch_sz)){
    get_chunk_PT<-function(t_ch){
	    t1 = proc.time()
    	col_st=1
		PTch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(tch_sz[t_ch], Alpha))
		for(ch in 1:NPch){
		    print(sprintf("t_ch:%d, ch:%d",t_ch,ch))
			# read chunk
			# t2 = proc.time()
			# print(load(paste0(savepath,"Pch_",name,"_",ch,".RData")))
			t3 = proc.time()
			
			# print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d",(t3-t2)[3],object.size(Pch)/(1024*1024),length(Pch@x)))
			index_st  = ifelse(t_ch==1,1,1+sum(tch_sz[1:(t_ch-1)]))
			index_end = sum(tch_sz[1:t_ch])
			tmp=Matrix::t(Pch_all[[ch]])
			tt=proc.time()
			print(sprintf("t transpose:%.2f",(tt-t3)[3]))
			tmp=tmp[index_st:index_end,]
			ts1=proc.time()
			print(sprintf("t tmp:%.2f,nnz:%d,mem tmp:%.1f",(ts1-tt)[3],length(tmp@x) ,object.size(tmp)/(1024*1024)))
			# print(str(tmp))
            col_end= col_st + nrow(Pch_all[[ch]])-1
            print(sprintf("col_st:%d, col_end:%d",col_st,col_end))
            if(length(tmp@x)>0){
                tmp=methods::as(tmp,'TsparseMatrix')
                newj=tmp@j+col_st#to be from 1 not 0
                tnewj=proc.time()
                print(sprintf("t newj:%.2f,max tmp@i=%d, tch_sz=%d to Tsp...",(tnewj-ts1)[3],max(tmp@i),tch_sz[t_ch]))

                tmp=Matrix::sparseMatrix(i=tmp@i+1,j=newj,x=tmp@x,dims=c(tch_sz[t_ch], Alpha))
                # PTch[,col_st:col_end] = tmp
                tnj=proc.time()
                print(sprintf("t newj:%.2f, Adding...",(tnj-tnewj)[3]))
                
                PTch = PTch + tmp
                t4 = proc.time()
                
                print(sprintf("ch:%d, col_st:%d, col_end:%d,  time all:%.1f, mem PTch:%.1f",ch,col_st,col_end,(t4-t3)[3],
                        object.size(PTch)/(1024*1024)))
            }
			col_st = col_end + 1
			rm(tmp)
			gc()
		}
		#save
		print("=================Saving PTch ...")
		save(file=paste0(savepath,"PTch_",name,"_",t_ch,".RData"),PTch)
		t5 = proc.time()
		print(sprintf("Chunk:%d, time total:%.1f, memP_ch1:%.1f,nnz:%d",t_ch,(t5-t1)[3],
			object.size(PTch)/(1024*1024),length(PTch@x)))
        nnz=length(PTch@x)
		rm(PTch)
		gc()
        return(nnz)
	}
    
    t0=proc.time()
    nnz2=NULL
		# tmp2 <- foreach(i = 1:length(tch_sz),.packages='Matrix', .combine="rbind") %dopar% {
       for(i in 12:16){#length(tch_sz)
     # i=1
        print(i)
            tmp=get_chunk_PT(i);
            nnz2=rbind(nnz2,tmp)
            print(tmp)
        }
    tf=proc.time()
    print(tf-t0)
# stopCluster(cluster)

print("Ok.")
