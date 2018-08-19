# 31/7/2018
# read Pch_all
    
	name="wdnewjun"
# savepath="~/abd/mats/"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdnewjun/"
loadpath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wdnewjun/"

Beta=3098582271#length(S)
Alpha=617563887#without the first

tch_sz = 1e5*c(4,15,rep(100,9),80,620,rep(600,7))
    tch_sz=c(tch_sz,Alpha-sum(tch_sz))

    library(Matrix)
	PTch_all = list()
	NChnks = length(tch_sz)
	mem = 0;
	t0=proc.time()
     nnz=0.0
	for(t_ch in 1:NChnks){
		t1=proc.time()
		print(load(paste0(savepath,"PTch_",name,"_",t_ch,".RData")))
		PTch_all[[t_ch]] = PTch;
		mem = mem + object.size(PTch)
		t2=proc.time()
        nnz=nnz+as.numeric(length(PTch@x))
		print(sprintf("ch:%d, total mem:%.1f, time:%.1f",t_ch,mem/(1024*1024),(t2-t1)[3]))
	}
	# load_PTch  10m,110GB
	t2=proc.time()
	print(sprintf("total load time:%.1f, mem:%.2f, nnz:%.0f",(t2-t0)[3],object.size(PTch_all)/(1024*1024),nnz))
    rm(PTch)
    gc()
	##-------------------
	## ncores=1
	# foreach()
	epsilon=1e-4; damping=0.85; maxIterations=200;
	n=Alpha
	previous = ones = rep(1,n)/n
	d_ones = (1-damping)*ones
	error = 1
	 #Equation 9
	tic2 = proc.time()
	ni=0	
	ch_st_ix=tch_sz
	ch_st_ix[1]=1
	for(i in 2:NChnks) ch_st_ix[i] = tch_sz[i-1] + ch_st_ix[i-1];
	print("Calculating HARE...")
	library(Matrix)
	while (error > epsilon && ni < maxIterations){
		ti0=proc.time()
        ni = ni + 1
		tmp = previous
		for(t_ch in 1:NChnks){
			t1=proc.time()
			ch_rng=ch_st_ix[t_ch]:(ch_st_ix[t_ch]+tch_sz[t_ch]-1)
			previous[ch_rng] = as.vector(damping *(PTch_all[[t_ch]] %*% tmp) + d_ones[ch_rng])
		print(sprintf("ni:%d,max index:%d,max:%f,sumSn:%f,error:%f",ni,which.max(as.vector(previous)),max(previous),sum(previous),error));
			t2=proc.time()
			print(sprintf("ni:%d, ch:%d, time:%.1f",ni,t_ch,(t2-t1)[3]))
		}
		error = norm(as.matrix(tmp - previous),"f")
		tif=proc.time()
		print(sprintf("ni:%d,max index:%d,max:%f,sumSn:%f,error:%f, iter time:%.1f",ni,which.max(as.vector(previous)),max(previous),sum(previous),error,(tif-ti0)[3]));
		rm(tmp)
		gc()
	}
	th=proc.time()
    print(th-t0)
	##Save results
	rm(PTch_all)
	gc()
	print('Saving results...')
	save(file=paste0(savepath,"Sn_",name,"_",ni,"_d",100*damping,".RData"),previous)
	##load Ent
    print("Loading E_cnt...")
	con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	E_cnt=as.integer(readLines(con))
	close(con)
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
    print("Loading Ent...")
    con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=order(previous,decreasing=TRUE)
    print(paste0("cbind...",format(Sys.time(), "%a %b %d %X %Y")))
	    Sn_order_hd=Sn_order[1:10000]
	tmp=cbind(Entity=Ent[Sn_order_hd],count=E_cnt[Sn_order_hd],Probability=as.vector(previous)[Sn_order_hd])		
	write.csv(file=paste(savepath , "results_resources_" , name , "_d",100*damping,"_HARE_hd.csv",sep=''),tmp,row.names=FALSE)

    # tmp=cbind(Entity=Ent,count=E_cnt,Probability=as.vector(previous))[Sn_order,]		
	# write.csv(file=paste(savepath , "results_resources_" , name , "_HARE_hd.csv",sep=''),tmp[1:10000,],row.names=FALSE)
	# write.csv(file=paste(savepath , "results_resources_" , name , "_HARE.txt",sep=''),tmp,row.names=FALSE)
tf=proc.time()
print(tf-t0)


################
 