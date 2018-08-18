
name="wd022018"
	savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
	loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
ni=9
hd_sz=10000

	print('Saving results...')
	print(load(paste0(savepath,"Sn_",name,"_",ni,".RData")))#previous
	#Ent, Ent_cnt,prob. sorted by prob.
	##load Ent
	print(load(paste0(loadpath,name,"_E_cnt.RData")))
	E_cnt=E_cnt[-1]
	con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
	
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=order(previous,decreasing=TRUE)
    print(paste0("hd_order...",format(Sys.time(), "%a %b %d %X %Y")))
	hd_order=Sn_order[1:hd_sz]
	tmp_hd=cbind(Entity=Ent[hd_order],count=E_cnt[hd_order],Probability=as.vector(previous)[hd_order])
	print(paste0("Saving head:",hd_sz," ",format(Sys.time(), "%a %b %d %X %Y")))
	write.csv(file=paste(savepath , "results_resources_" , name , "_HARE_hd.csv",sep=''),tmp_hd,row.names=FALSE)
	print(paste0("cbind...",format(Sys.time(), "%a %b %d %X %Y")))
	tmp=cbind(Entity=Ent,count=E_cnt,Probability=as.vector(previous))[Sn_order,]		
	write.csv(file=paste(savepath , "results_resources_" , name , "_HARE.txt",sep=''),tmp,row.names=FALSE)

	
	#############
	x=read.csv("D:\\RDF\\res\\results_resources_wd022018_HARE_hd.csv",header=T)
	plot(log(x[1:100,2]),x[1:100,3],main=sprintf("Top 100 entity Wikidata, count vs Probability\n correlation : %.1f %%",100*cor(log(x[1:100,2]),x[1:100,3])))

	aa=c(10,15,20,50,100,150,250,500,750,1000,2000)
	ac=NULL
	for(i in aa)ac=c(ac,cor(log(x[1:i,2]),x[1:i,3]));
	plot(aa,ac,type='b',col='red',lwd=2,main="Correlation between log(counts) and probability",xlab="Number of entities",ylab="Pearson corr.")

	#####
