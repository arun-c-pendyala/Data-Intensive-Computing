
# coding: utf-8

# In[1]:

import pyspark
import csv
import itertools
sc = pyspark.SparkContext()
raw_rdd = sc.textFile("files_3/*")


# In[9]:



with open('lemmas.csv', 'rb') as csvfile:  # store lemmas in dictionary
     data_reader = csv.reader(csvfile,delimiter=',')
     dict = {'key':'value list'}
     for row in data_reader:
        lem = []
        for i in range(1,len(row)):
            lem.append(row[i])
        dict[row[0]] = lem 
        


# In[46]:

def num(s):  #function to check if string has number
    try:
        return int(s)
    except ValueError:
        return "no"


def map_function(s):
        if(len(s.split(">")) == 2):
            meta_data, text = s.split(">")
        elif(len(s.split(">")) == 3):  # if > is present in text
            meta_data, text_1 , text_2 = s.split(">")
            text = text_1 + text_2
        else:      # for all the exceptions
            meta_data = " xyz.1 .1 "
            text = s
            
        
        text = text.replace("j","i")
        text = text.replace("v","u")
        
        meta_data = meta_data.replace("<","")
        if(num(meta_data.split(".")[1]) != "no" ): # e.g : luc.1.1
            doc_id, chap , line_num = meta_data.split(".")
        elif(len(meta_data.split(".")) == 4 and not  num(meta_data.split(".")[1]) != "no"): # e.g: vergil
            doc_id_1 , doc_id_2 , chap , line_num = meta_data.split(".")
            doc_id = doc_id_1 + doc_id_2
        elif(len(meta_data.split(".")) == 3):  # e.g: ambrose
            doc_id_1 , doc_id_2 , chap = meta_data.split(".")
            doc_id = doc_id_1 + doc_id_2
            line_num = " "
        else:   # if there is no ">" to split
            doc_id = meta_data
            line_num = " "
            chap = " "


        doc_id = doc_id.replace("<","")
        res =  " [ doc_id = " + doc_id + " , chapter# = " + chap + " , line# = " + line_num + " ]"
        txt_tokens = text.lower().split()
        out = []
        
        for i in range(0,len(txt_tokens)-1):  #replace token with lemma
            if(txt_tokens[i] in dict):
                txt_1_lemma = dict[txt_tokens[i]]
                while '' in txt_1_lemma:
                    txt_1_lemma.remove('')
            else:
                txt_1_lemma = txt_tokens[i]
            
            if(txt_tokens[i+1] in dict):
                txt_2_lemma = dict[txt_tokens[i+1]]
                while '' in txt_2_lemma:
                    txt_2_lemma.remove('')
            else:
                txt_2_lemma = txt_tokens[i+1]
            
            
            
            
            pair = itertools.product(txt_1_lemma,txt_2_lemma)
            for part in pair:
                txt_pair = part[0] + "," +  part[1]
                out.append((txt_pair,res))
        
        
        return out
    
    
       
            
TwoGramPairs = raw_rdd.flatMap(map_function)    
    


# In[41]:

result = TwoGramPairs.reduceByKey(lambda x,y : x+y )



# In[50]:

import time
out_file_name = "output_2_gram/out" + str(time.time())
result.saveAsTextFile(out_file_name)


# In[ ]:



