pageRank_loop <- function(P, epsilon=1e-3, damping=0.85, maxIterations=1000){
  n=nrow(P)
  d_P_T = damping*Matrix::t(P)
  
  stats=NULL
   previous = ones = rep(1,n)/n
	d_ones = (1-damping)*ones
	error = 1
	 #Equation 9
	tic2 = proc.time()
	ni=0
	while (error > epsilon && ni < maxIterations){
		t3=proc.time()
		ni = ni + 1
		tmp = previous
		previous = d_P_T%*%(previous) + d_ones
		error = norm(as.matrix(tmp - previous),"f")
		
		print(sprintf("ni:%d,max index:%d,max:%f,sumSn:%f, error:%e",ni,which.max(as.vector(previous)),max(previous),sum(previous),error));
		
		stats=rbind(stats,cbind(i=ni,error=error,mx=max(previous),whichmx=which.max(as.vector(previous)),itime=(proc.time()-t3)[3]))
	}

return(list(Sn=previous,ni=ni,stats=stats))	
}