
library('twitteR')
setup_twitter_oauth("AhfTjxlw3bMAJSx5LOzM0CfqT", "aixmj9xYpO3bLeTgcSuhLJLGZGchpkQYo6i8j85zejPKLLaXAj", "847585052-7ujhP4Gk68ybAxQUZ8UGuz3IZsxYwD7ihG9xbq0f", "pF4PXgUv1D6Gwl8ZDHN2UGv6TsJRY7a1YI3XkabDRIzlp")



tweets <- searchTwitter('syria', n=2000) #retrieve 2000 tweets
head(tweets)


Sys.setlocale('LC_ALL','C') #resolve encoding problem while converting to dataframe

df <- twListToDF(tweets)   #conversion to dataframe
head(df)

head(df$text)

write(df$text, file = "tweets_syria.txt", append = FALSE, sep = "\n")


#final hdfs output is converted into csv files using space as delimiter.
map_red <- read.csv("map-reduce.csv",sep=",")

head(map_red)


map_red <- setNames(map_red,  c("tag","freq"))
head(map_red)

unicodeSubset <- map_red[ grep("<u+", map_red$tag), ]
head(unicodeSubset)

map_red_new <- setdiff(map_red,unicodeSubset)  # the new df has most unicode values removed to produce a clear tag cloud



install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes

map_red_new <- na.omit(map_red_new)

library('wordcloud')
library('RColorBrewer')  # source: http://www.sthda.com/english/wiki/text-mining-and-word-cloud-fundamentals-in-r-5-simple-steps-you-should-know#step-1-create-a-text-file

set.seed(1234)
wordcloud(words = map_red_new$tag, freq = map_red_new$freq, min.freq = 2,
          max.words=304, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


