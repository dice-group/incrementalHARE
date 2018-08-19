# 1/8/2018
    name="wdnewjun"

    savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdnewjun/"
    loadpath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wdnewjun/"
    #ni=26; damping=0.90
ni=57; damping=0.99
t0=proc.time()
	print('Loading Sn...')
	print(load(paste0(savepath,"Sn_",name,"_",ni,"_d",100*damping,".RData")))
	##load Ent
    print("Loading E_cnt..")
	con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	E_cnt=as.integer(readLines(con))
	close(con)
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
    print("Loading Ent..")
    con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=order(previous,decreasing=TRUE)
    print(paste0("cbind...",format(Sys.time(), "%a %b %d %X %Y")))
    Sn_order_hd=Sn_order[1:10000]
	tmp_hd=cbind(Entity=Ent[Sn_order_hd],count=E_cnt[Sn_order_hd],Probability=as.vector(previous)[Sn_order_hd])		
	write.csv(file=paste(savepath , "results_resources_" , name , "_d",100*damping,"_HARE_hd.csv",sep=''),tmp_hd,row.names=FALSE)

	# write.csv(file=paste(savepath , "results_resources_" , name , "_HARE.txt",sep=''),tmp,row.names=FALSE)
tf=proc.time()
print(tf-t0)
