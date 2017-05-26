import java.io.IOException;
import java.util.Set;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.MapWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.io.LongWritable;

public class WordCooccurStripes {
    
    public static class StripesTokenizerMapper
    extends Mapper<Object, Text, Text, NewMapWritable>{     // based on http://codingjunkie.net/cooccurrence/
        
        
        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();
        private NewMapWritable occurmap = new NewMapWritable();
        
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            
            int neighbors = context.getConfiguration().getInt("neighbors", value.getLength());
            String[] tokens = value.toString().split("\\s+");
            for(int i=0; i < tokens.length ; i++){
                
                if(tokens[i].contains("\\>") || tokens[i].contains("\\<") || tokens[i].matches(".*\\d+.*") || tokens[i].equalsIgnoreCase("co") || tokens[i].equalsIgnoreCase("u") || tokens[i].equalsIgnoreCase("RT") || tokens[i].equalsIgnoreCase("") || tokens[i].length() == 1){
            continue;    // remove the emojis , numbers , co , u, RT , blank , single character as the first token
        }

                word.set(tokens[i]);
                occurmap.clear();
                int begin = 0;
                int end = 0;
                
                if(i-neighbors>0){
                    begin = i-neighbors;
                }
                if(i+neighbors>=tokens.length){
                    end = tokens.length-1;
                }
                else{
                    end = i+neighbors;
                }
                for(int j= begin; j<=end ; j++){
                    
                    if(j!=i){
                        Text neighbor = new Text(tokens[j]);
                        
                        if(occurmap.containsKey(neighbor)){
                            IntWritable count = (IntWritable)occurmap.get(neighbor);
                            count.set(count.get()+1);
                        }
                        else{
                            occurmap.put(neighbor,one);
                        }
                        
                    }
                    
                }
                
                context.write(word, occurmap);
                
                
            }
        }
    }
    
    public static class StripesIntSumReducer extends Reducer<Text, NewMapWritable, Text, NewMapWritable> {
        private NewMapWritable incrementingMap = new NewMapWritable();
        
        
        public void reduce(Text key, Iterable<NewMapWritable> values, Context context) throws IOException, InterruptedException {
            incrementingMap.clear();
            for (NewMapWritable value : values) {
                addAll(value);
            }
	    
            context.write(key, incrementingMap);
        }
        
        private void addAll(NewMapWritable mapWritable) {
            Set<Writable> keys = mapWritable.keySet();
            for (Writable key : keys) {
                IntWritable fromCount = (IntWritable) mapWritable.get(key);
                if (incrementingMap.containsKey(key)) {
                    IntWritable count = (IntWritable) incrementingMap.get(key);
                    count.set(count.get() + fromCount.get());
                } else {
                    incrementingMap.put(key, fromCount);
                }
            }
        }
    }

   public static class NewMapWritable extends MapWritable {    // based on http://stackoverflow.com/questions/23209174/converting-mapwritable-to-a-string-in-hadoop
    @Override
    public String toString() {
        StringBuilder result = new StringBuilder();
        Set<Writable> keySet = this.keySet();

        for (Object key : keySet) {
            result.append("{" + key.toString() + " = " + this.get(key) + "}");
        }
        return result.toString();
       }
    }
    
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "WordCooccurStripes");
        job.setJarByClass(WordCooccurStripes.class);
        job.setMapperClass(StripesTokenizerMapper.class);
        job.setCombinerClass(StripesIntSumReducer.class);
        job.setReducerClass(StripesIntSumReducer.class);
	job.setMapOutputKeyClass(Text.class);
	job.setMapOutputValueClass(NewMapWritable.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NewMapWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
