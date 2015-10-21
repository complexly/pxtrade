# 网络分析

## 读入
tradedata = read.csv("cleaneddata.csv")

## 使用igraph创建对象
library(igraph)
allmixed = graph_from_data_frame(tradedata)
