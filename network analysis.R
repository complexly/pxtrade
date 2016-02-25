#' # 网络分析

# 读入

tradedata = read.csv("cleaneddata.csv")

# 转换为网络

require(igraph)
require(dplyr)
allmixed = graph_from_data_frame(tradedata)

pxmixed = tradedata %>%
  filter(commodity==290243) %>%
  graph_from_data_frame()

pxlist = lapply(2004:2014, function(x) tradedata %>%
                  filter(commodity==290243, year==x) %>%
                  graph_from_data_frame())

# 查看px混合网络概况，判断是否简单图
pxmixed
is_simple(pxmixed)

# 除了多重边问题，中国地大物博，自己对自己出口……另一个有问题的是法国
E(pxmixed)[(which_loop(pxmixed))]

# 去掉多余属性，将列表中的多重边合并，取11年平均的贸易量、净重
pxmixed.simp = pxmixed %>%
  delete_edge_attr("year") %>%
  delete_edge_attr("commodity") %>%
  delete_edge_attr("price") %>%
  simplify(remove.multiple = T, remove.loops = T, edge.attr.comb = "mean")
pxmixed.simp

# 可视化多年平均px贸易网络，有明显的核心-边缘结构
l = layout.fruchterman.reingold(pxmixed.simp)
plot(pxmixed.simp, layout = l, vertex.size = 7, vertex.label = NA,
     edge.arrow.size=0.3, edge.width = log(E(pxmixed.simp)$value)/5)

# 看看累积度分布
pxmixed.simp %>%
  degree_distribution(cumulative = T) %>%
  plot(log = "xy", xlab = "Degree", ylab = "P(x)>=k")

# 平均路径长度与直径、半径,平均聚类系数
average.path.length(pxmixed.simp)
diameter(pxmixed.simp)
radius(pxmixed.simp)
mean(transitivity(pxmixed.simp, type = "local"), na.rm = T)

# 社团划分：尝试了几种算法，效果都奇差，模块性不显著
clusterlist = list(cluster_infomap(pxmixed.simp, e.weights = E(pxmixed.simp)$value),
                   cluster_label_prop(pxmixed.simp, weights = E(pxmixed.simp)$value),
                   cluster_walktrap(pxmixed.simp, weights = E(pxmixed.simp)$value))
sapply(clusterlist, modularity)

# 查看每年的px贸易网络节点数、边数、是否简单图,去除自环
sapply(pxlist,function(x) c(vcount(x),ecount(x), is.simple(x)))
pxlist = lapply(pxlist, simplify)

#‘ 查看每年px网络形态
opar <- par()
par(mfrow=c(3,4),
    mar=c(0.5, 0.5, 0.5, 0.5),
    oma=c(0.5, 1.0, 0.5, 0))
for(i in (1:11)) {
  plot(pxlist[[i]], layout = l[match(V(pxlist[[i]])$name,V(pxmixed.simp)$name),], vertex.size = 7, vertex.label = NA,
       edge.arrow.size=0.3, edge.width = log(E(pxmixed.simp)$value)/5)
  title(i+2003)
}
plot(pxmixed.simp, layout = l, vertex.size = 7, vertex.label = NA,
     edge.arrow.size=0.3, edge.width = log(E(pxmixed.simp)$value)/5)
title("averaged")
par(opar)

# 每年的指标变化：平均路径长度,平均聚类系数，模块度
plot(2004:2014, sapply(pxlist, average.path.length), xlab="year", ylab="average path length",type = "b")
plot(2004:2014, sapply(pxlist, function(x) mean(transitivity(x, type = "local"), na.rm = T)), xlab="year", ylab="average clustering coef",type = "b")
plot(2004:2014, sapply(pxlist, function(x) modularity(cluster_infomap(x, e.weights = E(x)$value))), xlab="year", ylab="modularity",type = "b")






res.deg=matrix(0,165,11)
for (i in 1:11){
  res.deg[match(V(pxlist[[i]])$name,V(pxmixed.simp)$name),i]=degree(pxlist[[i]])
}
res.core=matrix(0,165,11)
for (i in 1:11){
  res.core[match(V(pxlist[[i]])$name,V(pxmixed.simp)$name),i]=coreness(pxlist[[i]])
}
matplot(t(res.deg),type="l")
matplot(t(res.core),type="l")

# 整体贸易量、关键节点变化、70年