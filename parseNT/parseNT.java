/*
 * 25/2/2018
 * To do: only two passes , F&W
 *   form strings from chars
 *   try chuncks of 400Mi then merge and update indexes!!!
 *   	L1:<name,Id>&ind  L2:<name,Id>&ind  L2<name,newID>&newInd
 *   		I.find ids of common names(match), II.make new id for NAs
 *      chnkStart,chnkLen
 */
/* Build
  cd C:\Users\Abdelmonem\Dropbox\Java\ec-workspace\parseNT\src
 
 javac -target 1.7 parseNT\parseNT.java -source 1.7 -bootclasspath D:\RDF\rt.jar
 jar cvfm parseNT.jar parseNT\manifest.txt parseNT\parseNT.class
 java -jar parseNT.jar sec D:\RDF\ D:\RDF\ParseNT\
  
 */

/* Running Example
 * _:genid316339
	
	sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassI"
	>> printed 460463=(number of lines -1)
	sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassII" 460464 0 35
	>> printed 839920
	sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassII" 839921 36 999999
    >>Ecnt wc-l 866612
     sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "Ecnt" 866612
verify
	sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  verify 866612
	sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  RemGap 46065 1
 */
/*
 * Wikidata
 * prog dataset input_path output_path PassX [Pass Params]
 * java -jar -Xms45G -Xmx60G -XX:GCTimeRatio=40 parseNT_hm3.jar wd022018 /upb/departments/pc2/scratch/desouki/kg/ /upb/departments/pc2/scratch/desouki/ParseNT/wd/ PassI
 * wc -l, 118915653
 * java -jar -Xms45G -Xmx80G -XX:GCTimeRatio=40 parseNT_hm3.jar wd022018 /upb/departments/pc2/scratch/desouki/kg/ /upb/departments/pc2/scratch/desouki/ParseNT/wd/ PassII 118915654 0 35
 * 
 * java -jar -Xms45G -Xmx80G -XX:GCTimeRatio=40 parseNT_hm3.jar wd022018 /upb/departments/pc2/scratch/desouki/kg/ /upb/departments/pc2/scratch/desouki/ParseNT/wd/ PassII 338145116 36 999999
 */

package parseNT;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.Set;
import java.util.TreeSet;

