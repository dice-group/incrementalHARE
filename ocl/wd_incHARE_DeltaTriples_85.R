# 15/4/2019

##--------------
damping=0.85
print(sprintf('damping=%f',damping))
tl0=proc.time()
 nt1= 681596142
 nt2=2416986129

 ext1=686312297
 ext2=5041110266

P=matrix(0,2,2)
P[1,1]=(3*nt1)/(3*nt1 +ext1)
P[1,2]=ext1/(3*nt1 + ext1)
P[2,2]=(3*nt2)/(3*nt2+ext2)
P[2,1]=ext2/(3*nt2+ext2)

# P=matrix(0,2,2)
# P[1,1]=(3*nt1-ext1)/(3*nt1 )
# P[1,2]=ext1/(3*nt1)
# P[2,2]=(3*nt2-ext2)/(3*nt2)
# P[2,1]=ext2/(3*nt2)
source('/upb/departments/pc2/users/d/desouki/abd/R/pageRank_loop.R')
#source('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\incHARE\\incrementalHARE\\pageRank_loop.R')
res=pageRank_loop(P,damping=damping,epsilon=1e-6)
rG=res$Sn

######################################
name="wd13062018delta"
savepath="/upb/scratch/departments/pc2/groups/hpc-prf-dsg/desouki/mats/wddelta/"
t0=proc.time()
chnkLen<-10e6
con <- file(paste(savepath,"wd13062018delta","_scaled_ST.txt",sep=''), "r", blocking = FALSE)
        con_ST <- file(paste(savepath,name,"_incHare_ST.txt",sep=''), "w")
# con <- file(paste(savepath,"wd04012018","_scaled_ST.txt",sep=''), "r", blocking = FALSE)
	while(1==1){
        ST = as.numeric(readLines(con,chnkLen))
        print(length(ST))
        if(length(ST)==0) break;
        ST_delta=ST*rG[1]
        writeLines(as.character(ST_delta),con_ST)
    }
    tf=proc.time();
    close(con)
    close(con_ST)
    print(tf-t0)
    print('ok')
    