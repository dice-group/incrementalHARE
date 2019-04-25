# 12/4/2019
# given S_N find S_T,
# S_N is kept entirly in memory
# S_T must be saved in chunks as its size > 2B
# calculate F in demand chunk by chunk


name="wd13062018delta"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wddelta/"
loadpath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/"

Beta=681596142
Alpha=217850021

ni=20
damping=0.85
hd_sz=1000
# Beta=2605676230#length(S)
chnkLen=10*1e6#20M
NChnks=as.integer(ceiling(Beta/chnkLen))
print(sprintf("NChnks:%d",NChnks))

# p1_sz = floor(Beta/chnkLen/2)*chnkLen# two partitions are enough
# p2_sz =Beta-p1_sz

	print('Reading S_n...')
	# print(load(paste0(savepath,"Sn_",name,"_",ni,".RData")))#previous
    print(load(paste0(savepath,"Sn_wd13062018delta_20_d",damping*100,".RData")))
	S_n=previous
	rm(previous)
	#resourcedistribution = S_n  #S(N)
	###
	# con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	# Ent = readLines(con)
	# close(con)
	# Ent=Ent[-1]
	#print(load(paste0(loadpath,name,"_E_cnt.RData")))
        con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	 E_cnt = as.integer(readLines(con))
	close(con)
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
	t2=proc.time()
	
	#Alpha=length(E_cnt)
 S_n=as.matrix(S_n,nrow=Alpha)
    print(sprintf("Size of E_cnt:%.1f MB",object.size(E_cnt)/(1024*1024)))	
	scaleS_N = Beta/(Alpha + Beta)
	scaleS_T = 1-scaleS_N
	scaled_S_n = S_n * scaleS_T
	# print('saving scaled_Sn')
	# con <- file(paste0(savepath,"scaled_Sn_",name,"_",ni,".txt"),'w')
	# writeLines(as.character(scaled_S_n),con)
	# close(con)
	# rm(S_n)
	
	con_s <- file(paste(loadpath,name,"_s.txt",sep=''), "r", blocking = FALSE)
	con_p <- file(paste(loadpath,name,"_p.txt",sep=''), "r", blocking = FALSE)
	con_o <- file(paste(loadpath,name,"_ol.txt",sep=''), "r", blocking = FALSE)
	starting_ch = 1
	
		# S_T1 = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(p1_sz,1))
		# S_T2 = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(p2_sz,1))
# write directly to disk
    con_ST <- file(paste(savepath,name,"_scaled_ST.txt",sep=''), "w")
	# tripledistribution = Matrix::t(F) %*% S_n #Equation 6, S(T)=F^T * S(N)
	t0=proc.time()
	print(t0-t2)
	ch_st =1
	topTrp=NULL
	for(ch in 1:NChnks){
	    print(ch)
		if(ch==1)	    t1=proc.time();
		if(ch==NChnks) chnkLen=Beta - chnkLen*(ch-1)# can be different
		F_ch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, chnkLen))
		
		S_ch=as.integer(readLines(con_s,chnkLen))
		trp_ct=length(S_ch)
		if(trp_ct==0) break;
		t2=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |S|=%d, memory:%.1f",ch,(t2-t1)[3],length(S_ch),object.size(S_ch)/(1024*1024)))
		F_ch[cbind(S_ch,1:trp_ct)]=1.0/E_cnt[S_ch]
		gc()
		P_ch=as.integer(readLines(con_p,chnkLen))
		F_ch[cbind(P_ch,1:trp_ct)]=1.0/E_cnt[P_ch]
		t3=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |P|=%d, memory:%.1f",ch,(t3-t2)[3],length(P_ch),object.size(P_ch)/(1024*1024)))
		
		gc()
		O_ch=as.integer(readLines(con_o,chnkLen))
		F_ch[cbind(O_ch,1:trp_ct)]=1.0/E_cnt[O_ch]
		t4=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |O|=%d, O_ch:%.1f, memF_ch:%.1f",ch,(t4-t3)[3],length(O_ch),object.size(O_ch)/(1024*1024),
		        object.size(F_ch)/(1024*1024)))
		
		FTchSn = Matrix::t(F_ch) %*% S_n
		FTchSn = scaleS_T * FTchSn
		print(paste0('Writing result chunck ...',ch))
		writeLines(as.character(FTchSn),con_ST)
		qn=quantile(FTchSn,1-hd_sz/chnkLen)
		topix=which(FTchSn[,1] >= qn)
		topTrp=rbind(topTrp,cbind(ch=ch,qn=qn,chnkLen=chnkLen,index=ch_st-1+topix,prob=FTchSn[topix],
			#			txt=paste(Ent[S_ch[topix]],Ent[P_ch[topix]],Ent[O_ch[topix]],sep=':')))
			txt=paste(S_ch[topix],P_ch[topix],O_ch[topix],sep=':')))
		gc()
		rm(F_ch)
		rm(S_ch)
		rm(P_ch)
		rm(FTchSn)
		rm(O_ch)
		gc()
		ch_st=ch_st+chnkLen
		t4=proc.time()
		print(sprintf("Chunk:%d, time total:%.3f, time FSn:%.3f, time P:%.3f",ch,(t4-t1)[3],(t3-t2)[3],(t4-t3)[3]))
		
	}
	close(con_s)
	close(con_p)
	close(con_o)
	close(con_ST)
	
	qnSn = quantile(scaled_S_n,1-hd_sz/Alpha)
	topSnix = which(scaled_S_n>=qnSn)
	topSn=cbind(ch=0,qn=qnSn,chnkLen=Alpha,index=topSnix,prob=scaled_S_n[topSnix],
				#		txt=Ent[topSnix])
				txt=topSnix)
	
	Tmp=rbind(topSn,topTrp )
	hd_order=order(as.numeric(Tmp[,'prob']),decreasing=TRUE)
	tmp_hd=cbind(Tmp[hd_order,'txt'],Tmp[hd_order,'prob'])
	print(paste0("Saving head:",3*hd_sz," ",format(Sys.time(), "%a %b %d %X %Y")))
	write.csv(file=paste(savepath , "top_ranks_" , name , "_HARE.csv",sep=''),tmp_hd,row.names=FALSE)
	
	###-----------------------------------------###
	tf=proc.time()
	print(tf-t0)
	print('ok')
	