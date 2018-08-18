# G

#d1
d1=cbind('S', 'P1', 'O1')
d1=rbind(d1,
cbind('S','P2','O2'))
#d2
d2=cbind('S1','P3','O1')


source("C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\getTransitionMatrices.R")
source("C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\hare.R")
rdfpath='C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\Data\\KnowledgeBases\\'
matpath='C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\Data\\Matrices\\'
respath='C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\Data\\Results\\'
T2I=d1
save(file=paste0(matpath,'t2i_toy2d1.RData'),T2I)
T2I=d2
save(file=paste0(matpath,'t2i_toy2d2.RData'),T2I)
ed1=table(unlist(c(d1[,1],d1[,2],d1[,3])))
ed1=cbind(sn=1:length(ed1),cnt=ed1)
ed2=table(unlist(c(d2[,1],d2[,2],d2[,3])))
ed2=cbind(sn=1:length(ed2),cnt=ed2)
E2I=ed1
save(file=paste0(matpath,'e2i_toy2d1.RData'),E2I)
E2I=ed2
save(file=paste0(matpath,'e2i_toy2d2.RData'),E2I)


d12=rbind(d1,d2)
T2I=d12
save(file=paste0(matpath,'t2i_toy2d12.RData'),T2I)
ed12=table(unlist(c(d12[,1],d12[,2],d12[,3])))
ed12=cbind(sn=1:length(ed12),cnt=ed12)
E2I=ed12
save(file=paste0(matpath,'e2i_toy2d12.RData'),E2I)
getTransitionMatrices('toy2d1.nt',loadpath=matpath,savepath=matpath)
getTransitionMatrices('toy2d2.nt',loadpath=matpath,savepath=matpath)
getTransitionMatrices('toy2d12.nt',loadpath=matpath,savepath=matpath)
damping=0.99
runtime = hare('toy2d1.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = damping, saveRData=TRUE, saveresults=FALSE, printerror=TRUE, printruntimes=TRUE)
runtime = hare('toy2d2.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = damping, saveRData=TRUE, saveresults=FALSE, printerror=TRUE, printruntimes=TRUE)
runtime = hare('toy2d12.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = damping, saveRData=TRUE, saveresults=FALSE, printerror=TRUE, printruntimes=TRUE)

######################################################
#Rank1
p1e=ed1
p2e=ed2
p1t=d1
p2t=d2
orgE2I=ed12
ce=row.names(p1e)[row.names(p1e) %in% row.names(p2e)]# common entities
### ---- ### ----- ###
extlnks1=sum(p1t[,1]%in% ce) + sum (p1t[,2]%in% ce) + sum (p1t[,3]%in% ce) 
extlnks2=sum(p2t[,1]%in% ce) + sum(p2t[,2]%in% ce) + sum(p2t[,3]%in% ce) 
print(sprintf('np1:%d, np2:%d, ext1:%d, ext2:%d',nrow(p1t),nrow(p2t),extlnks1,extlnks2))

extlnks=extlnks1+extlnks2

P=matrix(0,2,2)
P[1,1]=(3*nrow(p1t))/(3*nrow(p1t)+extlnks1 )
P[1,2]=extlnks1/(3*nrow(p1t)+extlnks1)
P[2,2]=(3*nrow(p2t))/(3*nrow(p2t)+extlnks2)
P[2,1]=extlnks2/(3*nrow(p2t)+extlnks2)
###---------------------------
source('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\pageRank_loop.R')
res=pageRank_loop(P,damping=0.99,epsilon=1e-8)

rG=res[[1]]

########################################################
# new ranks
print(load(paste0(respath , "hare_" , "toy2d1.RData")))
p1hr=resourcedistribution
p1ht=tripledistribution
print(load(paste0(respath , "hare_" , "toy2d2.RData")))
p2hr=resourcedistribution
p2ht=tripledistribution
print(load(paste0(respath , "hare_" , "toy2d12.RData")))
orghr=resourcedistribution
orght=tripledistribution
####
p1hr1=p1hr*rG[1]
p1ht1=p1ht*rG[1]
p2hr1=p2hr*rG[2]
p2ht1=p2ht*rG[2]

el=rep(0,nrow(orgE2I))
ix1=match(row.names(p1e),row.names(orgE2I))
ix2=match(row.names(p2e),row.names(orgE2I))
el[ix1]=el[ix1]+p1hr1
el[ix2]=el[ix2]+p2hr1
# Error
rSE=(el-orghr)*(el-orghr)
rMSE=sqrt(mean(rSE))
# Error in triples
t1SE=(p1ht1-p1ht)*(p1ht1-p1ht)
t1MSE=sqrt(mean(t1SE))
t2SE=(p2ht1-p2ht)*(p2ht1-p2ht)
t2MSE=sqrt(mean(t2SE))
print(sprintf('max r Error:%e, max t1Error:%e, max t2 Error:%e',max(abs(el-orghr)),max(abs(p1ht1-p1ht)),max(abs((p2ht1-p2ht)))))
xx=abs(el-orghr)
aa=which.max(as.vector(xx))
mxr=row.names(orgE2I)[aa]
orghr[aa]
el[aa]
p1hr1[row.names(p1e)==mxr]

##### best alpha ############
td1=data.frame(ent=row.names(p1e),cnt=p1e[,2],Probability=as.vector(p1hr),d1Rank=rank(-p1hr,ties.method="min"),stringsAsFactors=F)
td2=data.frame(ent=row.names(p2e),cnt=p2e[,2],Probability=as.vector(p2hr),d2Rank=rank(-p2hr,ties.method="min"),stringsAsFactors=F)
td12=data.frame(ent=row.names(orgE2I),cnt=orgE2I[,2],Probability=as.vector(orghr),d12Rank=rank(-orghr,ties.method="min"),stringsAsFactors=F)

    tab1=merge(td1,td2,by.x=1,by.y=1,all.y=TRUE,all.x=TRUE,suffixes=c(".d1",".d2"))#outer join
    # dincnewjun=merge(deleted,djun,by.x=1,by.y=1,all.y=TRUE,all.x=TRUE,suffixes=c(".deleted",".djun"))
    tab2=merge(tab1,td12,by.x=1,by.y=1)

    
approx_rG<-function(tab2,alpha){
# alpha=0.4158439
    rG=c(alpha,1-alpha)
    
    tab3=cbind(tab2,incHARE=rG[1]*ifelse(is.na(tab2[,'Probability.d1']),0,tab2[,'Probability.d1'])+rG[2]*ifelse(is.na(tab2[,'Probability.d2']),0,tab2[,'Probability.d2']))
    tab3=cbind(tab3,error=abs(tab3[,'incHARE']-tab3[,'Probability']))
    tab3=cbind(tab3,pct_error=tab3[,'error']/tab3[,'Probability'])
    rMSE=sqrt(mean(tab3[,'error']*tab3[,'error']))
    print(rMSE)
    # newjun_order=rank(-tab3[,'dnewjunRank'],ties.method="min")
    newjun_order=order(tab3[,'d12Rank'])
    tab4=tab3[newjun_order,]
    # incjun_order=order(tab4[,'incHAREjun'],decreasing=TRUE)
    newjun_order=rank(tab4[,'d12Rank'],ties.method="min")
    # tab4=cbind(tab4,incHareRank=order(tab4[,'incHARE'],decreasing=TRUE),incjun_order=incjun_order)
    tab4=cbind(tab4,incHareRank=rank(-tab4[,'incHARE'],ties.method="min"),d12_order=newjun_order)
    tab4=cbind(tab4,DiffRank=abs(tab4[,'incHareRank']-tab4[,'d12_order']))
    #head(tab4)
    # return(mean(abs(tab4[,'incHareRank']-tab4[,'incjun_order'])))
    return(list(tab4=tab4,rMSE=rMSE))
}

# tab4=approx_rG(tab2,0.4158439)
 # (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'d12_order'])))
 # (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'d12_order'])))
######################
  Res=NULL
  
  x.c=0.5
  x.res=0.1
  x.rad=0.5
  
  minx=x.c
  # tab4=approx_rG(tab2,minx)
    res_rg=approx_rG(tab2,minx)
    tab4=res_rg[[1]]
    rMSE=res_rg[[2]]
  minRnk=mean(abs(tab4[,'incHareRank']-tab4[,'d12_order']))
  minrMSE=rMSE
  for(lvl in 1:3){
      for( x in seq(x.c-x.rad,x.c+x.rad,x.res)){
            res_rg=approx_rG(tab2,x)
            tab4=res_rg[[1]]
            rMSE=res_rg[[2]]
            avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'d12_order']))
            # if(avgRnk<minRnk){
            if(minrMSE>rMSE){
                minx=x
                minRnk=avgRnk
                minrMSE=rMSE
                print(sprintf("x=%f, avgRnk:%.2f",x,avgRnk))
            }
              Res=rbind(Res,cbind(x,avgRnk,rMSE))
      }
  
    print(sprintf("minx=%f, minRnk:%.2f,minrMSE=%f",minx,minRnk,minrMSE))
   x.res=x.res/10
   x.rad=x.rad/10
   x.c=minx
   print(sprintf('================  lvl %d  ===============',lvl))
   }
  
  res_rg=approx_rG(tab2,rG[1])
  tab4=res_rg[[1]]
  rMSE=res_rg[[2]]
 (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'d12_order'])))
 (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'d12_order'])))
 
 write.table(tab4,file='clipboard',row.names=FALSE,sep='\t')
 
 ############## old P
 # extlnks1=sum((p1t[,1]%in% ce) | (p1t[,2]%in% ce) | (p1t[,3]%in% ce) )
# extlnks2=sum((p2t[,1]%in% ce) | (p2t[,2]%in% ce) | (p2t[,3]%in% ce) )
# print(sprintf('np1:%d, np2:%d, ext1:%d, ext2:%d',nrow(p1t),nrow(p2t),extlnks1,extlnks2))

# extlnks=extlnks1+extlnks2

# P=matrix(0,2,2)
# P[1,1]=nrow(p1t)/(nrow(p1t) + extlnks)
# P[1,2]=extlnks/(nrow(p1t) + extlnks)
# P[2,2]=nrow(p2t)/(nrow(p2t) + extlnks)
# P[2,1]=extlnks/(nrow(p2t) + extlnks)