# 13/6/2018
# read
name='sec'

rdfpath='D:\\RDF\\'
matpath='D:\\RDF\\mats\\'
respath='D:\\RDF\\res\\'
load(paste(matpath , "t2i_" , name , ".RData",sep="")) # set of Triples  T2I
load(paste(matpath , "e2i_" , name , ".RData",sep="")) 
source("C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\getTransitionMatrices.R")
source("C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\hare.R")

runtime = hare('sec.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = .95, saveresults=FALSE,saveRData=TRUE, printerror=TRUE, printruntimes=TRUE)

orgT2I=T2I
orgE2I=E2I
nt=nrow(T2I)
nt_inc=floor(nt/10)
## two parts
p1t=T2I[1:nt_inc,]
p2t=T2I[(nt_inc+1):nt,]

T2I=p1t
save(file=paste0(matpath,'t2i_',name,'_p1.RData'),T2I)
T2I=p2t
save(file=paste0(matpath,'t2i_',name,'_p2.RData'),T2I)

p1e=table(unlist(c(p1t[,1],p1t[,2],p1t[,3])))
p1e=cbind(sn=1:length(p1e),cnt=p1e)
E2I=p1e
save(file=paste0(matpath,'e2i_',name,'_p1.RData'),E2I)
#
p2e=table(unlist(c(p2t[,1],p2t[,2],p2t[,3])))
p2e=cbind(sn=1:length(p2e),cnt=p2e)
E2I=p2e
save(file=paste0(matpath,'e2i_',name,'_p2.RData'),E2I)
##
getTransitionMatrices('sec_p1.nt',loadpath=matpath,savepath=matpath)
getTransitionMatrices('sec_p2.nt',loadpath=matpath,savepath=matpath)
###
rt1 = hare('sec_p1.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = .85, saveRData=TRUE, saveresults=FALSE, printerror=TRUE, printruntimes=TRUE)
rt2 = hare('sec_p2.nt',loadpath=matpath,savepath=respath, epsilon=10^-4, damping = .85, saveRData=TRUE, saveresults=FALSE, printerror=TRUE, printruntimes=TRUE)

# partition
# inc hare
# flg=(orgT2I[,2]=='<http://purl.org/dc/elements/1.1/date>' | orgT2I[,2]=='<http://www.rdfabout.com/rdf/schema/ussec/cik>')
# p1t=orgT2I[flg,]
# p2t=orgT2I[!flg,]
ce=row.names(p1e)[row.names(p1e) %in% row.names(p2e)]
extlnks1=sum((p1t[,1]%in% ce) | (p1t[,2]%in% ce) | (p1t[,3]%in% ce) )
extlnks2=sum((p2t[,1]%in% ce) | (p2t[,2]%in% ce) | (p2t[,3]%in% ce) )
print(sprintf('np1:%d, np2:%d, ext1:%d, ext2:%d',nrow(p1t),nrow(p2t),extlnks1,extlnks2))

extlnks=extlnks1+extlnks2

P=matrix(0,2,2)
P[1,1]=nrow(p1t)/(nrow(p1t) + extlnks)
P[1,2]=extlnks/(nrow(p1t) + extlnks)
P[2,2]=nrow(p2t)/(nrow(p2t) + extlnks)
P[2,1]=extlnks/(nrow(p2t) + extlnks)
#### ---- ### ----- ###
source('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\pageRank_loop.R')
res=pageRank_loop(P,damping=0.85,epsilon=1e-6)

rG=res[[1]]

# new ranks
print(load(paste0(respath , "hare_" , "sec_p1.RData")))
p1hr=resourcedistribution
p1ht=tripledistribution
print(load(paste0(respath , "hare_" , "sec_p2.RData")))
p2hr=resourcedistribution
p2ht=tripledistribution
print(load(paste0(respath , "hare_" , "sec.RData")))
orghr=resourcedistribution
orght=tripledistribution
####
p1hr=p1hr*rG[1]
p1ht1=p1ht*rG[1]
p2hr=p2hr*rG[2]
p2ht1=p2ht*rG[2]

el=rep(0,nrow(orgE2I))
ix1=match(row.names(p1e),row.names(orgE2I))
ix2=match(row.names(p2e),row.names(orgE2I))
el[ix1]=el[ix1]+p1hr
el[ix2]=el[ix2]+p2hr
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
p1hr[row.names(p1e)==mxr]

# ----------------
#Average Error in Rank
# orghr_order=order(orghr,decreasing=TRUE)
# el_order=order(el,decreasing=TRUE)
# mean(abs(orghr_order-el_order))

tmp_tab=cbind(orgE2I,el,orghr=as.vector(orghr))
tmp_tab1=tmp_tab[orghr_order,]
tmp_tab2=cbind(tmp_tab1,orghr_order=order(tmp_tab1[,'orghr'],tmp_tab1[,'sn'],decreasing=TRUE),el_order=order(tmp_tab1[,'el'],tmp_tab1[,'sn'],decreasing=TRUE))
tmp_tab3=cbind(tmp_tab2,DiffRank=abs(tmp_tab2[,'orghr_order']-tmp_tab2[,'el_order']))
mean(tmp_tab3[,'DiffRank'])

write.csv(file="sec_incHARE_order.csv", tmp_tab3)
