# 2/8/2018
damping=0.85
 nt1= 681596142
 nt2=2416986129

 ext1=686312297
 ext2=5041110266


P=matrix(0,2,2)
P[1,1]=(3*nt1)/(3*nt1+ext2 )
P[1,2]=ext2/(3*nt1+ext2)
P[2,2]=(3*nt2)/(3*nt2+ext1)
P[2,1]=ext1/(3*nt2+ext1)

source('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\incHARE\\incrementalHARE\\pageRank_loop.R')
res=pageRank_loop(P,damping=damping,epsilon=1e-6)
rG=res$Sn
####################################
   delta=read.csv(paste0('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\incHARE\\Results\\results_resources_wd13062018delta','_d',100*damping,'_HARE_hd.csv'),header=T,stringsAsFactors=FALSE)
    djan=read.csv(paste0('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\incHARE\\Results\\results_resources_wd04012018','_d',100*damping,'_HARE_hd.csv'),header=T,stringsAsFactors=FALSE)
    dnewjun=read.csv(paste0('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\incHARE\\Results\\results_resources_wdnewjun','_d',100*damping,'_HARE_hd.csv'),header=T,stringsAsFactors=FALSE)

    sum(delta[,1] %in% djan[,1] & delta[,1] %in% dnewjun[,1])
    delta=cbind(delta,deltaRank=order(delta[,3],decreasing=TRUE))
    djan=cbind(djan,djanRank=order(djan[,3],decreasing=TRUE))
    dnewjun=cbind(dnewjun,dnewjunRank=order(dnewjun[,3],decreasing=TRUE))
    # deleted=cbind(deleted,deletedRank=order(deleted[,3],decreasing=TRUE))

    tab1=merge(delta,djan,by.x=1,by.y=1,all.y=TRUE,all.x=TRUE,suffixes=c(".delta",".djan"))#outer join
    # dincnewjun=merge(deleted,djun,by.x=1,by.y=1,all.y=TRUE,all.x=TRUE,suffixes=c(".deleted",".djun"))
    tab2=merge(tab1,dnewjun,by.x=1,by.y=1)
    newjun_order=order(tab2[,'Probability'],decreasing=TRUE)
    tab2=tab2[newjun_order,]
    
    # flg=!is.na(tab2[,'deltaRank']) & !is.na(tab2[,'djanRank'])
 
    # tab2=tab2[flg,]
 
approx_rG<-function(tab2,alpha,rMSEonly=FALSE){
# get rMSE and rankDiff according to alpha
# alpha=0.4158439
    rG=c(alpha,1-alpha)
    # djun.rG=c(y,1-y)
    
    tab3=cbind(tab2,incHARE=rG[1]*ifelse(is.na(tab2[,'Probability.delta']),0,tab2[,'Probability.delta'])+rG[2]*ifelse(is.na(tab2[,'Probability.djan']),0,tab2[,'Probability.djan']))
    # tab3=cbind(tab3,incHAREjun=djun.rG[1]*ifelse(is.na(tab3[,'Probability.deleted']),0,tab3[,'Probability.deleted'])+djun.rG[2]*ifelse(is.na(tab3[,'Probability.djun']),0,tab3[,'Probability.djun']))
    tab3=cbind(tab3,error=abs(tab3[,'incHARE']-tab3[,'Probability']))
    tab3=cbind(tab3,pct_error=tab3[,'error']/tab3[,'Probability'])
    rMSE=sqrt(mean(tab3[,'error']*tab3[,'error']))
    # print(rMSE)
    if(rMSEonly) {
        return(list(tab4=NULL,rMSE=rMSE))
    }
    # newjun_order=rank(-tab3[,'dnewjunRank'],ties.method="min")
    newjun_order=order(tab3[,'dnewjunRank'])
    tab4=tab3[newjun_order,]
    # incjun_order=order(tab4[,'incHAREjun'],decreasing=TRUE)
    newjun_order=rank(tab4[,'dnewjunRank'],ties.method="min")
    # tab4=cbind(tab4,incHareRank=order(tab4[,'incHARE'],decreasing=TRUE),incjun_order=incjun_order)
    tab4=cbind(tab4,incHareRank=rank(-tab4[,'incHARE'],ties.method="min"),newjun_order=newjun_order)
    tab4=cbind(tab4,DiffRank=abs(tab4[,'incHareRank']-tab4[,'newjun_order']))
    #head(tab4)
    # return(mean(abs(tab4[,'incHareRank']-tab4[,'incjun_order'])))
    return(list(tab4=tab4,rMSE=rMSE))
}