public class parseNT {
	public static void main(String[] args) {
//		sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"
		String ds_name="org_dogfood_names";
		String loadpath="D:\\RDF\\";
		String savepath="D:\\RDF\\parseNT\\";
		boolean LoadEnt=false;
		boolean removeDuplictes=false;
				
		if(args.length >2 ) { 
			ds_name=args[0];
			loadpath=args[1];
			savepath=args[2];
		}else {
			System.out.println("Usage: <jarfile> dataset loadpath savepath hm [sn st_L end_L]");
//			System.out.println("Usage: <jarfile> dataset loadpath savepath loadEnt/defEnt [removeDuplictes/ignoreDublicates]");
			System.exit(1);
		}
		String filename= loadpath + ds_name + ".nt";
		System.out.println("Parsing:"+filename+" ...");
		long stTime=System.currentTimeMillis(),endTime=System.currentTimeMillis();
//		System.out.println("ars:"+args[3]);
//		if(args.length > 3 && args[3].equals("loadEnt")) LoadEnt=true;
//		if(args.length > 4 && args[4].equals("removeDuplictes")) removeDuplictes=true;
		//removeDuplicates
		int nEnt=0;
//		System.out.println("removeDuplicates & get E cnt");
		if(args.length > 3 && args[3].equals("Full")) {
			System.out.println("Parse full.");
			parse_full(ds_name,loadpath,savepath,filename);
			System.exit(0);
		}
		if(args.length > 4 && args[3].equals("Ecnt")) {
			System.out.println("get E cnt");
			nEnt=Integer.parseInt(args[4]);
			parseNT_get_Ecnt_ind(savepath+ds_name+"_s.txt",
				savepath+ds_name+"_p.txt",savepath+ds_name+"_ol.txt",savepath+ds_name,nEnt);
			endTime=System.currentTimeMillis();
			System.out.println("time geting counts:"+(endTime-stTime));
			System.out.println("Ok.");
			System.exit(0);
		}
		//System.exit(0);
		
		//System.out.println(LoadEnt);
		
		//verify
        if(args.length > 4 && args[3].equals("verify")) {
            System.out.println("Verifying nt parsing.");
            nEnt=Integer.parseInt(args[4]);
            parseNT_verify(filename,savepath+ds_name+"_Ent.txt",savepath+ds_name+"_s.txt",
                    savepath+ds_name+"_p.txt",savepath+ds_name+"_ol.txt",nEnt);
            endTime=System.currentTimeMillis();
            System.out.println("");
            System.exit(0);
        }
      //verify
        if(args.length > 4 && args[3].equals("RemDuplSorted")) {
            System.out.println("Remove duplicate.");
            nEnt=Integer.parseInt(args[4]);
            parseNT_verify(filename,savepath+ds_name+"_Ent.txt",savepath+ds_name+"_s.txt",
                    savepath+ds_name+"_p.txt",savepath+ds_name+"_ol.txt",nEnt);
            endTime=System.currentTimeMillis();
            System.out.println("");
            System.exit(0);
        }
		/*STATS
		parseNT_stats(filename,savepath+ds_name);//Stats
		long t2=System.currentTimeMillis();
		parseNT_stats2(filename,savepath+ds_name);
		endTime=System.currentTimeMillis();
		System.out.println("time st:"+(t2-stTime)+", time st2:"+(endTime-t2));
		System.exit(0);
		*/
		//PARSING
		stTime = System.currentTimeMillis();
		int st_sn=0,st_L=0,end_L=35;
		if(args.length > 6 && args[3].equals("PassII")) {
			st_sn=Integer.parseInt(args[4]);
			st_L=Integer.parseInt(args[5]);
			end_L=Integer.parseInt(args[6]);
			System.out.println("parseNT_ltr");
			parseNT_ltr(filename,savepath+ds_name,st_sn,st_L,end_L);
			System.exit(0);
		} ;
		
		if(st_sn==0 && args[3].equals("PassI")) {
			System.out.println("Pass I");
			Object[] res=parseNT_hm3(filename,savepath+ds_name);
			nEnt=(int) res[1];
			System.out.println("nEnt:"+nEnt);
			st_sn=nEnt+1;
		}
		
		if(st_sn==0 && args[3].equals("RemGap")) {
			System.out.println("Removing Gap..");
			long gap_st=Integer.parseInt(args[4]);
			int gap_len=Integer.parseInt(args[5]);
			remove_gap(filename,savepath+ds_name,gap_st,gap_len);
		}else {
			System.out.println("Unknown parameters.");
		}
		endTime = System.currentTimeMillis();
//		 long t2 = System.currentTimeMillis();
		
		System.out.println("get hm3 time: "+(endTime-stTime));
//		benchmark_readers(filename);
//		System.exit(0);

		/*stTime = System.currentTimeMillis();
		Object[] obj=parseNT_passI(filename,savepath+ds_name);
//		Object[] obj=getTriples_ind_hm(filename,savepath+ds_name,removeDuplictes);
		long nli=(long)obj[0];
		 nEnt=(int)obj[1];
//		long ntrp=(long)obj[2];
		endTime = System.currentTimeMillis();
		System.out.println("get Triples ind Time: "+(endTime-stTime));

		System.out.println("# Lines:"+nli+", # Entities:" + nEnt);//+", # unique triples:"+ntrp);
*/		
	   System.out.println("Ok.");
	}
		//-------------------------------------------
	public static void parse_full(String ds_name,String loadpath,String savepath,String filename) {
		
		int nEnt=0,st_sn=0;
		System.out.println("Pass I, parse objects");
		Object[] res=parseNT_hm3(filename,savepath+ds_name);
		nEnt=(int) res[1];
		System.out.println("nEnt:"+nEnt);
		st_sn=nEnt+1;
		
		System.out.println("Pass II, parse literals");
		Object[] res2=parseNT_ltr(filename,savepath+ds_name,st_sn,0,999999);
		nEnt=(int) res2[1];
		
		System.out.println("get counts");
		parseNT_get_Ecnt_ind(savepath+ds_name+"_s.txt",
				savepath+ds_name+"_p.txt",savepath+ds_name+"_ol999999.txt",savepath+ds_name,nEnt+1);
		System.out.println("Ok.");
	}
	//-------------------------------------------
	public static long linecount(String filename) throws IOException {
	    InputStream is = new BufferedInputStream(new FileInputStream(filename));
	    try {
	        byte[] c = new byte[1024*1024];
//	        byte[] s = 
	        long count = 0;
	        int readChars = 0;
	        boolean endsWithoutNewLine = false;
	        while ((readChars = is.read(c)) != -1) {
	            for (int i = 0; i < readChars; ++i) {
	                if (c[i] == '\n')
	                    ++count;
	            }
	            endsWithoutNewLine = (c[readChars - 1] != '\n');
	        }
	        if(endsWithoutNewLine) {
	            ++count;
	        } 
	        return count;
	    } finally {
	        is.close();
	    }
	}
	//---------------------------------------------------------------------
		public static Object[] getTriples_ind_hm(String filename,String ofname,boolean removeDuplictes) {
			/* Input: stream of triples (lines)
			 * Output: entities file(_Ent) +3 index files _s,_p,_o + counts(_E_cnt)
			 */
    		//int[] E_cnt=new int[Ent.length];
			ArrayList<Integer> E_cnt=new ArrayList<Integer>();
    		Map<String, Integer> entities=new HashMap<String, Integer>();// to check duplicate triples
    		//TreeSet<String> trpc=new TreeSet<String>();// to check duplicate triples
    		HashSet<String> trpc=new HashSet<String>();
       		long t1 = System.currentTimeMillis();
    		long t2 = System.currentTimeMillis();
    		System.out.println("time:"+(t2-t1));
    		long li=0;//line index
    		int nEnt=0;
    		
    		long ri=0;// triple index
			try{
			    Scanner input = new Scanner(new File(filename),"UTF-8");
			    System.out.println("Writing triples to: " + ofname + "_x");
				
				PrintWriter sout = new PrintWriter(new FileWriter(ofname+"_s.txt"));
				PrintWriter pout = new PrintWriter(new FileWriter(ofname+"_p.txt"));
				PrintWriter oout = new PrintWriter(new FileWriter(ofname+"_o.txt"));
			
			  while (input.hasNextLine()) {
		        	String line=input.nextLine();
		        	li++;
				  if(li%100000==0) {
					  t2 = System.currentTimeMillis();
					  System.out.println(li+":t="+(t2-t1));
					  t1 = System.currentTimeMillis();
				   }	
				//subject
	        	String[] st=line.split(" ");
	        	if(st.length < 4) continue;// wrong triple
	        	int x=indexEnt(st[0],entities);
	        	int s=x;
	        	//predicate
	        	x=indexEnt(st[1],entities);
		        int p=x;
		        //Object
	        	String o=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
	        	x=indexEnt(o,entities);		        
		     
	        	// remove duplicated rows
			        if(removeDuplictes) {
		        	String rowhash=String.format("%d,%d,%d", s,p,x);
			        
			        if(!trpc.add(rowhash)) {
			        	//System.out.println("Line:" + i +" S:" + s +" P:"+ p +" O:"+x+" hash:"+rowhash);
			        	continue;
			        }
			        }
			        //write triple
			        sout.println(s);
			        pout.println(p);
			        oout.println(o);
			        ri++;
		//	        E_cnt[x]++;E_cnt[s]++;E_cnt[p]++;
		/*	        if(E_cnt.size()<s)E_cnt.set(s,E_cnt.get(s)+1);
			        else E_cnt.add(1);
			        if(E_cnt.size()<p)E_cnt.set(p,E_cnt.get(p)+1);
			        else E_cnt.add(1);
			        if(E_cnt.size()<x)E_cnt.set(x,E_cnt.get(x)+1);
			        else E_cnt.add(1);*/
	        	//System.out.println("S:"+ s +'\n' + "P:" + p +'\n' + "Obj:" + o);
	        }
//	        ##Calc EntCount
			  System.out.println("Saving Entities...");
			  PrintWriter eout = new PrintWriter(new FileWriter(ofname+"_Ent.txt"));
			  String[] Ent=new String[entities.size()];
			  for(Map.Entry<String,Integer> e: entities.entrySet()) Ent[e.getValue()]=e.getKey();
			  for(String e:Ent) eout.println(e);
			  nEnt =Ent.length;
			  System.out.println("Saving Entities counts...");
			  PrintWriter cntout = new PrintWriter(new FileWriter(ofname+"_E_cnt.txt"));
			  for(int e:E_cnt) cntout.println(e);
	       input.close(); 
	       sout.close(); 
	       pout.close(); 
	       oout.close(); 
	       eout.close(); 
	       cntout.close(); 
		}catch(IOException e) {
				System.out.println("Failed to open file. ");
				e.printStackTrace();
			}
			
		return new Object[]{li,nEnt, ri};//ri:number of distinct triples
	}
	//--------------------------------------
	public static Integer indexEnt(String fld,Map<String,Integer> entities) {
			if(entities.containsKey(fld)) {
				return entities.get(fld);
			}else {
				int id=entities.size();
				entities.put(fld,id);
				return id;//entities.get(fld);
			}
		}
	//-------------------------------------------------------------------------
	public static Integer indexEnt3(String fld,Map<String,Integer> entities,int id) {
		if(entities.containsKey(fld)) {
			return entities.get(fld);
		}else {
			entities.put(fld,id);
			return id;//entities.get(fld);
		}
	}
		//---------------------------------------------------------------------
			public static Object[] parseNT_hm3(String filename,String ofname) {
				/*
				 * find length distn of Entities s,p,o 1024
				 * #lines
				 */ 	
				        Runtime rt = Runtime.getRuntime();
			       		long t1 = System.currentTimeMillis();
			    		long t2 = System.currentTimeMillis();
			    		long li=0;//line index
			    		int o=0;
			    		int skipped=0;
			    		int nEnt=0;
			    		//ArrayList<Map<String, Integer>> Ent=new ArrayList<Map<String, Integer>>();
			    		Map<String, Integer> sm=new HashMap<String, Integer>(2^30);
			    		Map<String, Integer> olm=new HashMap<String, Integer>(8);//Literals
			    		int sn=1;//id of next Ent
			    		o=indexEnt3("<Literal>",olm,0);//place holder for all literals
						   try {
//								BufferedReader reader = new BufferedReader(	new FileReader(filename));
							   Scanner input = new Scanner(new File(filename),"UTF-8");
//							    String line;
							    System.out.println("Writing triples to: " + ofname + "_x");
								
							    PrintWriter sout = new PrintWriter(new FileWriter(ofname+"_s.txt"));
								PrintWriter pout = new PrintWriter(new FileWriter(ofname+"_p.txt"));
								PrintWriter oout = new PrintWriter(new FileWriter(ofname+"_o.txt"));
								
//							    while ((line = reader.readLine()) != null) {
								while (input.hasNextLine()) {
						        	String line=input.nextLine();
							    	li++;
									  if(li%100000==0) {
										  long total = rt.totalMemory();
									      long free = rt.freeMemory();
										  t2 = System.currentTimeMillis();
										  System.out.println(li+":t="+(t2-t1)+" sn:"+sn+", sm:"+sm.size()
										  +",olm:"+olm.size()+", Total mem: " + total/(1024*1024) +
							                ", Used: " +(total-free)/(1024*1024)+" MB");
										  t1 = System.currentTimeMillis();
									   }	
									//subject
						        	//String[] st=line.split(" ");
									  int i1=line.indexOf(' ');
									  int i2=line.indexOf(' ',i1+1);
										 
							        if(i2 < 0) {
						        		skipped++;
						        		continue;// wrong triple
						        	}
//						        	if(st.length < 4) {  		skipped++;      		continue;// wrong triple     	}
							        String subj=line.substring(0, i1);
							        String prd=line.substring(i1+1, i2);
						        	int s=indexEnt3(subj,sm,sn);
						        	if(s==sn) sn++;
						        	//predicate						        	
						        	int p=indexEnt3(prd,sm,sn);
						        	if(p==sn) sn++;
						        	//Object
						        	String os;
						        	if(line.charAt(i2+1) !='\"') { //add to subj
						        		//os=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
						        		os=line.substring(i2+1, line.length()-2);
						        		o=indexEnt3(os,sm,sn);
						        		if(o==sn) sn++;
						        	} else {
						        		o=0;// index for Literals
						        	}
						        	sout.println(s);
							        pout.println(p);
							        oout.println(o);
							        
						        }
//							    reader.close();
								input.close();
							    sout.close(); 
							    pout.close(); 
							    oout.close(); 
							       
						    }catch(IOException e) {
								System.out.println("Failed to open file ");
							}
						   
						   System.out.println("Saving Entities...");
							 try { PrintWriter eout = new PrintWriter(new FileWriter(ofname+"_Ent.txt"));
							  String[] Ent=new String[sm.size()+olm.size()];
							  for(Map.Entry<String,Integer> e: sm.entrySet()) Ent[e.getValue()]=e.getKey();
							  for(Map.Entry<String,Integer> e: olm.entrySet()) Ent[e.getValue()]=e.getKey();
							  for(String e:Ent) eout.println(e);
							  nEnt =Ent.length-1;//Exclude Literal(0) Ent
							  System.out.println("#Entities:"+nEnt);
							  System.out.println("#new Entities:"+nEnt+", skipped:"+skipped);
							/*try {  System.out.println("Saving counts...");
							  PrintWriter stout = new PrintWriter(new FileWriter(ofname+"_st.txt"));
							 for(int i=0;i<=maxLen+1;i++) stout.println(i+","+sl[i]+","+pl[i]+","+ol[i]);
					          stout.close(); */
							  eout.close();
						}catch(IOException e) {
								System.out.println("Failed to open output file. ");
								e.printStackTrace();
							}
							
						return new Object[]{li,nEnt,skipped};//ri:number of distinct triples

						}   
//---------------------------------------------------------------------
		
