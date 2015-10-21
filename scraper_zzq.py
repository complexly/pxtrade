#encoding:utf-8

from urllib import urlretrieve
import urllib2
import time
import json

user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'#配置浏览器环境
headers = {'User-Agent':user_agent}

reporters = json.load(open("report.json",'r')) #读取reporter list的json文件
results = reporters["results"]


a=0#计数，99次后休止1小时
for yyyy in range(2010,2012):
	year = str(yyyy)
	r_list = []#将reporter list写入数组r_list
	for i in range(1,len(results)):
		r_list.append(results[i]['id'])

	for k in range(len(results)):#遍历reporter list内的成员
		time.sleep(1)#网站限制，每秒请求一次
		a += 1
		if a == 90:
			time.sleep(3610)
			a=0
		print results[k]['id']#显示正在请求的reporterID
		if results[k]['id'] == 'all':#跳过reporter=all时无法输出的情景
			continue
		host = "http://comtrade.un.org/api/get?r=" + results[k]['id'] + "&cc=270900,290243,291736,390760,270111,270112,270119,270210,270220,270400,284910,290129,290321,390410,290121&freq=A&ps="+year+"&px=HS"#OPENAPI的请求格式
		req = urllib2.Request(host,headers = headers)#数据抓取
		response = urllib2.urlopen(req)
		the_page = response.read()
		dictionary = json.loads(the_page)
		dataset = dictionary['dataset']
		print len(dataset)#显示数据行数
		if len(dataset) == 0:
			continue
		keys = dataset[0].keys()
		outHandle = open("HS29_zzq/"+ year + "/" + results[k]['id'] + '.csv','w')#将抓取到的json格式转换为csv
		for i in range(len(keys)):
			outHandle.write(str(keys[i]))
			if i != len(keys) - 1:
				outHandle.write(',')
		outHandle.write('\n')
		for i in range(len(dataset)):
			for j in range(len(keys)):
				try:
					outHandle.write(str(dataset[i][keys[j]]))
				except:
					pass
				if j != len(keys) - 1:
					outHandle.write(',')
			outHandle.write('\n')
		outHandle.close()
