# 24/4/2018
	name="sec"
	savepath="D:\\RDF\\mats\\"
	loadpath="D:\\RDF\\parseNT\\"

	#Scale with equation 8 to get a distribution
	ni=8
	hd_sz=5
	
	print('Reading S_n...')
	print(load(paste0(savepath,"Sn_",name,"_",ni,".RData")))#previous
	S_n=previous
	rm(previous)
	Alpha = length(S_n)
	Beta = 1814645
	p1_sz=as.integer(Beta/2)
	p2_sz=Beta-p1_sz
	scaleS_N = Beta/(Alpha + Beta)
	scaleS_T = 1-scaleS_N
	scaled_S_n = S_n * scaleS_T
	print('saving scaled_Sn')
	con <- file(paste0(savepath,"scaled_Sn_",name,"_",ni,".txt"),'w')
	writeLines(as.character(scaled_S_n),con)
	close(con)
	rm(S_n)
	#####
	print(paste0("Sorting...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=order(scaled_S_n,decreasing=TRUE)
    print(paste0("hd_order...",format(Sys.time(), "%a %b %d %X %Y")))
	Sn_order=Sn_order[1:hd_sz]
	Snhd_val=scaled_S_n[Sn_order]
	rm(scaled_S_n)
	#####
	gc()
	###
	print('Loading S(T): ...')
	con_STr <- file(paste(savepath,name,"_ST.txt",sep=''), "r")
	ST_1 = as.numeric(readLines(con_STr,p1_sz))
	ST_1 = ST_1 * scaleS_T
	
	con_ST <- file(paste(savepath,name,"_scaled_ST.txt",sep=''), "w")
	print('Writing scaled S(T) 1/2...')
	writeLines(as.character(ST_1),con_ST)
	print(paste0("Sorting S(T) 1/2...",format(Sys.time(), "%a %b %d %X %Y")))
	ST1_order=order(ST_1,decreasing=TRUE)
	ST1_order=ST1_order[1:hd_sz]
	ST1hd_val=ST_1[ST1_order]
	rm(ST_1)
	gc()
	ST_2 = as.numeric(readLines(con_STr,p2_sz))
	ST_2 = ST_2 * scaleS_T
	close(con_STr)
	gc()
	print('Writing scaled S(T) 2/2...')
	writeLines(as.character(ST_2),con_ST)
	close(con_ST)
	
	print(paste0("Sorting S(T) 2/2...",format(Sys.time(), "%a %b %d %X %Y")))
	ST2_order=order(ST_2,decreasing=TRUE)
	ST2_order=ST2_order[1:hd_sz]
	ST2hd_val=ST_2[ST2_order]
	rm(ST_2)
	gc()
	
##load Ent
	# print(load(paste0(loadpath,name,"_E_cnt.RData")))
	# E_cnt=E_cnt[-1]
	con <- file(paste(loadpath,name,"_Ent.txt",sep=''), "r", blocking = FALSE)
	Ent = readLines(con)
	close(con)
	Ent=Ent[-1]
	
	# getTripleSet
	print('getting getTripleSet 1/2...')
	con_s <- file(paste(loadpath,name,"_s.txt",sep=''), "r", blocking = FALSE)
	trp_s=as.integer(readLines(con_s,p1_sz))
	st1hd_s=Ent[trp_s[ST1_order]]
    rm(trp_s)
	gc()
	print('getting getTripleSet 1/2 p...')
	con_p <- file(paste(loadpath,name,"_p.txt",sep=''), "r", blocking = FALSE)
	trp_p=as.integer(readLines(con_p,p1_sz))
	st1hd_p=Ent[trp_p[ST1_order]]
	rm(trp_p)
	gc()
	print('getting getTripleSet 1/2 o...')
	con_o <- file(paste(loadpath,name,"_ol.txt",sep=''), "r", blocking = FALSE)
	trp_o=as.integer(readLines(con_o,p1_sz))
	st1hd_o=Ent[trp_o[ST1_order]]
	rm(trp_o)
	gc()
	print('getting getTripleSet 2/2...')
	trp_s=as.integer(readLines(con_s,p2_sz))
	st2hd_s=Ent[trp_s[ST2_order]]
    rm(trp_s)
	gc()
	print('getting getTripleSet 2/2 p...')
	trp_p=as.integer(readLines(con_p,p2_sz))
	st2hd_p=Ent[trp_p[ST2_order]]
	rm(trp_p)
	gc()
	print('getting getTripleSet 2/2 o...')
	trp_o=as.integer(readLines(con_o,p2_sz))
	st2hd_o=Ent[trp_o[ST2_order]]
	rm(trp_o)
	gc()
	
	close(con_s)
	close(con_p)
	close(con_o)
 	Tmp=rbind(cbind(set=1,Sn_order,val=Snhd_val,txt=Ent[Sn_order]),
			  cbind(set=2,ST1_order,val=ST1hd_val,txt=paste(st1hd_s,st1hd_p,st1hd_o,sep=':')),
			  cbind(set=3,ST2_order+p1_sz,val=ST2hd_val,txt=paste(st2hd_s,st2hd_p,st2hd_o,sep=':')) )
	hd_order=order(as.numeric(Tmp[,'val']),decreasing=TRUE)
	tmp_hd=cbind(Tmp[hd_order,'txt'],Tmp[hd_order,'val'])
	print(paste0("Saving head:",3*hd_sz," ",format(Sys.time(), "%a %b %d %X %Y")))
	write.csv(file=paste(savepath , "top_ranks_" , name , "_HARE.csv",sep=''),tmp_hd,row.names=FALSE)
	
	###-----------------------------------------###
	print('ok')