			public static long remove_gap(String filename,String ofname,long gap_st,int gap_len) {
			/*
			 * removes gap in .ol file identified by start and length
			 * subtract gap_len from indexes>=gap_st
			 * 		 */ 	
		    Runtime rt = Runtime.getRuntime();
			long t1 = System.currentTimeMillis();
			long t2 = System.currentTimeMillis();
			long li=0;//line index
			
			long cntchanged=0;
						
			   try {
				    System.out.println("Writing triples to: " + ofname + "_x");
					String srcfname,destfname;
				    srcfname=ofname+"_ol.txt";				   
					
				    destfname=ofname + "_olg" + gap_st + ".txt";
//						BufferedReader no_ltr = new BufferedReader(	new FileReader(srcfname));
				    	Scanner olf= new Scanner(new File(srcfname),"UTF-8");
						PrintWriter oout = new PrintWriter(new FileWriter(destfname));
					while (olf.hasNextLine()) {
				    	  li++;
				    	  String os = olf.nextLine();
				    	  long indx=Long.parseLong(os);
						  if(li%100000==0) {
							  long total = rt.totalMemory();
						      long free = rt.freeMemory();
							  t2 = System.currentTimeMillis();
							  System.out.println(li+":t="+(t2-t1)+", Total mem: " + total/(1024*1024) +
				                ", Used: " +(total-free)/(1024*1024)+" MB");
							  t1 = System.currentTimeMillis();
						   }	
			        	//Object
			        	if(indx>=gap_st) {
			        		indx=indx-gap_len;
			        		oout.println(indx);
//			        		cntchanged++;
			        	} else {
			        		oout.println(os);// read from passI
			        	}
			        	
			        }
				    
				    oout.close(); 
				    olf.close();  
			    }catch(IOException e) {
					System.out.println("Failed to open file ");
				}
			     
//			}catch(IOException e) {
//					System.out.println("Failed to open output file. ");
//					e.printStackTrace();
//				}
//				
		return(cntchanged);
		}
			//---------------------------------------------------------------------
			
			public static Object[] parseNT_ltr(String filename,String ofname,int st_sn,int st_L,int end_L) {
			/*
			 * finds indexes of literals according to there length(in range)
			 * #lines
			 */ 	
		    Runtime rt = Runtime.getRuntime();
			long t1 = System.currentTimeMillis();
			long t2 = System.currentTimeMillis();
			long li=0;//line index
			long trpcnt=0;
			int o=0;
			int skipped=0,nEnt=0;
			Map<String, Integer> olm=new HashMap<String, Integer>(2^30);//Literals
			//final int st_sn=0;
			int sn=st_sn;//id of next Ent
			//o=indexEnt3("<Literal>",olm,0);
			   try {
//					BufferedReader reader = new BufferedReader(	new FileReader(filename));
				   Scanner input = new Scanner(new File(filename),"UTF-8");
//				    String line;
				    System.out.println("Writing triples to: " + ofname + "_x");
					String srcfname,destfname;
				    if(st_L==0) {
					   srcfname=ofname+"_o.txt";				   
					}else {
						srcfname=ofname+"_ol"+(st_L-1)+".txt";
					}
				    destfname=ofname + "_ol" + end_L + ".txt";
//						BufferedReader no_ltr = new BufferedReader(	new FileReader(srcfname));
				    	Scanner no_ltr= new Scanner(new File(srcfname),"UTF-8");
						PrintWriter oout = new PrintWriter(new FileWriter(destfname));
					
//				    while ((line = reader.readLine()) != null) {
					while (input.hasNextLine()) {
				        	String line=input.nextLine();
				    	  li++;
				    	  String os = no_ltr.nextLine();
						  if(li%100000==0) {
							  long total = rt.totalMemory();
						      long free = rt.freeMemory();
							  t2 = System.currentTimeMillis();
							  System.out.println(li+":t="+(t2-t1)+" sn:"+sn+",olm:"+olm.size()+", Total mem: " + total/(1024*1024) +
				                ", Used: " +(total-free)/(1024*1024)+" MB");
							  t1 = System.currentTimeMillis();
						   }	
						//subject
			        	  int i1=line.indexOf(' ');
						  int i2=line.indexOf(' ',i1+1);
							 
				        if(i2 < 0 || !(line.charAt(0) =='<' || line.charAt(0) =='_') ) {
			        		skipped++;
			        		continue;// wrong triple
			        	}
			        	//Object
			        	if(line.charAt(i2+1) =='\"' && (line.length()-i2) >=st_L && (line.length()-i2) <= end_L) { //short literals
			        		os=line.substring(i2+1, line.length()-2);
			        		o=indexEnt3(os,olm,sn);
			        		if(o==sn) sn++;
			        		oout.println(o);
			        	} else {
			        		oout.println(os);// read from passI
			        	}
			        	
			        }
				    input.close();
				    oout.close(); 
				    no_ltr.close();  
			    }catch(IOException e) {
					System.out.println("Failed to open file ");
				}
			   
			   System.out.println("Saving Entities...");
				 try { PrintWriter eout = new PrintWriter(new FileWriter(ofname+"_Ent.txt",true));
				  String[] Ent=new String[olm.size()];
				  for(Map.Entry<String,Integer> e: olm.entrySet()) Ent[e.getValue()-st_sn]=e.getKey();
				  for(String e:Ent) eout.println(e);
				  nEnt =Ent.length;
				  System.out.println("#new Entities:"+nEnt+" #total entities: "+(st_sn+nEnt-1)+", #skipped:"+skipped);
				/*try {  System.out.println("Saving counts...");
				  PrintWriter stout = new PrintWriter(new FileWriter(ofname+"_st.txt"));
				 for(int i=0;i<=maxLen+1;i++) stout.println(i+","+sl[i]+","+pl[i]+","+ol[i]);
		          stout.close(); */
				  eout.close();
				  
			}catch(IOException e) {
					System.out.println("Failed to open output file. ");
					e.printStackTrace();
				}
				
			return new Object[]{li,st_sn+nEnt-1,nEnt};//ri:number of distinct triples
		
		}
		
