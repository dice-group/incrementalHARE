## checks
## transition matrix max value<1??
## max(rowSums)-min(rowSums)<2e-6
name="wd04012018"
savepath="/home/AbdelmoneimDesouki/shared/mats/ocl/"
library(Matrix)
Beta=2416986129#length(S)
Alpha=446499408
ch_sz=1e5*c(5,15,rep(100,10),rep(1000,3))
    ch_sz=c(ch_sz,Alpha-sum(ch_sz))
    NPch <-length(ch_sz)
    print('reading P to memory')
	Pch_all <- list()
    t1=proc.time()
    nnz=NULL
    mx=NULL
    mnrs<-NULL
    mxrs<-NULL
    for(ch in 1:NPch){
		    print(sprintf("ch:%d",ch))
			# read chunk
			t2 = proc.time()
			print(load(paste0(savepath,"Pch_",name,"_",ch,".RData")))
			t3 = proc.time()
			Pch_all[[ch]]<-P_ch
            nnz=rbind(nnz,sum(P_ch@x>0))
            mx=rbind(mx,max(P_ch@x))
            rs=rowSums(P_ch)
            mnrs=rbind(mnrs,min(rs))
            mxrs=rbind(mxrs,max(rs))
			print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d, minRS:%f, maxRs:%f ",(t3-t2)[3],object.size(P_ch)/(1024*1024),nnz[ch],mnrs[ch],mxrs[ch]))
    }
    print(sprintf("time load:%.3f, memP_ch1:%.1f, nnz:%.1f",(proc.time()-t1)[3],object.size(Pch_all)/(1024*1024),nnz))
    
   
######################
   
name="wd04012018"
savepath="/home/AbdelmoneimDesouki/shared/mats/ocl/"
library(Matrix)
Beta=2416986129#length(S)
Alpha=446499408
	tch_sz = 1e5*c(4,15,rep(100,10),rep(1000,3))
    tch_sz=c(tch_sz,Alpha-sum(tch_sz))
    NPch <-length(tch_sz)
    print('reading P^T to memory')
	Pch_all <- list()
    t1=proc.time()
    nnz=NULL
    mx=NULL
    mnrs<-NULL
    mxrs<-NULL
    library(Matrix)
cs=rep(0,Alpha)
    for(ch in 1:NPch){
		    print(sprintf("ch:%d",ch))
			# read chunk
			t2 = proc.time()
			print(load(paste0(savepath,"PTch_",name,"_",ch,".RData")))
			t3 = proc.time()
			Pch_all[[ch]]<-PTch
            nnz=rbind(nnz,sum(PTch@x>0))
            mx=rbind(mx,max(PTch@x))
    
            cs1=colSums(PTch)
            cs=cs+cs1
            mnrs=rbind(mnrs,min(cs))
            mxrs=rbind(mxrs,max(cs))
			print(sprintf("time load:%.3f, memP_ch1:%.1f,nnz:%d, minRS:%f, maxRs:%f ",(t3-t2)[3],object.size(PTch)/(1024*1024),nnz[ch],mnrs[ch],mxrs[ch]))
    }
    print(sprintf("time load:%.3f, memP_ch1:%.1f, nnz:%.1f",(proc.time()-t1)[3],object.size(Pch_all)/(1024*1024),sum(as.numeric(nnz))))
    
    ################
    
name="wd13062018delta"
savepath="/home/AbdelmoneimDesouki/shared/mats/ocl/"

Beta=681596142
Alpha=217850021

    
    cs=rep(0,ncol(Pch_all[[1]]))
    for( i in 1:NPch){
        print(i)
        cs1=colSums(Pch_all[[i]])
        cs=cs+cs1
        print(sprintf(" minRS:%f, maxRs:%f ",min(cs),max(cs)))
    }
    
   
######################

    print(load(paste0(savepath,"FW_",name,"_",10,".RData")))
max(FW@x)
    
    
	# con <- file(paste("~/abd/mats/","wd04012018","_E_cnt.txt",sep=''), "r", blocking = FALSE)
	con <- file(paste("~/abd/mats/","wd13062018u","_E_cnt.txt",sep=''), "r", blocking = FALSE)
	t1=proc.time()
    E_cnt=as.integer(readLines(con))
	close(con)
    sum(as.numeric(E_cnt))/3.0
    print(proc.time()-t1)
    which(E_cnt==0)
    
    ###############################

    
name="wd04012018"
savepath="/home/hadoop/abd/mats/"
loadpath="/home/hadoop/abd/kg/"

print(load(paste0(savepath,"FW_",name,"_",10,".RData")))
sum(FW@x>=1)
FWt=as(FW,'TsparseMatrix')
imx= FWt@i[which.max(FWt@x)] +1     
jmx=FWt@j[which.max(FWt@x)]+1
FW[imx,jmx]

con <- file(paste("~/abd/mats/","wd04012018","_E_cnt.txt",sep=''), "r", blocking = FALSE)
	t1=proc.time()
    E_cnt=as.integer(readLines(con))
	close(con)
    E_cnt=E_cnt[-1]
    sum(E_cnt==0)
    sum(as.numeric(E_cnt))/3.0
    print(proc.time()-t1)
    which(E_cnt==0)
E_cnt[imx]
con <- file(paste(savepath,name,"_Entp2.txt",sep=''), "r", blocking = FALSE)
	Ent=readLines(con)
	close(con)
    Ent=Ent[-1]