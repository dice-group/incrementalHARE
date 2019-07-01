# 9/7/2018

name="wd04012018"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wdjan/nc8/"
loadpath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/ParseNT/wdjan/"

t1=proc.time()
	con <- file(paste(loadpath,name,"_E_cnt.txt",sep=''), "r", blocking = FALSE)
	E_cnt=as.integer(readLines(con))
	close(con)
	E_cnt=E_cnt[-1]# must be there #Exclude the dummy node
	t2=proc.time()
	Beta=2416986129#length(S)
	Alpha=length(E_cnt)
    print(sprintf("Size of E_cnt:%.1f MB",object.size(E_cnt)/(1024*1024)))	
	chnkLen=25000000
	NChnks=as.integer(ceiling(Beta/chnkLen))
	print(sprintf("NChnks:%d",NChnks))
	print(t2-t1)
	NCH=10
	ncores=7#one reserved
	require(parallel)
	require(doParallel)
	cluster <- makeCluster(ncores,outfile="")
	registerDoParallel(cluster)
    fnames=c(paste(loadpath,name,"_s.txt",sep=''),paste(loadpath,name,"_p.txt",sep=''),paste(loadpath,name,"_ol.txt",sep=''))

    read_list<-function(fi){
        x_list<-list()
        con_x <- file(fnames[fi], "r", blocking = FALSE)
        for(i in 1:NChnks){
            x_list[[i]]<-as.integer(readLines(con_x,chnkLen))
        }
       close(con_x)
       return(x_list)        
    }

  get_chunk_FW <- function(s_ch){
        
    FW = Matrix::spMatrix(i=1,j=1,x=0,nrow=Alpha, ncol=Alpha)
	
	for(ch in s_ch:min(NChnks,NCH+s_ch-1)){
	    print(ch)
	    t1=proc.time()

        S_ch=s_list[[ch]]
		trp_ct=length(S_ch)
		if(trp_ct==0) break;
		t2=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |S|=%d, memory:%.1f",ch,(t2-t1)[3],length(S_ch),object.size(S_ch)/(1024*1024)))
		P_ch=p_list[[ch]]
		t3=proc.time()
		print(sprintf("Chunk:%d, time read:%.3f, |P|=%d, memory:%.1f",ch,(t3-t2)[3],length(P_ch),object.size(P_ch)/(1024*1024)))
		O_ch=o_list[[ch]]
		t4=proc.time()

		print(sprintf("Chunk:%d, time read:%.3f, |O|=%d, O_ch:%.1f",ch,(t4-t3)[3],length(O_ch),object.size(O_ch)/(1024*1024)))
        Wt <-Matrix::sparseMatrix(j=c(S_ch,P_ch,O_ch),i=c(1:trp_ct,1:trp_ct,1:trp_ct),x=1.0/3,dims=c(chnkLen,Alpha))
        Ft <- Matrix::sparseMatrix(i=c(S_ch,P_ch,O_ch),j=c(1:trp_ct,1:trp_ct,1:trp_ct),x=1.0/c(E_cnt[S_ch],E_cnt[P_ch],E_cnt[O_ch]),dims=c(Alpha, chnkLen))
        FW = FW + Ft %*% Wt;
        t5 = proc.time()
        if(max(FW@x)>1.000001){
           	print(sprintf("#nnz:%d, maxV:%f,imx=%d, cnt>1:%d",sum(FW@x>0),max(FW@x),FW@i[which.max(FW@x)],sum(FW@x>1.000001)))
			save(file=paste0(savepath,"FW10_state_",name,"_",ch,".RData"),Ft,Wt,S_ch,P_ch,O_ch,FW)   
			stop("Error: there are values >1/3 in P.")
        }
        gc()
		t4=proc.time()
		print(sprintf("Chunk:%d, time total:%.3f, time FW:%.3f, time P:%.3f,memFW:%.1f",ch,(t5-t1)[3],(t5-t4)[3],(t4-t3)[3],object.size(FW)/(1024*1024)))
	}
	print(paste0("Saving FW, ch:",ch))
	save(file=paste0(savepath,"FW_",name,"_",ch,".RData"),FW)

    return(length(FW@x))
}   
	t00=proc.time()
    print("Loading s, p, o files...")
    tmp1 <- foreach(fi = 1:3,.packages='Matrix') %dopar% {
        x_list=read_list(fi)
     }
 s_list=tmp1[[1]]
 p_list=tmp1[[2]]
 o_list=tmp1[[3]]
    
    rm(tmp1)
    gc()
    t0=proc.time()
    print(sprintf("time loading:%.2f,sizes s_list:%.1f, p_list:%.1f, o_list:%.1f MB",(t0-t00)[3],object.size(s_list)/(1024*1024),
                                 object.size(p_list)/(1024*1024),object.size(o_list)/(1024*1024)))
	tmp2 <- foreach(i = 1:ceiling(NChnks/NCH),.packages='Matrix', .combine="c") %dopar% {
    # for(i in 1:ceiling(NChnks/NCH)){
            print(i)
            tmp=get_chunk_FW(NCH*(i-1)+1);
            print(tmp)
        }
    tf=proc.time()
    print(tf-t0)
 stopCluster(cluster)
    print(tmp2)
    write.table(file=sprintf("%s_FW%d_tmp2.txt",name,NCH),tmp2)