	//--------------------------------------------------------------------	
	public static void parseNT_verify(String filename,String Entfname,String s_fname,String p_fname,String o_fname,int maxEnt) {
		String[] Ent=new String[maxEnt];//max Ents
		
		int li=0;
		long lino=0;
		   try {
//				BufferedReader ent_reader = new BufferedReader(	new FileReader(Entfname));
			   Scanner input = new Scanner(new File(Entfname),"UTF-8");
			   Scanner nt_reader = new Scanner(new File(filename),"UTF-8");
			   String line;
			    
			    Runtime rt = Runtime.getRuntime();
				long total,free,t2,t1=System.currentTimeMillis();
				System.out.println("Reading Entities list..."+Entfname);
//			    while ((line = ent_reader.readLine()) != null) {
				while (input.hasNextLine()) {
		        	line=input.nextLine();
			    	Ent[li++]=line;
			    	if(li%100000==0) {
						   total = rt.totalMemory();
					       free = rt.freeMemory();
						  t2 = System.currentTimeMillis();
						  System.out.println(li+":t="+(t2-t1)+", Total mem: " + total/(1024*1024) +
			                ", Used: " +(total-free)/(1024*1024)+" MB");
						  t1 = System.currentTimeMillis();
					   }
			    };
			  //  int nEnt=li;
			    input.close();
			    t2=System.currentTimeMillis();
			    System.out.println(" # Entities:"+li+" reading time:"+(t2-t1));
			    //long[] cnts=new long[nEnt];
			    
//			    BufferedReader nt_reader = new BufferedReader(	new FileReader(filename));
			   
			    BufferedReader s_reader = new BufferedReader(	new FileReader(s_fname));
			    BufferedReader p_reader = new BufferedReader(	new FileReader(p_fname));
			    BufferedReader o_reader = new BufferedReader(	new FileReader(o_fname));
			    
//			    while ((line = nt_reader.readLine()) != null) {
			    while (nt_reader.hasNextLine()) {
		        	line=nt_reader.nextLine();
			    	lino++;
//			    	int i1=line.indexOf(' ');
//					int i2=line.indexOf(' ',i1+1);
//					String ostr=line.substring(i2+1, line.length()-2);
			    	if(lino%100000==0) {
						  total = rt.totalMemory();
					      free = rt.freeMemory();
						  t2 = System.currentTimeMillis();
						  System.out.println(lino+":t="+(t2-t1)+", Total mem: " + total/(1024*1024) +
			                ", Used: " +(total-free)/(1024*1024)+" MB, verified");
						  t1 = System.currentTimeMillis();
					   }
			    	int si=Integer.parseInt(s_reader.readLine());
			    	int pi=Integer.parseInt(p_reader.readLine());
			    	int oi=Integer.parseInt(o_reader.readLine());
		    	//if(oi>460464)oi=oi-1;
			    	StringBuilder nl=new StringBuilder(Ent[si]).append(' ').append(Ent[pi])
			    			.append(' ').append(Ent[oi]).append(" .");
			    	if(!nl.toString().equals(line)) {
			    		System.out.println("Mismatch: line #:"+lino+"\nnt:"+line+"\n spo:"+nl+
			    			"\n"+si+","+pi+","+oi);
			    		System.exit(1);
			    		};
			    }
			    nt_reader.close();
			    s_reader.close();
			    p_reader.close();
			    o_reader.close();
			    System.out.println("Parsing was verified for:"+lino+" triples.");
				}catch(IOException e) {
					System.out.println("Failed to open input file. "+"li:"+lino+"\n"+filename+"'\n"+Entfname);
					e.printStackTrace();
				}
	}
	//--------------------------------------------------------------------	
	public static void parseNT_RemDupl_Ecnt(String s_fname,String p_fname,String o_fname,String ofname,int maxEnt) {
		// ofname: name for files containing unique triples
			long[] E_cnt=new long[maxEnt];//max Ents
			//HashSet<StringBuilder> trpc=new HashSet<StringBuilder>(2^30);//size is int, will not work for wd
			/* ideas
			 * hashcode for lines write a duplicated list then investigate.
			 * 2- write to file and use awk tool then re-parse
			 * 3- Approximate: store in memory up to 2^30 truncate if full
			 * 4- List of HashSets, once full add a new one, to add srch ib all at first
			 * */
			HashMap<Integer,HashMap<Integer,HashSet<Integer>>> P=new HashMap<Integer,HashMap<Integer,HashSet<Integer>>>();
			
			long duplicated_cnt=0;
			int li=0;
			   try {
				    Runtime rt = Runtime.getRuntime();
					long total,free,t2,t1=System.currentTimeMillis();
				    //long[] cnts=new long[nEnt];
				    
			//	    BufferedReader nt_reader = new BufferedReader(	new FileReader(filename));
				    BufferedReader s_reader = new BufferedReader(	new FileReader(s_fname));
				    BufferedReader p_reader = new BufferedReader(	new FileReader(p_fname));
				    BufferedReader o_reader = new BufferedReader(	new FileReader(o_fname));

				    String sline;//,pline,oline;
				    while ((sline = s_reader.readLine()) != null) {
				    	li++;
				    	if(li%100000==0) {
							  total = rt.totalMemory();
						      free = rt.freeMemory();
							  t2 = System.currentTimeMillis();
							  System.out.println(li+":t="+(t2-t1)+", Prd size:"+P.size()+", Total mem: " + total/(1024*1024) +
				                ", Used: " +(total-free)/(1024*1024)+" MB");
							  t1 = System.currentTimeMillis();
							  /*if(trpc.size()==(2^30)) {
								  System.out.println("Clearing HashSet..."+(nClears++));
								  trpc.clear();
								  System.out.println("# triples:"+li+", # duplicated triples:"+duplicated_cnt+", # Clears:"+nClears+".");
							  }*/
						   }
				    	int si=Integer.parseInt(sline);
				    	int pi=Integer.parseInt(p_reader.readLine());
				    	int oi=Integer.parseInt(o_reader.readLine());
				    	
//				    	String rowhash=String.format("%s,%s,%s", sline,pline,oline);
				    	//StringBuilder rowhash=new StringBuilder(sline).append(',').append(pline).append(',').append(oline);
				        if(P.containsKey(pi)) {
				        	HashMap<Integer,HashSet<Integer>> subjects=P.get(pi);
				        	if(subjects.containsKey(si)) {
					        	 if(!subjects.get(si).add(oi)) duplicated_cnt++;
				        	}else {
				        		HashSet<Integer> objects=new HashSet<Integer>();
				        		objects.add(oi);
				        		subjects.put(si,objects);
					        }
				        }else {
				        	HashMap<Integer,HashSet<Integer>> subjects=new HashMap<Integer,HashSet<Integer>>();
				        	HashSet<Integer> objects=new HashSet<Integer>();
			        		objects.add(oi);
			        		subjects.put(si,objects);
			        		P.put(pi,subjects);
				        }
				        /*if(!trpc.add(rowhash)) {//already there
				        	//System.out.println("Line:" + i +" S:" + s +" P:"+ p +" O:"+x+" hash:"+rowhash);
				        	duplicated_cnt++;
				        	continue;
				        }*/
				        //adjust counts
				        E_cnt[si]++;E_cnt[pi]++;E_cnt[oi]++;
				        
				    }
				 // write out
				    System.out.println("\n======= Writing file ...");
				    PrintWriter sout = new PrintWriter(new FileWriter(ofname+"_su.txt"));
					PrintWriter pout = new PrintWriter(new FileWriter(ofname+"_pu.txt"));
					PrintWriter oout = new PrintWriter(new FileWriter(ofname+"_ou.txt"));
					long nt=0;
					
				    for(Map.Entry<Integer,HashMap<Integer,HashSet<Integer>>> p: P.entrySet()) {
				    	for(Map.Entry<Integer,HashSet<Integer>> s: p.getValue().entrySet()) {
				    		for(Integer o: s.getValue()) {
				    			nt++;
						    	sout.println(s.getKey());
						        pout.println(p.getKey());
						        oout.println(o);
						        if(nt%100000==0) {
									  total = rt.totalMemory();
								      free = rt.freeMemory();
									  t2 = System.currentTimeMillis();
									  System.out.println(nt+":t="+(t2-t1)+", Total mem: " + total/(1024*1024) +
						                ", Used: " +(total-free)/(1024*1024)+" MB");
									  t1 = System.currentTimeMillis();
						        }
				    		}
				    	}
				    }
				    s_reader.close();
				    p_reader.close();
				    o_reader.close();
				    sout.close(); 
				    pout.close(); 
				    oout.close(); 
				    System.out.println("Saving Entities counts...");
				    PrintWriter cntout = new PrintWriter(new FileWriter(ofname+"_E_cnt.txt"));
				    for(long e:E_cnt) cntout.println(e);
				    cntout.close(); 
				    System.out.println("# triples:"+li+", # duplicated triples:"+duplicated_cnt+", # uniq triples:"+nt+", Prd size:"+P.size()+".");
				}catch(IOException e) {
							System.out.println("Failed to open output file. "+"li:"+li);
							e.printStackTrace();
				}
		}
	//--------------------------------------------------------------------	
		public static void parseNT_RemDupl_Ecnt2(String s_fname,String p_fname,String o_fname,String ofname,int maxEnt) {
			// ofname: name for files containing unique triples
				long[] E_cnt=new long[maxEnt];//max Ents
				//HashSet<StringBuilder> trpc=new HashSet<StringBuilder>(2^30);//size is int, will not work for wd
				/* ideas
				 * 4- List of HashSets, once full add a new one, to add srch ib all at first
				 * */
				//HashMap<Integer,HashMap<Integer,HashSet<Integer>>> P=new HashMap<Integer,HashMap<Integer,HashSet<Integer>>>();
				int maxSize=1024*1024*1024;
				ArrayList<Set<String>> mapL=new ArrayList<Set<String>>();				
				Set<String> hs=new HashSet<String>();
				mapL.add(hs);
				
				//hs.contains(o)
				int crntHs=0;
				long duplicated_cnt=0;
				
				int li=0;
				   try {
					    Runtime rt = Runtime.getRuntime();
						long total,free,t2,t1=System.currentTimeMillis();
					    //long[] cnts=new long[nEnt];
					    
				//	    BufferedReader nt_reader = new BufferedReader(	new FileReader(filename));
					    BufferedReader s_reader = new BufferedReader(	new FileReader(s_fname));
					    BufferedReader p_reader = new BufferedReader(	new FileReader(p_fname));
					    BufferedReader o_reader = new BufferedReader(	new FileReader(o_fname));

					    PrintWriter sout = new PrintWriter(new FileWriter(ofname+"_su.txt"));
						PrintWriter pout = new PrintWriter(new FileWriter(ofname+"_pu.txt"));
						PrintWriter oout = new PrintWriter(new FileWriter(ofname+"_ou.txt"));
						
					    String sline,pline=null,oline=null;
					    while ((sline = s_reader.readLine()) != null) {
					    	li++;
					    	if(li%100000==0) {
								  total = rt.totalMemory();
							      free = rt.freeMemory();
								  t2 = System.currentTimeMillis();
								  System.out.println(li+":t="+(t2-t1)+", crntHs:"+crntHs+", HS size:"+mapL.get(crntHs).size()+
										  ", Total mem: " + total/(1024*1024) + ", Used: " +(total-free)/(1024*1024)+" MB");
								  t1 = System.currentTimeMillis();
							   }
					    	int si=Integer.parseInt(sline);
					    	int pi=Integer.parseInt(pline=p_reader.readLine());
					    	int oi=Integer.parseInt(oline=o_reader.readLine());
					    	
					    	StringBuilder rowhash=new StringBuilder(sline).append(',').append(pline).append(',').append(oline);
					    	boolean found=false;
					    	for(int i=0;i <= crntHs;i++) {//srch all inc the last
					    		if(mapL.get(i).contains(rowhash.toString())) {
					    			found=true;
					    			break;
					    		}
					    	}
					        if(found){
					        	duplicated_cnt++;
					        	continue;
					        }else {
					        	if(mapL.get(crntHs).size() >= maxSize) {
					        		// Last set is full
					        		System.out.println("Hash set:"+crntHs+" is full, size:"+mapL.get(crntHs).size()+
					        				", # duplicated triples:"+duplicated_cnt);
					        		crntHs++;
					        		hs=new HashSet<String>();
									mapL.add(hs);
					        	}
					        	mapL.get(crntHs).add(rowhash.toString());// new triple write out
					        	sout.println(sline);
						        pout.println(pline);
						        oout.println(oline);
					        }
					        /*if(!trpc.add(rowhash)) {//already there
					        	//System.out.println("Line:" + i +" S:" + s +" P:"+ p +" O:"+x+" hash:"+rowhash);
					        	duplicated_cnt++;
					        	continue;
					        }*/
					        //adjust counts
					        E_cnt[si]++;E_cnt[pi]++;E_cnt[oi]++;
					        
					    }
    				    s_reader.close();
					    p_reader.close();
					    o_reader.close();
					    sout.close(); 
					    pout.close(); 
					    oout.close(); 
					    System.out.println("Saving Entities counts...");
					    PrintWriter cntout = new PrintWriter(new FileWriter(ofname+"_E_cnt.txt"));
					    for(long e:E_cnt) cntout.println(e);
					    cntout.close(); 
					    System.out.println("# triples:"+li+", # duplicated triples:"+duplicated_cnt+", unique triples:"+(li-duplicated_cnt)+".");
					}catch(IOException e) {
								System.out.println("Failed to open output file. "+"li:"+li);
								e.printStackTrace();
					}
			}
		//---------------------------------------------------------------------
		public static void parseNT_get_Ecnt_ind(String s_fname,String p_fname,String o_fname,String ofname,int maxEnt) {
			// ofname: output filename
				long[] E_cnt=new long[maxEnt];//max Ents
				long li=0;
				   try {
					    Runtime rt = Runtime.getRuntime();
						long total,free,t2,t1=System.currentTimeMillis();
					    BufferedReader s_reader = new BufferedReader(	new FileReader(s_fname));
					    BufferedReader p_reader = new BufferedReader(	new FileReader(p_fname));
					    BufferedReader o_reader = new BufferedReader(	new FileReader(o_fname));

	     			    String sline;
					    while ((sline = s_reader.readLine()) != null) {
					    	li++;
					    	if(li%100000==0) {
								  total = rt.totalMemory();
							      free = rt.freeMemory();
								  t2 = System.currentTimeMillis();
								  System.out.println(li+":t="+(t2-t1)+
										  ", Total mem: " + total/(1024*1024) + ", Used: " +(total-free)/(1024*1024)+" MB");
								  t1 = System.currentTimeMillis();
							   }
					    	int si=Integer.parseInt(sline);
					    	int pi=Integer.parseInt(p_reader.readLine());
					    	int oi=Integer.parseInt(o_reader.readLine());
					    	//adjust counts
					        E_cnt[si]++;E_cnt[pi]++;E_cnt[oi]++;
					        
					    }
    				    s_reader.close();
					    p_reader.close();
					    o_reader.close();
					    System.out.println("Saving Entities counts...");
					    PrintWriter cntout = new PrintWriter(new FileWriter(ofname+"_E_cnt.txt"));
					    for(long e:E_cnt) cntout.println(e);
					    cntout.close(); 
					    System.out.println("# triples:"+li+".");
					}catch(IOException e) {
								System.out.println("Failed to open output file. "+"li:"+li);
								e.printStackTrace();
					}
			}
//---------------------------------------------------------------------

