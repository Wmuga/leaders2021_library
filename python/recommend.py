import random
import psycopg2
import pandas as pd
import numpy as np
import time
import sys
import os.path
import csv

# 8.tcp.ngrok.io:13924

def recommendation(user_list,amount_of_users_blocks = 1,block_len = 1000):

	# 1.  Подключение к базе данных
	hst ='8.tcp.ngrok.io'
	prt = 13924
	pas = '0001'
	usr = 'data_read'
	db = 'library'
	conn = psycopg2.connect(dbname=db, user=usr, password=pas, host=hst, port =prt)
	cursor = conn.cursor()

	#2. Алгоритм
	for k in range(0,amount_of_users_blocks):
		# 2.1. Заполнение локального списка пользователей
		# заполнение локального списка пользователей, которым нужна рекомендация
		# если на входе user_list пуст, то он заполняется пользователями, 
		# которые хотяб раз брали книгу 
		if not user_list:
			circulation_onhands = pd.read_sql('SELECT distinct reader_id from circulations where state = \'На руках\' limit {} offset {}'.format(block_len,k*block_len), conn)
			users_id = circulation_onhands.reader_id.tolist()
			# print("обработано пользователей: ",k*block_len)
		else:
			users_id = user_list

		# 2.2. Создание промежуточного файла и словаря рубрика-список книг по рубрике
		# создается дополнительный файл для хранения рубрика-список книг по рубрике
		if not os.path.exists("rubrics_booklist.csv"):
			# print("генерим csv")
			catolog1 = pd.read_sql('SELECT rec_id,rubric from rubrics', conn)
			group_by_rubric = catolog1.groupby("rubric")["rec_id"].apply(lambda x: ','.join(map(str, x)))
			group_by_rubric.to_csv("rubrics_booklist.csv",sep=';',encoding='utf-8')

		# из дополнительного файла создается словарь
		catolog = pd.read_csv("rubrics_booklist.csv",sep=';',encoding='utf-8',header = None,index_col=0, squeeze=True)

		# rubrics :  словарь
		# Пример:
		# Агрофизика;191513,385618,714664
		rubrics = catolog.to_dict()

		# 2.3. для каждого юзера создается список рекомендаций
		for user_id in users_id:

			print("user_id = ",user_id)
			recomend_list = []

			# из таблицы circulations находятся книги, которые брал юзер 
			cursor.execute("SELECT distinct catalogue_record_id from circulations join (select {} as reader_id) as t1 using(reader_id)".format(user_id))
			temp = cursor.fetchall()			
			# id преобразуются в список
			user_books_id = list(sum(temp, ()))
			print(user_books_id)
			# для находятся рубрики из таблицы rubrics, если у книги рубрик нет, то добавляется None 
			cursor.execute("SELECT rubrics.rubric from rubrics right join main_catalog on main_catalog.rec_id = rubrics.rec_id where main_catalog.rec_id in ({})".format(",".join(str(x) for x in user_books_id)))
			temp = cursor.fetchall()
			print(temp)
			# список рубрик пользователя
			user_rubrics = list(sum(temp, ()))
			user_rubrics =["Художественная литература","Художественная литература","Художественная литература","Справочные материалы","Зарубежная проза, сборники разных жанров для детей и юношества"]
			# выбирается возрастное ограничение по книгам
			cursor.execute("SELECT ager from main_catalog where rec_id in ({})".format(",".join(str(x) for x in user_books_id)))
			temp = cursor.fetchall()
			user_ager = list(sum(temp, ()))
			user_ager = list(filter(None, user_ager))

			n = len(user_books_id)
			print("user_rubrics:",user_rubrics)
			print("user_ager:",user_ager)
			# рекомендации по книгам пользователя
			for i in range(0,n):
				if user_rubrics[i] == None:
					continue
				if user_ager :
					# если есть возрастное ограничение по книге, то подбирается книга по возрастному ограничению и рубрике
					# прочитанные книги не предлогются
					cursor.execute("SELECT main_catalog.rec_id from main_catalog join rubrics on main_catalog.rec_id = rubrics.rec_id where (main_catalog.ager in ('{}')) and (rubrics.rubric = '{}') and (main_catalog.rec_id not in ({})) limit 1".format("','".join(user_ager),user_rubrics[i], ",".join(str(x) for x in (user_books_id+recomend_list))))
					temp = cursor.fetchone()
					# ничего не добавляется, если соответствий нет
					if temp == None:
						continue
					corresp_id= temp[0]
					# print("corresp_id:",corresp_id)
					recomend_list.append(int(corresp_id))

			# рубрики очищаются от None
			user_rubrics = list(filter(None, user_rubrics))
			 
			i=0
			# если после очищения список рубрик пуст, то пользователь пропускается
			if  user_rubrics:
				# если рекомендованных книг <5, то дополнение случайными книгами по рубрикам пользователя
				while len(recomend_list) <5 and i<10:
					#  берется случайная рубрика пользователя
					random_rubric = random.choice(user_rubrics)
					# из словаря берется список книг по соотвеетствующей рубрике 
					books_by_rubric = rubrics[random_rubric].split(",")

					# из списока книг по рубрике берется случайная книга
					random_book_id = random.choice(books_by_rubric) 
					#  если пользователь ее не читал, заносится в список рекомендаций
					if (not (random_book_id in user_books_id)) and (not (random_book_id in recomend_list)):
						recomend_list.append(int(random_book_id))
					# может быть такой случай, когда все рекомендованные пользователь уже читал, поэтому стоит ограничивающее условие i<10
					i+=1

				random.shuffle(recomend_list)
				recomend_list=recomend_list[:5]

				print("user id:",user_id,"recommendations:",",".join(str(x) for x in recomend_list))
				
				# список рекомендаций заносится в export.csv
				for n in recomend_list:
					# преобразование данных в удобный для экспорта вид
					lst =[f'{user_id}']
					lst.append(f'{n}')
					numpy_array =np.asarray(lst)
					df = pd.DataFrame([numpy_array],columns=['reader_id', 'rec_id'])

					# если файла нет, то он создается и первой строкой добавляется названия столбцов, потом рекомендации
					# если есть, то добавляются рекомендации
					if os.path.exists("export.csv"):
						df.to_csv("export.csv",sep=',',encoding='utf-8', mode='a', header=False,index=False, quoting=csv.QUOTE_ALL)
					else:
						df.to_csv("export.csv",sep=',',encoding='utf-8', index=False, quoting=csv.QUOTE_ALL)




# start = time.time()

recommendation([])
# recommendation([],200,1000)
# recommendation(user_list =[],amount_of_users_blocks = 200,block_len = 1000)

# end = time.time()
# print("time:",end - start)
