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

source('C:\\Users\\Abdelmonem\\Dropbox\\HARE\\HareSparkR\\HareSparkR\\pageRank_loop.R')
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

approx_rG<-function(tab2,alpha){
# alpha=0.4158439
    rG=c(alpha,1-alpha)
    # djun.rG=c(y,1-y)
    
    tab3=cbind(tab2,incHARE=rG[1]*ifelse(is.na(tab2[,'Probability.delta']),0,tab2[,'Probability.delta'])+rG[2]*ifelse(is.na(tab2[,'Probability.djan']),0,tab2[,'Probability.djan']))
    # tab3=cbind(tab3,incHAREjun=djun.rG[1]*ifelse(is.na(tab3[,'Probability.deleted']),0,tab3[,'Probability.deleted'])+djun.rG[2]*ifelse(is.na(tab3[,'Probability.djun']),0,tab3[,'Probability.djun']))
    tab3=cbind(tab3,error=abs(tab3[,'incHARE']-tab3[,'Probability']))
    tab3=cbind(tab3,pct_error=tab3[,'error']/tab3[,'Probability'])
    rMSE=sqrt(mean(tab3[,'error']*tab3[,'error']))
    print(rMSE)
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
    return(tab4)
}

# tab4=approx_rG(tab2,0.234)
tab4=approx_rG(tab2,0.4158439)
 (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
 (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
# write.csv(file=paste0('wd_top10k_newjun','_d',100*damping,'.csv'),tab4)


##############################################

  Res=NULL
  
  x.c=0.25
  x.res=0.01
  x.rad=0.25
  
  minx=x.c
  tab4=approx_rG(tab2,minx)
  minRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order']))
  for(lvl in 1:3){
      for( x in seq(x.c-x.rad,x.c+x.rad,x.res)){
            tab4=approx_rG(tab2,x)
            avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order']))
            if(avgRnk<minRnk){
                minx=x
                minRnk=avgRnk
                print(sprintf("x=%f, avgRnk:%.2f",x,avgRnk))
            }
              Res=rbind(Res,cbind(x,avgRnk))
      }
  
    print(sprintf("minx=%f, minRnk:%.2f",minx,minRnk))
   x.res=x.res/10
   x.rad=x.rad/10
   x.c=minx
   print(sprintf('================  lvl %d  ===============',lvl))
   }
  
  tab4=approx_rG(tab2,0.2506)
 (avgRnk=mean(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))
 (medRnk=median(abs(tab4[,'incHareRank']-tab4[,'newjun_order'])))