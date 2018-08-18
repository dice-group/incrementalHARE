# 22/6/2018

name="wd13062018"
# savepath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
# loadpath="/upb/departments/pc2/scratch/desouki/ParseNT/wd/"
savepath="/home/AbdelmoneimDesouki/mats/nc16/"
loadpath="/home/AbdelmoneimDesouki/wd/"

t1=proc.time()
	con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	E_cnt=as.integer(readLines(con))
	close(con)
	# save(file=paste0(loadpath,name,"_E_cnt.RData"),E_cnt)
	# print(load(paste0(loadpath,name,"_E_cnt.RData")))
	# E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
	t2=proc.time()
	Beta=3039030927#length(S)
	Alpha=length(E_cnt)
    print(sprintf("Size of E_cnt:%.1f MB",object.size(E_cnt)/(1024*1024)))	
	chnkLen=25000000
	NChnks=as.integer(ceiling(Beta/chnkLen))
	print(sprintf("NChnks:%d",NChnks))
	print(t2-t1)
	NCH=10
	ncores=16
	require(parallel)
	require(doParallel)
	cluster <- makeCluster(ncores)
	registerDoParallel(cluster)

    get_chunk_FW <- function(s_ch){
        t00=proc.time()
        starting_ch=s_ch 
        con_s <- file(paste(loadpath,name,"_s.txt",sep=''), "r", blocking = FALSE)
        con_p <- file(paste(loadpath,name,"_p.txt",sep=''), "r", blocking = FALSE)
        con_o <- file(paste(loadpath,name,"_ol.txt",sep=''), "r", blocking = FALSE)
        st_l=chnkLen*(starting_ch-1) - .Machine$integer.max #starting line
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
                # print(paste0("loading file: ",savepath,"P_",name,"_",starting_ch-1,".RData"))
                # print(load(paste0(savepath,"P_",name,"_",starting_ch-1,".RData")))
            }
        }
		# FW = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, Alpha))
		FW = Matrix::spMatrix(i=1,j=1,x=0,nrow=Alpha, ncol=Alpha)
	
		t2=proc.time()
		print(t2-t00)
	for(ch in starting_ch:min(NChnks,NCH+starting_ch-1)){
	    print(ch)
	    t1=proc.time()
		F_ch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(Alpha, chnkLen))
		W_ch = Matrix::sparseMatrix(i=1,j=1,x=0,dims=c(chnkLen, Alpha))

		S_ch=as.integer(readLines(con_s,chnkLen))
		trp_ct=length(S_ch)
		if(trp_ct==0) break;
		W_ch[cbind(1:trp_ct,S_ch)]=1.0/3
		F_ch[cbind(S_ch,1:trp_ct)]=1.0/E_cnt[S_ch]
		t2=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |S|=%d, memory:%.1f",ch,(t2-t1)[3],length(S_ch),object.size(S_ch)/(1024*1024)))
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
	}
	close(con_s)
	close(con_p)
	close(con_o)
	print(paste0("Saving FW, ch:",ch))
	save(file=paste0(savepath,"FW_",name,"_",ch,".RData"),FW)

    # FW = Matrix::spMatrix(i=1,j=1,x=0,nrow=Alpha, ncol=Alpha)
	# save(file=paste0(savepath,"FW_",name,"_",NChnks,".RData"),FW)
	t2=proc.time()
	print(t2-t00)
    
    return(length(FW@x))
}   
	
    t0=proc.time()
		tmp2 <- foreach(i = 1:ceiling(NChnks/NCH),.packages='Matrix', .combine="c") %dopar% {
       # for(i in 1:ceiling(NChnks/NCH)){
            print(i)
            tmp=get_chunk_FW(NCH*(i-1)+1);
            print(tmp)
        }
    tf=proc.time()
    print(tf-t0)
    stopCluster(cluster)