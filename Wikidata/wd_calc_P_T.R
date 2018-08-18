#20/3/2018
# Computes transpose of P: could be done faster by reading Pch to list once but needs more memory.
    # calc_d_P_T 
	name="wd022018"
	savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
	loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"

    Alpha <- 479414243
	# Pch_all <- list()
	tch_sz = c(10000000,10000000,rep(20000000,5),120000000,120000000,119414243)
	for(t_ch in 1:length(tch_sz)){
	    t1 = proc.time()
    	col_st=1
		PTch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(tch_sz[t_ch], Alpha))
		for(ch in 1:14){
		    print(sprintf("t_ch:%d, ch:%d",t_ch,ch))
			# read chunk
			t2 = proc.time()
			print(load(paste0(savepath,"Pch_",name,"_",ch,".RData")))
			t3 = proc.time()
			
			print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d",(t3-t2)[3],object.size(Pch)/(1024*1024),length(Pch@x)))
			index_st  = ifelse(t_ch==1,1,1+sum(tch_sz[1:(t_ch-1)]))
			index_end = sum(tch_sz[1:t_ch])
			tmp=Matrix::t(Pch)
			tt=proc.time()
			print(sprintf("t transpose:%.2f",(tt-t3)[3]))
			tmp=tmp[index_st:index_end,]
			ts1=proc.time()
			print(sprintf("t tmp:%.2f,nnz:%d,mem tmp:%.1f",(ts1-tt)[3],length(tmp@x) ,object.size(tmp)/(1024*1024)))
			# print(str(tmp))
			col_end= col_st + nrow(Pch)-1
			print(sprintf("col_st:%d, col_end:%d",col_st,col_end))
			tmp=methods::as(tmp,'TsparseMatrix')
			newj=tmp@j+col_st#to be from 1 not 0
			tnewj=proc.time()
			print(sprintf("t newj:%.2f, to Tsp...",(tnewj-ts1)[3]))

			tmp=Matrix::sparseMatrix(i=tmp@i+1,j=newj,x=tmp@x,dims=c(tch_sz[t_ch], Alpha))
			# PTch[,col_st:col_end] = tmp
			tnj=proc.time()
			print(sprintf("t newj:%.2f, Adding...",(tnj-tnewj)[3]))
			
			PTch = PTch + tmp
			t4 = proc.time()
			
			print(sprintf("ch:%d, col_st:%d, col_end:%d, time load:%.1f, time all:%.1f, mem PTch:%.1f",ch,col_st,col_end,(t3-t2)[3],(t4-t3)[3],
					object.size(PTch)/(1024*1024)))
			col_st = col_end + 1
			rm(tmp)
			rm(Pch)
			gc()
		}
		#save
		print("Saving PTch ...")
		save(file=paste0(savepath,"PTch_",name,"_",t_ch,".RData"),PTch)
		t5 = proc.time()
		print(sprintf("Chunk:%d, time total:%.3f, time load:%.3f, memP_ch1:%.1f,nnz:%d",t_ch,(t5-t1)[3],
			(t2-t1)[3],object.size(PTch)/(1024*1024),length(PTch@x)))
		rm(PTch)
		gc()
	}

print("Ok.")
