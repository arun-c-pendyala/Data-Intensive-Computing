import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Locale;


import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;


public class LatinWordCooccur {
	
	public static HashMap<String,ArrayList<String>> lemmaMap = new HashMap<String,ArrayList<String>>();
	

    public static class LatinMapper
       extends Mapper<Object, Text, Text, Text>{

    private final static IntWritable one = new IntWritable(1);
    private Text key_word = new Text();
    private Text val_list = new Text();
    private String first ;
    private String second;
           

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
    String line = value.toString();  
	line.trim();
    String[] meta_txt = line.split("\\>");
	
	System.out.println(meta_txt[0]);  // meta_txt[0] contains meta data
	String docid ="";
	String chap_no = "";
	String line_no = "";
	
	
	
	//here
	try{
		if( meta_txt.length > 1 && !line.equals("") && !meta_txt[0].contains("\\,") ){
			
			String[] meta_tokens = meta_txt[0].split("\\.");
			
			meta_txt[1].replaceAll("j", "i");
			meta_txt[1].replaceAll("v", "u");
			
			meta_txt[0] = meta_txt[0].trim();
			meta_txt[1] = meta_txt[1].trim();
			
			 String[] tokens = meta_txt[1].split("\\s+");
			
			System.out.println(meta_tokens[0]+ ","+ meta_tokens[1]);
			
			System.out.println("meta_tokens[0]" +meta_tokens[0]);
			
			docid = meta_tokens[0].substring(1, meta_tokens[0].length());
			
			
			
			if(meta_tokens[1].matches(".*\\d+.*")){
				chap_no = meta_tokens[1];
				line_no = meta_tokens[2];
			}
			else if(!meta_tokens[1].matches(".*\\d+.*") && meta_tokens.length == 4){
				docid = docid + meta_tokens[1];
				chap_no = meta_tokens[2];
				line_no = meta_tokens[3];
			}
			else{
				docid = docid + meta_tokens[1];
				chap_no = meta_tokens[2];
				
			}
		    
		 
		   
			ArrayList<String> lemma_arr_first ;
			ArrayList<String> lemma_arr_sec;
			String first_word;
			String second_word;
			String first_Second;
			
			
			String loc = "< docid = " + docid + ",[chapter# = " + chap_no + ", line# = " + line_no ;
			
			 
			for(int j= 0; j< tokens.length-1; j++){ // iterate over the text part of tokens
				lemma_arr_first = new ArrayList<String>();
				lemma_arr_sec = new ArrayList<String>();
				
				String loc_pos = loc + ", position# = " + Integer.toString(j) + "]>";
				
				tokens[j] = tokens[j].replaceAll("[\\s.:;&=<>?!%(),/]", "").toLowerCase() ; //replace all non word chars and change it to lowercase
				
				
				
				
				if(lemmaMap.containsKey(tokens[j])){   // check if the token has any lemmas
					
					lemma_arr_first = lemmaMap.get(tokens[j]);
					lemma_arr_sec = lemmaMap.get(tokens[j+1]);
					
						
						
						first_word = lemma_arr_first.get(0);
						second_word = lemma_arr_sec.get(0);
						
						first_Second = first_word +","+ second_word;
						
						key_word.set(first_Second);
						val_list.set(loc_pos);
						
						context.write(key_word,val_list);
						
					
					
				}
				else{
					if(!tokens[j].contains("")){
						first_word = tokens[j];
						second_word = tokens[j+1];
						
						first_Second = first_word + "," + second_word;
						
						key_word.set(first_Second);
						val_list.set(loc_pos);
						
						context.write(key_word,val_list);
						
					}
					
					
				}
				
				
				
			}
			
		}
	}
	catch(Exception e){
		
	}
	
	
	
        
	
    
		
		
		
		
		
	
	
 
    }


  }

  public static class LatinSumReducer
       extends Reducer<Text,Text,Text,Text> {
    private Text result = new Text();
    private String res = "";

    public void reduce(Text key, Iterable<Text> values,
                       Context context
                       ) throws IOException, InterruptedException {
      
      ArrayList<String> loc_arr = new ArrayList<String>();
      int count=0;
      for (Text val : values) {
        loc_arr.add(val.toString());
          count++;
      }
      
      
        
        res = "PairCount= " + Integer.toString(count) + loc_arr.toString() ;
        
        result.set(res);
        
        context.write(key, result);

        
        
      
    }
  }

  public static void main(String[] args) throws Exception {
	
	String line = "";
	String csvFile = args[2]; 
	BufferedReader br;
	try{
		
		br = new BufferedReader(new FileReader(csvFile));
		while((line = br.readLine()) != null){
			
			String[] parts = line.split("\\,");
			String key = parts[0];
			ArrayList<String> values_list = new ArrayList<String>();
			for(int i =1; i<= parts.length-1 ; i++){
				values_list.add(parts[i]);
				
				
			}
			
			lemmaMap.put(key,values_list);
			
		}
		
	}
	catch(FileNotFoundException e){
		
		 e.printStackTrace();
		
	}
	
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "Word Count in Latin text");
    job.setJarByClass(LatinWordCooccur.class);
    job.setMapperClass(LatinMapper.class);
    job.setCombinerClass(LatinSumReducer.class);
    job.setReducerClass(LatinSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