		//------------------------------------------
	public static void parseNT_stats(String filename,String ofname) {
		/*
		 * find length distn of Entities s,p,o 1024
		 * #lines
		 */  final int maxLen=1024;
				long[] sl=new long[maxLen+2];
				long[] pl=new long[maxLen+2];
				long[] ol=new long[maxLen+2];
				long[] ll=new long[maxLen+2];//literals
				
	       		long t1 = System.currentTimeMillis();
	    		long t2 = System.currentTimeMillis();
	    		long li=0;//line index

				   try {
						BufferedReader reader = new BufferedReader(	new FileReader(filename));
					    String line;
					    System.out.println("Writing triples to: " + ofname + "_x");
						
					    while ((line = reader.readLine()) != null) {
					    	li++;
							  if(li%100000==0) {
								  t2 = System.currentTimeMillis();
								  System.out.println(li+":t="+(t2-t1));
								  t1 = System.currentTimeMillis();
							   }	
							//subject
				        	String[] st=line.split(" ");
				        	if(st.length < 4) continue;// wrong triple
				        	if(st[0].length()>maxLen) sl[maxLen]++;
				        	else sl[st[0].length()]++;
				        	if(st[0].length()>sl[maxLen+1])sl[maxLen+1]=st[0].length();
				        	//predicate
				        	if(st[1].length()>maxLen) pl[maxLen]++;
				        	else pl[st[1].length()]++;
				        	if(st[1].length()>pl[maxLen+1]) pl[maxLen+1]=st[1].length();
				        	//Object
				        	String os=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
				        	if(os.charAt(0) !='\"') { 
					        	if(os.length()>maxLen) ol[maxLen]++;
					        	else ol[os.length()]++;
					        	if(os.length()>ol[maxLen+1]) ol[maxLen+1]=os.length();
				        	}else {
				        		if(os.length()>maxLen) ll[maxLen]++;
					        	else ll[os.length()]++;
					        	if(os.length()>ol[maxLen+1]) ll[maxLen+1]=os.length();				        		
				        	}
					    }
					    reader.close();
				    }catch(IOException e) {
						System.out.println("Failed to open file ");
					}
					try {  System.out.println("Saving counts...");
					  PrintWriter stout = new PrintWriter(new FileWriter(ofname+"_st.txt"));
					 for(int i=0;i<=maxLen+1;i++) stout.println(i+","+sl[i]+","+pl[i]+","+ol[i]+","+ll[i]);
			          stout.close(); 
				}catch(IOException e) {
						System.out.println("Failed to open output file. ");
						e.printStackTrace();
					}
					
				//return new Object[]{li,nEnt};//ri:number of distinct triples

				}   
				
