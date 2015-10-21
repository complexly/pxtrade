# 本文件用于清理朱子棋抓取的贸易数据

## 读入
dirtydata = read.csv("Total.backups.csv")

## 基本概况与取舍判断
str(dirtydata)
summary(dirtydata)
table(dirtydata$aggrLevel) #aggrLevel全都一样，可删
table(dirtydata$rgCode) #决定只保留1进口2出口，舍去3/4的再进出口
all.equal(dirtydata$period,dirtydata$periodDesc)
all.equal(dirtydata$period,dirtydata$yr) #period列/periodDesc列/yr列一样，只留yr
table(dirtydata$pt3ISO) #似乎应为贸易对象国家三位ISO代码，感觉数据有误，舍去
plot(dirtydata$TradeQuantity,dirtydata$NetWeight) #差别不大，netweight净重值有些值小一些，留netweight，不用留单位了
table(dirtydata$ptCode) #存在不确切的地区汇总结果，需要删去
badcodelist=c(472,10,899,80,86,837,471,129,162,166,221,697,
              492,260,838,334,473,520,536,570,574,637,290,527,
              577,568,612,636,698,239,839,581,849,879,732,0) #UN comtrade中只作为partner出现的单位，不明确的出口对象

## 使用dplyr整理格式
library(dplyr)
dirtydata = tbl_df(dirtydata) %>%
  filter(!(ptCode %in% badcodelist))

importdata = dirtydata %>%
  filter(rgCode == 1, ptCode) %>%
  select(origin = ptCode, destination = rtCode, year = yr, commodity = cmdCode, value = TradeValue, netweight = NetWeight)

exportdata = dirtydata %>%
  filter(rgCode == 2) %>%
  select(origin = rtCode, destination = ptCode, year = yr, commodity = cmdCode, value = TradeValue, netweight = NetWeight)

tradedata = rbind(importdata, exportdata)
rm(importdata, exportdata)

## 去除netweight小于0.1的离群点，计算当年平均价格(总价/总量)
avgprice = tradedata %>%
  filter(netweight > 0.1) %>%
  group_by(year, commodity) %>%
  summarise(price = sum(value)/sum(netweight))

## 查看不同商品不同年的价格走势
library(ggplot2)
qplot(y=price,x=year,data=avgprice,color=factor(commodity),geom="line")

## 使用平均价格对netweight小于0.1缺失点做插补
tradedata = tradedata %>%
  left_join(avgprice) %>%
  mutate(netweight = ifelse(netweight<0.1,value/price,netweight))

## 对于重复的汇报结果取平均值
tradedata %>%
  group_by(origin, destination, year, commodity) %>%
  summarise_each(funs(mean))

## 输出清洗后的数据
write.csv(tradedata,"cleaneddata.csv", row.names = F)
