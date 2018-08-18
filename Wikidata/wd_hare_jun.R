
	# name="sec"
	# savepath="D:\\RDF\\mats\\"
	# loadpath="D:\\RDF\\parseNT\\"
	name="wd13062018"
	savepath="/home/AbdelmoneimDesouki/mats/nc8/pt/"
    loadpath="/home/AbdelmoneimDesouki/wd/nc8/"

# read Pch_all
    Alpha <- 593688915
	tch_sz = c(400000,10e6,rep(20e6,5),120e6,120e6,120e6)
    tch_sz=c(tch_sz,Alpha-sum(tch_sz))
    library(Matrix)
	PTch_all = list()
	NChnks = length(tch_sz)
	mem = 0;
	t0=proc.time()
	for(t_ch in 1:NChnks){
		t1=proc.time()
		print(load(paste0(savepath,"PTch_",name,"_",t_ch,".RData")))
		PTch_all[[t_ch]] = PTch;
		mem = mem + object.size(PTch)
		t2=proc.time()
		print(sprintf("ch:%d, total mem:%.1f, time%.1f",t_ch,mem/(1024*1024),(t2-t1)[3]))
	}
	# load_PTch  10m,110GB
	t2=proc.time()
	print(sprintf("total load time:%.1f",(t2-t0)[3]))
	##-------------------
	## ncores=1
	# foreach()
	epsilon=1e-4; damping=0.85; maxIterations=40;
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
		
		print(sprintf("ni:%d,max index:%d,max:%f,sumSn:%f,error:%f",ni,which.max(as.vector(previous)),max(previous),sum(previous),error));
		# rm(tmp)
		# gc()
	}
	th=proc.time()
    print(th-t0)
	##Save results
	rm(PTch_all)
	gc()
	print('Saving results...')
	save(file=paste0(savepath,"Sn_",name,"_",ni,".RData"),previous)
	con <- file(paste0(savepath,"Sn_",name,"_",ni,".txt"),'w')
	writeLines(as.character(previous),con)
	close(con)
	#Ent, Ent_cnt,prob. sorted by prob.
	##load Ent
	print(load(paste0(loadpath,name,"_E_cnt.RData")))
	E_cnt=E_cnt[-1]
	con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y"))
	Sn_order=order(previous,decreasing=TRUE)
    print(paste0("cbind...",format(Sys.time(), "%a %b %d %X %Y"))
	tmp=cbind(Entity=Ent,count=E_cnt,Probability=as.vector(previous))[Sn_order,]		
	write.csv(file=paste(savepath , "results_resources_" , name , "_HARE_hd.csv",sep=''),tmp[1:10000,],row.names=FALSE)
	write.csv(file=paste(savepath , "results_resources_" , name , "_HARE.txt",sep=''),tmp,row.names=FALSE)
tf=proc.time()
print(tf-t0)


################
 