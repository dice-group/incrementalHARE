 
 REM Building 
 javac -target 1.7 parseNT\parseNT.java -source 1.7 -bootclasspath rt.jar
 jar cvfm parseNT.jar parseNT\manifest.txt parseNT\parseNT.class
 
 
 REM Example 
 java -jar parseNT.jar sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassI"
REM	>> printed 460463=(number of lines -1)include dummy literal <Literal>
REM 	##start of literaals
	java -jar parseNT.jar sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassII" 460464 0 35
	REM >> printed #new Entities:379457 #total entities: 839920, #skipped:0
	java -jar parseNT.jar sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "PassII" 839921 36 999999
	REM #new Entities:26691 #total entities: 866611, #skipped:0
	REM >>Ecnt wc-l 866612 = 866611+1
	REM * to verify rename file <sec>_ol99999.txt to only sec_ol.txt
     java -jar parseNT.jar sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  "Ecnt" 866612 #as the number of linrs not entities 
REM verify
	java -jar parseNT.jar sec "D:\\RDF\\" "D:\\RDF\\ParseNT\\"  verify 866612
 