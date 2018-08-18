# 19/4/2018
*Two limits on sparse matrices in R on 64-bit machines
	1- The number of rows/columns must be less than(2^31)
	2- The number of nonzeros must be less than (2^31)
The order of operations:
1-ParseNT.JAR in three iterations

2-wd_FW.R: finds P=F*W(Alpha x Alpha) in forms of chunks (105*25M), Alpha~=479M

3-wd_FW20.R: combines(adds) each 20 chunks together from two combined 10 chunks.

4-wd_FW40+0.1R: combines(adds) each 40 chunks together from two combined 20 chunks from previous step.
			Used different sizes of chunks because the density of P differs(higher density at start)
			divide P into two parts: P1 and P2 with P1 more dense(1 - 100M, 100M+1 to end) 

5-wd_FW105p1.R: P1 into 10 chunks(10M each)

6-wd_FW105p2.R: P2(379M) in 4 chunks (11 to 14, 100M each)

7-wd_calc_P_T.R: calculate transpose of P, into 10 chunks
				each of the 14 chunks is read to calc one chunk.

8-wd_hare.R: the matrix multiplication of P^T is done in chunks and mapped to ranges in Sn.

9-wd_calc_ST.R calculate the ranking of the triples.

####
Parsing the nt file of 322GB(2.6B triples)
A java program was used to form an entity dictionary. The triples are saved as three files one for subject, one for predicate and one for object.
The files contains indix values to the Entity dictionary. Also a fifth file contains the count for each entity.
The parsing for Wikidata dataset was done in three iterations, one for non-literal resources and two for literals(length less than 36 characters and others). 
Implementation details: HashMap<String, Integer> is used.
What was not done is the removal of duplicate triples.
--------------------------------
Calculating FW:
the straight forward calculation of F and W matrices of Wikidata graph won't work in R because the number of rows of F 
(equals the number of columns of W) is more than 2.6B which is more than the limit(2^31).
Since F and W are needed to calculate the transition matrix P=FW which has the dimensions(Alpha x Alpha) and Alpha is about 479M which is affordable in R,
we calculated P directly for horizontal chunks as follows:
input:
output:
  ChnkLen=25M#// matrix multiplication limit
  NChnks=105;#// 2.6B/25M
  E_cnt <- counts for each entity
  for starting_ch=1; starting_ch <= Nchnks; starting_ch+=10){
	  FW =sparse matrix with dim (Alpha x Alpha) of zeros
	  for( ch=1;ch<=10 && ((starting_ch+ch-1) <= Nchnks);ch++){
			F_ch=sparse matrix with dim (Alpha x ChnkLen) of zeros
			W_ch=sparse matrix with dim (ChnkLen x Alpha) of zeros
			
			S_ch <- read chunck from subject file
			W_ch[1:ChnkLen,S_ch indexes]=1.0/3
			F_ch[S_ch,1:ChnkLen]=1.0/E_cnt[S_ch]#// for the last iteration in stead of ChnkLen use no of triples
			do the same for predicate and object files.
			
			FW = FW + F_ch * W_ch
			
	  }
	  save(FW to file)
  }
  
 ----------------------------------------
 3-combines(adds) each 20 chunks together from two combined 10 chunks.
	After this step P(FW) is contained in 6 files
 4-combines(adds) each 40 chunks together from two combined 20 chunks from previous step.
			Divided P into two parts: P1 and P2 with P1 more dense(1 - 100M, 100M+1 to end).
			This is because of the parsing scheme, from index 118M to 479M are literals, having low density in FW.
	After this step P(FW) is contained in 6 files	
5-using the three files containing P1 from previous step, calculate the final P! by adding horizontal chunks from the three files.
The output is made into 10 chunks (10M each) and saved into 10 files.

6-similarly P2 is saved to 4 chunks, now the total number of chunks of P is 14 containing bands of final P.

7-calculate transpose of P, and save it into 10 files.
				To do that each of the 14 is read (one at a time)to calculate one part of one horizontal chunk in P^T.
			The sizes of the chunks is different because of the different density of P^T so that the limit of max(2^31)nonzeros won't be hit.
	NChnksP_T <-10
	NChnksP <-14
	for(t_ch in 1:NChnksP_T){
    	col_st=1
		PTch = sparse matrix, dim (size of t_ch, Alpha)#Horizontal chunk of P^T
		for(ch in 1:NChnksP){
			Pch<-read chunk from file
			
			index_st  = ifelse(t_ch==1,1,1+sum(tch_sz[1:(t_ch-1)]))
			index_end = sum(tch_sz[1:t_ch])
			tmp=t(Pch)#transpose
			tmp=tmp[index_st:index_end,]
			col_end= col_st + nrow(Pch)-1
			tmp=methods::as(tmp,'TsparseMatrix')#i,j,val
			newj=tmp@j+col_st#from 1 not 0

			tmp=Matrix::sparseMatrix(i=tmp@i+1,j=newj,x=tmp@x,dims=c(tch_sz[t_ch], Alpha))
			
			PTch = PTch + tmp
			col_st = col_end + 1
		}

		Save PTch to file
	}

8-Calculating HARE:

	epsilon=1e-3; damping=0.85; maxIterations=12;
	PTch_all<- read all Pch into list
	while (error > epsilon && ni < maxIterations){
		ni = ni + 1
		tmp = previous
		for(t_ch in 1:NChnks){
			ch_range=start index :end index of chunk t_ch
			previous[ch_range] = damping *(PTch_all[[t_ch]] %*% tmp) + d_ones[ch_range]
		}
		error = norm(as.matrix(tmp - previous),"f")
	}
	
	S_n <- previous

9-calculate the ranking of the triples,
	use chunks to calculate F^T and multiply by S_n and save to one file.
	FTchSn = Matrix::t(F_ch) * S_n
###3
As in algorithm#1