##############################################

  bisect<-function(tab,rMSEonly=FALSE,x.c=0.25,  x.res=0.01,  x.rad=0.25,maxlvl=3){
      Res=NULL
        
      minx=x.c
      res_rg=approx_rG(tab,minx,rMSEonly=rMSEonly)
        tab4=res_rg[[1]]
        rMSE=res_rg[[2]]
      minRnk=ifelse(is.null(tab4),0,mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
      minrMSE=rMSE
      for(lvl in 1:maxlvl){
          for( x in seq(x.c-x.rad,x.c+x.rad,x.res)){
               res_rg=approx_rG(tab,x,rMSEonly=rMSEonly)
                tab4=res_rg[[1]]
                rMSE=res_rg[[2]]
                avgRnk=ifelse(is.null(tab4),0,mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
                # if(avgRnk<minRnk){
                if(minrMSE>rMSE){
                    minx=x
                    minRnk=avgRnk
                    minrMSE=rMSE
                    # print(sprintf("x=%f, avgRnk:%.2f",x,avgRnk))
                }
                  Res=rbind(Res,cbind(x,avgRnk,rMSE))
          }
      
        print(sprintf("minx=%f, minRnk:%.2f,minrMSE=%f",minx,minRnk,minrMSE))
       x.res=x.res/10
       x.rad=x.rad/10
       x.c=minx
       print(sprintf('================  lvl %d  ===============',lvl))
       }
    return(list(minx=minx,avgRnk=minRnk,rMSE=minrMSE))
  }
  
  # tab4=approx_rG(tab2,minx)
  res=bisect(tab=tmp,rMSEonly=TRUE,x.c=0.5,  x.res=0.01,  x.rad=0.5,maxlvl=3)
  res_rg=approx_rG(tab2,res[['minx']])
  tab4=res_rg[[1]]
  rMSE=res_rg[[2]]
 (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
 (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
 
 res_rg=approx_rG(tab2,rG[1])
  tab4=res_rg[[1]]
  rMSE=res_rg[[2]]
 (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
 (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))

tab2_10k=tab2

t0=proc.time()
Res=NULL
for(n in 1:9000){
    print(n)
    tmp=tab2_10k[1:n,]
    res=bisect(tab=tmp,rMSEonly=TRUE,x.c=0.5,  x.res=0.01,  x.rad=0.5,maxlvl=3)
    flg=!is.na(tmp[,'deltaRank']) & !is.na(tmp[,'djanRank'])
    Res=rbind(Res,cbind(n=n,rMSE=res[['rMSE']],avgRnk=res[['avgRnk']],cntinboth=sum(flg)))
}
 t1=proc.time()
 t1-t0
 
 rmean=NULL
for(i in 1:n){
    print(i)
    tmp=tab2_10k[1:i,]
    rmean=rbind(rmean,cbind(i,mean(tmp[,'Probability'])))
 }
 
 plot(Res[,1],1/Res[,1],main="rMSE with number of top HARE scores",xlab='n',ylim=c(min(Res[,2],1/Res[,1]),max(Res[,2],1/Res[,1])),ylab='Error',log='y',col='blue')
 points(Res[,1],Res[,2])#main="rMSE with no of top HARE scores",xlab='n',ylab='Error',log='y')
 points(rmean[,1],rmean[,2],col='red')
 # 
 
  legend(legend=c('incHare rMSE','1/n','running mean'),col=c('black','blue','red'),x=50,y=1e-5,pch=1,cex=0.75)

  # save(file='Res_top_3k_Rnk_rMSE.RData',Res)
  nn=c(1:10,seq(12,40,2),seq(45,100,5),seq(110,200,10),seq(220,400,20),seq(450,1000,50),seq(1100,2000,100),seq(2200,4000,200),seq(4500,10000,500))
  nn=c(nn,seq(11000,20000,1000),seq(22000,50000,2000),seq(55000,100000,5000),seq(110000,200000,10000),seq(220000,300000,20000))
  length(nn)
  
  plot(Res[,1],Res[,3],main='Average Rank Diff',xlab='n',ylab='Avg Rank Diff')
  

t0=proc.time()
Res=NULL
for(n in nn){
    print(n)
    tmp=tab2_10k[1:n,]
    res=bisect(tab=tmp,rMSEonly=TRUE,x.c=0.5,  x.res=0.01,  x.rad=0.5,maxlvl=3)
    flg=!is.na(tmp[,'deltaRank']) & !is.na(tmp[,'djanRank'])
    Res=rbind(Res,cbind(n=n,rMSE=res[['rMSE']],avgRnk=res[['avgRnk']],cntinboth=sum(flg)))
}
 t1=proc.time()
 t1-t0
 
 rmean=NULL
for(i in nn){
    print(i)
    tmp=tab2_10k[1:i,]
    rmean=rbind(rmean,cbind(i,mean(tmp[,'Probability'])))
 }
 
  plot(Res[,1],1/Res[,1],type='l',main="rMSE trend with top 300K",xlab='n',ylim=c(min(Res[,2],1/Res[,1]),max(Res[,2],1/Res[,1])),ylab='Error',log='y',col='blue',lwd=2)
points(Res[,1],Res[,2],lwd=2,type='l')#main="rMSE with no of top HARE scores",xlab='n',ylab='Error',log='y')
  points(rmean[,1],rmean[,2],col='red',lwd=2,type='l')
  
   legend(legend=c('incHare rMSE','1/n','running mean'),col=c('black','blue','red'),x=max(Res[,1])*0.75,y=0.75,lwd=2,cex=0.75)
   
   # Res=Resa[Resa[,1]<50000,]
   plot(Res[,1],Res[,3],main='Average Rank Diff',xlab='n',ylab='Avg Rank Diff',type='l')

   # tab3=cbind(tab2,cnts)
   
   cnt_order=rank(-tab2[,'count'],ties.method="min")
   tab3=cbind(tab2,cnt_order)
   n=10
   avgRank=mean(abs(tab3[1:n,'cnt_order']-tab3[1:n,'newjun_order']))
   
   ##############################################################
   # save(file='Resa_top_300k_Rnk_rMSE.RData',Resa,rmean)
   print(load('Resa_top_300k_Rnk_rMSE.RData'))
   Res=Resa
   Res[,1]=Res[,1]/1000
   rmean=rmean[!is.na(rmean[,2]),]
 the_plot <- function(Res)
{
   plot(Res[,1],0.001/Res[,1],type='l',main="",xlab='n (Thousands)',ylim=c(min(Res[,2],1/Res[,1]),max(Res[,2],0.001/Res[,1])),
      ylab='Error',log='y',col='blue',lwd=2,cex=0.85,cex.lab=1,cex.axis=1)
    points(Res[,1],Res[,2],lwd=2,type='l')#main="rMSE with no of top HARE scores",xlab='n',ylab='Error',log='y')
  points(rmean[,1]/1000,rmean[,2],col='red',lwd=2,type='l')
  
   legend(legend=c('IRaKG rMSE','1/n','running mean'),col=c('black','blue','red'),x=max(Res[,1])*0.5,y=0.75,lwd=2,cex=1)
}
 
  par(mgp=c(2.2,0.45,0), tcl=-0.3, mar=c(3.3,3.6,1.1,1.1))
 the_plot(Res)