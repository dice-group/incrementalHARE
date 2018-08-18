# 14/3/2018
name="wd022018"
savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
oadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
t1=proc.time()
	# con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	# E_cnt=as.integer(readLines(con))
	# close(con)
	# save(file=paste0(loadpath,name,"_E_cnt.RData"),E_cnt)
	print(load(paste0(loadpath,name,"_E_cnt.RData")))
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
	t2=proc.time()
	Beta=2605676230#length(S)
	Alpha=length(E_cnt)
    print(sprintf("Size of E_cnt:%.1f MB",object.size(E_cnt)/(1024*1024)))	
	chnkLen=25000000
	NChnks=as.integer(ceiling(Beta/chnkLen))
	print(sprintf("NChnks:%d",NChnks))
	print(t2-t1)
	con_s <- file(paste(loadpath,name,"_s.txt",sep=''), "r", blocking = FALSE)
	con_p <- file(paste(loadpath,name,"_p.txt",sep=''), "r", blocking = FALSE)
	con_o <- file(paste(loadpath,name,"_ol.txt",sep=''), "r", blocking = FALSE)
	starting_ch=91
	# if(starting_ch > 1){#continue to a previous Run
		# print(sprintf("skipping # Chunks:%d",starting_ch-1))
		# aa=scan(con_s,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
		# aa=scan(con_p,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
		# aa=scan(con_o,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
		# print(paste0("loading file: ",savepath,"P_",name,"_",starting_ch-1,".RData"))
		# print(load(paste0(savepath,"P_",name,"_",starting_ch-1,".RData")))
	# }
	st_l=chnkLen*(starting_ch-1) - .Machine$integer.max
	if(st_l>0){
		print(sprintf("skipping # Chunks:%d, in two steps",starting_ch-1))
		aa=scan(con_s,what=list(NULL),sep='\n',blank.lines.skip = F,skip=.Machine$integer.max-1,nlines=1)
		aa=scan(con_p,what=list(NULL),sep='\n',blank.lines.skip = F,skip=.Machine$integer.max-1,nlines=1)
		aa=scan(con_o,what=list(NULL),sep='\n',blank.lines.skip = F,skip=.Machine$integer.max-1,nlines=1)
		
		aa=scan(con_s,what=list(NULL),sep='\n',blank.lines.skip = F,skip=st_l-1,nlines=1)
		aa=scan(con_p,what=list(NULL),sep='\n',blank.lines.skip = F,skip=st_l-1,nlines=1)
		aa=scan(con_o,what=list(NULL),sep='\n',blank.lines.skip = F,skip=st_l-1,nlines=1)
	}else{
		if(starting_ch > 1){#continue to a previous Run
			print(sprintf("skipping # Chunks:%d",starting_ch-1))
			aa=scan(con_s,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
			aa=scan(con_p,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
			aa=scan(con_o,what=list(NULL),sep='\n',blank.lines.skip = F,skip=chnkLen*(starting_ch-1)-1,nlines=1)
			print(paste0("loading file: ",savepath,"P_",name,"_",starting_ch-1,".RData"))
			print(load(paste0(savepath,"P_",name,"_",starting_ch-1,".RData")))
		}
	}

		FW = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, Alpha))
	
		t0=proc.time()
		print(t0-t2)
	for(ch in starting_ch:NChnks){
	    print(ch)
	    t1=proc.time()
		F_ch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, chnkLen))
		W_ch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(chnkLen, Alpha))

		S_ch=as.integer(readLines(con_s,chnkLen))
		trp_ct=length(S_ch)
		if(trp_ct==0) break;
		t2=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |S|=%d, memory:%.1f",ch,(t2-t1)[3],length(S_ch),object.size(S_ch)/(1024*1024)))
		W_ch[cbind(1:trp_ct,S_ch)]=1.0/3
		F_ch[cbind(S_ch,1:trp_ct)]=1.0/E_cnt[S_ch]
		rm(S_ch)
		gc()
		P_ch=as.integer(readLines(con_p,chnkLen))
		W_ch[cbind(1:trp_ct,P_ch)]=1.0/3
		F_ch[cbind(P_ch,1:trp_ct)]=1.0/E_cnt[P_ch]
		t3=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |P|=%d, memory:%.1f",ch,(t3-t2)[3],length(P_ch),object.size(P_ch)/(1024*1024)))
		rm(P_ch)
		gc()
		O_ch=as.integer(readLines(con_o,chnkLen))
		W_ch[cbind(1:trp_ct,O_ch)]=1.0/3
		F_ch[cbind(O_ch,1:trp_ct)]=1.0/E_cnt[O_ch]
		t4=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |O|=%d, O_ch:%.1f, memW_ch:%.1f, memF_ch:%.1f",ch,(t4-t3)[3],length(O_ch),object.size(O_ch)/(1024*1024),
		        object.size(W_ch)/(1024*1024),object.size(F_ch)/(1024*1024)))
		rm(O_ch)
		FW = FW + F_ch %*% W_ch
		gc()
		rm(F_ch)
		rm(W_ch)
		gc()
		# P = P + tmp
		t4=proc.time()
		print(sprintf("Chunk:%d, time total:%.3f, time FW:%.3f, time P:%.3f,memFW:%.1f",ch,(t4-t1)[3],(t3-t2)[3],(t4-t3)[3],object.size(FW)/(1024*1024)))
		
		if((ch %% 10)==0){
			print(paste0("Saving FW, ch:",ch))
			save(file=paste0(savepath,"FW_",name,"_",ch,".RData"),FW)
			FW = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, Alpha))
		}
	}
	close(con_s)
	close(con_p)
	close(con_o)
	
	save(file=paste0(savepath,"FW_",name,"_",NChnks,".RData"),FW)#Was P_name
	tf=proc.time()
	print(tf-t0)
	# d_P_T

	
	