# 27/9/2018
   name="lgd4cnt"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/lgd4cnt/"
loadpath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/lgd4cnt/"

    ni=14; damping=0.85
t0=proc.time()
	print('Loading Sn...')
	print(load(paste0(savepath,"Sn_",name,"_",ni,"_d",100*damping,".RData")))
	##load Ent
    print("Loading E_cnt..")
	con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	E_cnt=as.integer(readLines(con))
	close(con)
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
    #print("Loading Ent..")
    #con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	#Ent = readLines(con)
	#close(con)
	#print("Remove first element..")
	#Ent=Ent[-1]
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=order(previous,decreasing=TRUE)
    print(paste0("cbind...",format(Sys.time(), "%a %b %d %X %Y")))
    Sn_order_hd=Sn_order[1:300000]
    write.csv(file=paste(savepath , "Sn_order_hd_" , name , "_d",100*damping,".csv",sep=''),Sn_order_hd,row.names=FALSE)
	tmp_hd=cbind(Entity=Sn_order_hd,count=E_cnt[Sn_order_hd],Probability=as.vector(previous)[Sn_order_hd])		
	write.csv(file=paste(savepath , "results_resources_id_" , name , "_d",100*damping,"_HARE_hd.csv",sep=''),tmp_hd,row.names=FALSE)
tf=proc.time()
print(tf-t0)