	//------------------------------------------
		public static void parseNT_stats2(String filename,String ofname) {
			/*
			 * find length distn of Entities s,p,o 1024
			 * #lines
			 */  final int maxLen=1024;
					long[] sl=new long[maxLen+2];
					long[] pl=new long[maxLen+2];
					long[] ol=new long[maxLen+2];
					long[] ll=new long[maxLen+2];//literals
					
		       		long t1 = System.currentTimeMillis();
		    		long t2 = System.currentTimeMillis();
		    		long li=0;//line index

					   try {
							BufferedReader reader = new BufferedReader(	new FileReader(filename));
						    String line;
						    System.out.println("Writing triples to: " + ofname + "_x");
							
						    while ((line = reader.readLine()) != null) {
						    	li++;
								  if(li%100000==0) {
									  t2 = System.currentTimeMillis();
									  System.out.println(li+":t="+(t2-t1));
									  t1 = System.currentTimeMillis();
								   }	
								//subject
					        	//String[] st=line.split(" ");
								 int i1=line.indexOf(' ');
								 int i2=line.indexOf(' ',i1+1);
								 
					        	if(i2 < 0) continue;// wrong triple
					        	if(i1 > maxLen) sl[maxLen]++;
					        	else sl[i1]++;
					        	if(i1>sl[maxLen+1])sl[maxLen+1]=i1;
					        	//predicate
					        	if((i2-i1)>maxLen) pl[maxLen]++;
					        	else pl[(i2-i1)]++;
					        	if((i2-i1)>pl[maxLen+1]) pl[maxLen+1]=(i2-i1);
					        	//Object xx xxx xxxx . i2=6, len=13 osl=
					        	//String os=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
					        	int osl=line.length()-i2-3;
					        	if(line.charAt(i2+1) !='\"') { 
						        	if(osl > maxLen) ol[maxLen]++;
						        	else ol[osl]++;
						        	if(osl >ol[maxLen+1]) ol[maxLen+1]=osl;
					        	}else {
					        		if(osl > maxLen) ll[maxLen]++;
						        	else ll[osl]++;
						        	if(osl > ol[maxLen+1]) ll[maxLen+1]=osl;				        		
					        	}
						    }
						    reader.close();
					    }catch(IOException e) {
							System.out.println("Failed to open file ");
						}
						try {  System.out.println("Saving counts...");
						  PrintWriter stout = new PrintWriter(new FileWriter(ofname+"_st.csv"));
						 for(int i=0;i<=maxLen+1;i++) stout.println(i+","+sl[i]+","+pl[i]+","+ol[i]+","+ll[i]);
				          stout.close(); 
					}catch(IOException e) {
							System.out.println("Failed to open output file. ");
							e.printStackTrace();
						}
						
					//return new Object[]{li,nEnt};//ri:number of distinct triples

					}   
		//-------------------------------------------------------------------------
		public static Object[] getTriples_ind(String filename,String[] Ent,String[] P_arr,int cnt,boolean removeDuplictes) {
			// use Arrays
			// return 4 vectors, indices for s,p,o and counts of Ent
    		int[][] triples=new int[cnt][3];
    		int[] E_cnt=new int[Ent.length];
    		TreeSet<String> trpc=new TreeSet<String>();// to check duplicate triples
    		int[] P_ind=new int[P_arr.length];// |P|<<|Ent| two speedup calculate once
    	
    		System.out.println("Getting indexes of Predicate.."+P_ind.length);
    		long t1 = System.currentTimeMillis();
    		for(int i=0; i < P_arr.length; i++)	P_ind[i]=Arrays.binarySearch(Ent,P_arr[i]);
    		long t2 = System.currentTimeMillis();
    		System.out.println("time:"+(t2-t1));
    		
    		int ri=0;// row index
			try{
			Scanner input = new Scanner(new File(filename),"UTF-8");
	   	    
			for(int i = 0; i < cnt; i++) {
				if(i%100000==0) {
					t2 = System.currentTimeMillis();
					System.out.println(i+":t="+(t2-t1));
					t1 = System.currentTimeMillis();
				}	
				String line=input.nextLine();
	        	//subject
	        	String[] st=line.split(" ");
	        	if(st.length < 4) continue;// wrong triple
	        	int x=Arrays.binarySearch(Ent,st[0]);
	        	int s=x;
	        	//predicate
	        	x=P_ind[Arrays.binarySearch(P_arr,st[1])];
		        int p=x;
		        //Object
	        	String o=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
	        	x=Arrays.binarySearch(Ent,o);		        
		     
	        	// remove duplicated rows
			        if(removeDuplictes) {
		        	String rowhash=String.format("%d,%d,%d", s,p,x);
			        
			        if(!trpc.add(rowhash)) {
			        	//System.out.println("Line:" + i +" S:" + s +" P:"+ p +" O:"+x+" hash:"+rowhash);
			        	continue;
			        }
			        }
		        triples[ri][0]=s;
		        triples[ri][1]=p;
		        triples[ri][2]=x;
		        ri++;
		        E_cnt[x]++;E_cnt[s]++;E_cnt[p]++;
	        	//System.out.println("S:"+ s +'\n' + "P:" + p +'\n' + "Obj:" + o);
	        	//lcnt++;
	        }
//	        ##Calc EntCount
	       input.close(); 
		}catch(IOException e) {
				System.out.println("Failed to open file: ");
			}
			
		return new Object[]{triples, E_cnt,ri};//ri:number of distinct triples
	}

//--------------------------------------------------------------------------------
	public static Object[] parseNT_passI(String filename,String ofname) {//hm2
			Map<String, Integer> entities=new HashMap<String, Integer>(2^30);
			ArrayList<Integer> E_cnt=new ArrayList<Integer>();
			int nEnt=0;
       		long t1 = System.currentTimeMillis();
    		long t2 = System.currentTimeMillis();
    		long li=0;//line index

			   try {
					BufferedReader reader = new BufferedReader(
							new InputStreamReader(new FileInputStream(filename), "UTF8"));
				    String line;
				    System.out.println("Writing triples to: " + ofname + "_x");
					
					PrintWriter sout = new PrintWriter(new FileWriter(ofname+"_s.txt"));
					PrintWriter pout = new PrintWriter(new FileWriter(ofname+"_p.txt"));
					PrintWriter oout = new PrintWriter(new FileWriter(ofname+"_o.txt"));

				    while ((line = reader.readLine()) != null) {
				    	li++;
						  if(li%100000==0) {
							  t2 = System.currentTimeMillis();
							  System.out.println(li+":t="+(t2-t1)+" #Ent: "+entities.size());
							  t1 = System.currentTimeMillis();
						   }	
						//subject
			        	String[] st=line.split(" ");
			        	if(st.length < 4) continue;// wrong triple
			        	int x=indexEnt(st[0],entities);
			        	int s=x;
			        	//predicate
			        	x=indexEnt(st[1],entities);
				        int p=x;
				        //Object
			        	String os=line.substring(st[0].length()+st[1].length()+2, line.length()-2);
			        	int o=indexEnt(os,entities);	
			        	//write triple
				        sout.println(s);
				        pout.println(p);
				        oout.println(o);

				        if(E_cnt.size()<s)E_cnt.set(s,E_cnt.get(s)+1);
				        else E_cnt.add(1);
				        if(E_cnt.size()<p)E_cnt.set(p,E_cnt.get(p)+1);
				        else E_cnt.add(1);
				        if(E_cnt.size()<x)E_cnt.set(x,E_cnt.get(x)+1);
				        else E_cnt.add(1);
				    }
				    reader.close();
				    sout.close(); 
			       pout.close(); 
			       oout.close(); 

			    }catch(IOException e) {
					System.out.println("Failed to open file ");
				}
			   try {  System.out.println("Saving Entities...");
				  PrintWriter eout = new PrintWriter(new FileWriter(ofname+"_Ent.txt"));
				  String[] Ent=new String[entities.size()];
				  for(Map.Entry<String,Integer> e: entities.entrySet()) Ent[e.getValue()]=e.getKey();
				  for(String e:Ent) eout.println(e);
				  nEnt =Ent.length;
				  System.out.println("Saving Entities counts...");
				  PrintWriter cntout = new PrintWriter(new FileWriter(ofname+"_E_cnt.txt"));
				  for(int e:E_cnt) cntout.println(e);
		       eout.close(); 
		       cntout.close(); 
			}catch(IOException e) {
					System.out.println("Failed to open file. ");
					e.printStackTrace();
				}
				
			return new Object[]{li,nEnt};//ri:number of distinct triples

			}   
		//----------------------------------------------------------
		//--------------------------------------------------------------------
				public static String[][] getTriples_cnt(String filename,int cnt) {
					// use Arrays
//					long lcnt =0;
					String[][] triples=new String[cnt][3];
					try{
						Scanner input = new Scanner(new File(filename));
						
						for(int i = 0; i < cnt; i++) {
							String line=input.nextLine();
							String[] st=line.split(" ");
							String s=st[0];
							triples[i][0]=s;
							String p=st[1];
							triples[i][1]=p;
							String o=line.substring(s.length()+p.length()+2, line.length()-2);
							triples[i][2]=o;
							//System.out.println("S:"+ s +'\n' + "P:" + p +'\n' + "Obj:" + o);
							//lcnt++;
						}
//			        ##Calc EntCount
						
//			        Map<String, Long> map = //Arrays.stream(sl)
//			        	    sl.stream().collect(Collectors.groupingBy(s -> s, Collectors.counting()));
						
						
					}catch(IOException e) {
						System.out.println("Failed to open file: ");
					}
					
					return(triples);
				}
				//---------------------------------------------------------------------
				public static long getEntc(String filename) throws IOException {
					//LF: problem
				    InputStream is = new BufferedInputStream(new FileInputStream(filename));
				    try {
				        byte[] c = new byte[1];
				        byte[] s=new byte[1024];
				        byte[] p=new byte[1024];
				        byte[] o=new byte[1024*1024];
				        byte[] line=new byte[1024*100];
				        byte[] tmp=null;
				        TreeSet<byte[]> tst=new TreeSet<byte[]>();
				        int si=0, pi=0,oi=0,i=0;
				        int state=0;
//				        byte[] s = 
				        long count = 0;
				        //int readChars = 0;
				        boolean endsWithoutNewLine = false;
				        while (is.read(c) != -1) {
				            //for (int i = 0; i < readChars; ++i) {
				        	
				        	if(c[0] == '\n') { 
				        		++count;
				        		//process triple
				        		
				        		//String subj=String.copyValueOf(line, 0, si);//
				        		System.arraycopy(line, 0, s, 0, si);
				        		//String subj=new String(s,"UTF-8");
				        		//String prd=String.copyValueOf(line, si, pi-si);
				        		System.arraycopy(line, 0, p, si, pi-si);
				        		//String obj=String.copyValueOf(line, pi, i-pi);
				        		System.arraycopy(line, 0, o, pi,i-pi);
				        		System.out.println("S:"+(int)s[0]+" P:"+p+" O:"+o);
				        		si=0;
				        		state=0;
				        		pi=0;
				        	//	oi=0;
				        		i=0;
				        	}else 
				        		if(c[0] == ' ' && state<2) {
				        			if(state==0)si=i;//s[si++]=c[0];
				    	        	else if(state==1)pi=i;//p[pi++]=c[0];
				    	        	      //else oi++;//o[oi++]=c[0];
				        		               state++;
				        		               continue;
				        	    }
				        	
				        	if(c[0] != 10) line[i++]=c[0];
				        }
				            endsWithoutNewLine = (c[0] != '\n');
				        
				        if(endsWithoutNewLine) {
				            ++count;
				        } 
				        return count;
				    } finally {
				        is.close();
				    }
				}
			//-------------------------------------------------------------------------
				public static void benchmark_readers(String filename) {
					long t1 = System.currentTimeMillis();
					long cnt=getLinecount_buf(filename);
					long t2 = System.currentTimeMillis();
					long cnts=getLinecount_scan(filename);
					long t3 = System.currentTimeMillis();
					System.out.println("ctb:"+cnt+" cnts:"+cnts+"time buf:"+(t2-t1)+"time scan:"+(t3-t2));
				}
			//-------------------------------------------------------------------------
		public static long getLinecount_buf(String filename) {
			long lcnt =0;
			try {
				BufferedReader reader = new BufferedReader(
						 new InputStreamReader(
			                      new FileInputStream(filename), "UTF8"));//new FileReader(filename));
			    Set<String> lines = new HashSet<String>(10000); // maybe should be bigger
			    String line;
			    while ((line = reader.readLine()) != null) {
			        lines.add(line);
			        lcnt++;
			    }
			    reader.close();
		    }catch(IOException e) {
				System.out.println("Failed to open file: ");
			}
			return lcnt;
		}   
		//----------------------------------------------------------------------
		//-------------------------------------------------------------------------
				public static long getLinecount_scan(String filename) {
					long lcnt =0;
					try {
						Scanner input = new Scanner(new File(filename),"UTF-8");
					    Set<String> lines = new HashSet<String>(10000); 
					    while (input.hasNextLine()) {
				        	String line=input.nextLine();
				        	lcnt++;
					    }
					    input.close();
				    }catch(IOException e) {
						System.out.println("Failed to open file: ");
					}
					return lcnt;
				}   
		//----------------------------------------------------------------------
				public static int getLinecount_scan_st(String filename) {
			int lcnt =0;
			int maxL=0,maxL_ind=0;
			String LL="";
			long t1 = System.currentTimeMillis();
			try{
			Scanner input = new Scanner(new File(filename),"UTF-8");
	        while (input.hasNextLine()) {
	        	String line=input.nextLine();
	        	lcnt++;
	        	if(lcnt%10000==0) {
					long t2 = System.currentTimeMillis();
					System.out.println(lcnt+":t="+(t2-t1)+" "+maxL+" "+maxL_ind);
					t1 = System.currentTimeMillis();
				}
	        	if(line.length()>maxL) {
	        		maxL=line.length();
	        		maxL_ind=lcnt;
	        		LL=line;
	        	}
	        }
	        input.close();
			}catch(IOException e) {
				System.out.println("Failed to open file: ");
			}
			
			System.out.println("MaxL:"+maxL+" maxL_ind:"+maxL_ind+"\n"+LL);
			return lcnt;
		}
		//---------------------------------------------------------------------
		public static void getTriples_scan(String filename,long cnt) {
//			long lcnt =0;
			//if(cnt==0) cnt=linecount(filename);
			try{
			Scanner input = new Scanner(new File(filename));
	        //int numberOfLinesToPrint = Integer.parseInt(input.nextLine());
	        //NavigableMap<Integer, String> lineMap = new TreeMap<>();
			List<String> sl = new ArrayList<String>();//=new List();
			List<String> pl = new ArrayList<String>();//=new List();
			List<String> ol = new ArrayList<String>();//=new List();
	        while (input.hasNextLine()) {
	        	String line=input.nextLine();
	        	String[] st=line.split(" ");
	        	String s=st[0];
	        	sl.add(s);
	        	String p=st[1];
	        	pl.add(p);
	        	String o=line.substring(s.length()+p.length()+2, line.length()-2);
	        	ol.add(o);
	        	//System.out.println("S:"+ s +'\n' + "P:" + p +'\n' + "Obj:" + o);
	        }
//	        ##Calc EntCount
	        
//	        Map<String, Long> map = //Arrays.stream(sl)
//	        	    sl.stream().collect(Collectors.groupingBy(s -> s, Collectors.counting()));
	        input.close();
	        
		}catch(IOException e) {
				System.out.println("Failed to open file: ");
			}
		}
		//--------------------------------------------------------------------
		public static Object[] getEnt(String filename,int cnt) {
			String[] E_arr=null;
			int k=0;//#Ents
		TreeSet<String> EntS=new TreeSet<String>();
		TreeSet<String> EntO=new TreeSet<String>();
		TreeSet<String> Prd=new TreeSet<String>();//|P|<<|S|
		int Chnk=200000;
		long t1 = System.currentTimeMillis(),t2;
		int lno=0;
		try{// merge 2: n=n1+n2 : n log n, n1 log n1 + n2 log n2 + O(n1+n2)
			Scanner input = new Scanner(new File(filename),"UTF-8");//
			for(; lno < cnt; lno++) {
				if(lno%100000==0) {
					t2 = System.currentTimeMillis();
					System.out.println(lno+":t="+(t2-t1)+" |S|="+EntS.size()+" |P|="+Prd.size()+" |O|="+EntO.size());
					t1 = System.currentTimeMillis();
				}
		    	String line=input.nextLine();
		    	String[] st=line.split(" ");
		    	//System.out.println(lno);
		    	if(st.length < 4) {
		    		System.out.println(lno + ":Wrong triple:" + line);
		    		//continue;
		    	}else {
		    	String s=st[0];
		    	EntS.add(s);
		    	String p=st[1];
		    	Prd.add(p);
		    	String o=line.substring(s.length()+p.length()+2, line.length()-2);
		    	EntO.add(o);
		    	}
		    	if(lno%Chnk==0) {
		    		// merging
		    		System.out.println("Merging Obj:"+EntO.size());
		    		t1 = System.currentTimeMillis();
		    		Object[] Res=mergeArrays(E_arr,EntO.toArray(new String[EntO.size()]),k,EntO.size());
		    		E_arr=(String[])Res[0];
		    		k=(int) Res[1];
		    		//EntO.clear();
		    		EntO=new TreeSet<String>();
		    		t2 = System.currentTimeMillis();
		    		System.out.println("Merging Obj:"+k+" took:"+(t2-t1));
		    		System.out.println("Merging Subj:"+EntS.size());
		    		t1 = System.currentTimeMillis();
		    		Res=mergeArrays(E_arr,EntS.toArray(new String[EntS.size()]),k,EntS.size());
		    		//EntS.clear();
		    		EntS= new TreeSet<String>();
		    		E_arr=(String[])Res[0];
		    		k=(int) Res[1];
		    		t2 = System.currentTimeMillis();
		    		System.out.println("Merging Subj:"+k+" took:"+(t2-t1));
		    	}
			}
			if(lno%Chnk!=0) {
	    		// merging
	    		System.out.println("Merging Obj:"+EntO.size());
	    		t1 = System.currentTimeMillis();
	    		Object[] Res=mergeArrays(E_arr,EntO.toArray(new String[EntO.size()]),k,EntO.size());
	    		E_arr=(String[])Res[0];
	    		k=(int) Res[1];
	    		EntO.clear();
	    		t2 = System.currentTimeMillis();
	    		System.out.println("Merging Obj:"+k+" took:"+(t2-t1));
	    		System.out.println("Merging Subj:"+EntS.size());
	    		t1 = System.currentTimeMillis();
	    		Res=mergeArrays(E_arr,EntS.toArray(new String[EntS.size()]),k,EntS.size());
	    		EntS.clear();
	    		E_arr=(String[])Res[0];
	    		k=(int) Res[1];
	    		t2 = System.currentTimeMillis();
	    		System.out.println("Merging Subj:"+k+" took:"+(t2-t1));
	    	}
			input.close();
		}catch(IOException e) {
			System.out.println("getEnt: Failed to open file: "+filename);
		}
		String[] P_arr=Prd.toArray(new String[Prd.size()]);
		//merge Predicates
		System.out.println("Merging Predicates:"+Prd.size());
		t1 = System.currentTimeMillis();
		Object[] Res=mergeArrays(E_arr,P_arr,k,P_arr.length);
		EntS.clear();
		E_arr=(String[])Res[0];
		k=(int) Res[1];
		t2 = System.currentTimeMillis();
		System.out.println("Merging Subj:"+k+" took:"+(t2-t1));
		//for(String x:P_arr)EntS.add(x);
		//String[] O_arr=EntO.toArray(new String[EntO.size()])
		//for(String x:O_arr)EntS.add(x);
		System.out.println("#Predicates:" + P_arr.length);
		String[] tmpS=new String[k];
		System.arraycopy(E_arr,0, tmpS, 0, k);//EntS.toArray(new String[EntS.size()]);
		return(new Object[] {tmpS,P_arr});
		}
		//---------------------------------------------------------------------
	// Merge arr1[0..n1-1] and arr2[0..n2-1] into
		// arr3[0..n1+n2-1] O(n1+n2)
		public static Object[] mergeArrays(String arr1[], String arr2[],int n1,int n2)
		{
		    int i = 0, j = 0, k = 0;
		    //int n1=arr1.length;
	        //int n2=arr2.length;
	        String[] arr3=new String[n1+n2];
		    // Traverse both array
		    while (i<n1 && j <n2)
		    {   int test=arr1[i].compareTo(arr2[j]);
		        if (test < 0)
		            arr3[k++] = arr1[i++];
		        else if (test > 0)
		            arr3[k++] = arr2[j++];
		        else {
		        	  arr3[k++] = arr1[i++];
		              j++;//repeated item
		        }
		    }
		 
		    // Store remaining elements of first array
		    while (i < n1)
		        arr3[k++] = arr1[i++];
		 
		    // Store remaining elements of second array
		    while (j < n2)
		        arr3[k++] = arr2[j++];
		   
		    return new Object[]{arr3,k};
		}
		
		//--------------------------------------------------------------------
}

