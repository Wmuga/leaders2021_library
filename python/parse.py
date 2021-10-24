import psycopg2
from psycopg2 import sql
import sys
import spacy
import time
from pymystem3 import Mystem


# Аргументы на коннект получаю через агрументы при запуске
if (len(sys.argv)<5):
  print("Specify arguments: dbname, user, host, port, password")
  exit()

# Получает слова определенной книги
def get_words(read_ids):
  """
    Аргументы:
      read_ids - Список id прочитанных пользователем книг
    Возвращает:
      Множество из ключевых слов, относящихся к прочитанным книгам
      Если таковых нет - None
  """
  words = execute_with_connection(sql.SQL("select keyword from key_words where rec_id in ({});").format(sql.SQL(',').join(map(sql.Literal,read_ids))))
  return set([list(word)[0] for word in words]) if words else None


def get_dict_words_by_ids(recommend_ids): 
  """
    Аргументы:
      recommend_ids - Список id книг, рекомендуемых пользователю
    Возвращает:
      Словарь в формате {id : Множество из ключевых слов, относящихся к книге}
      Если таковых нет - None
  """ 
  print('Forming dict')
  lines = execute_with_connection(sql.SQL("select * from key_words where rec_id in ({});").format(sql.SQL(',').join(map(sql.Literal,recommend_ids))))
  if not lines: return None
  d = {}
  for line in lines:
    id = int(line[0])
    word = line[1]
    if id not in d:
      d.update({id:set()})
    d[id].add(word) 

def get_same_books_from_given(recommend_ids,read_ids):
  """
    Аргументы:
      read_ids - Список id прочитанных пользоватлем книг
      recommend_ids - Список id книг, рекомендуемых пользователю
    Возвращает:
      Список, длиной до 5 книг, наиболее подходящих пользователю
  """
  if len(recommend_ids)<=5:
    return recommend_ids
  book_words = get_words(read_ids)
  if not book_words:
    return recommend_ids[:5]
  words_dict = get_dict_words_by_ids(recommend_ids)
  if not words_dict or len(words_dict)==0:
    return recommend_ids[:5]
  
  for key in words_dict:
    words_dict[key] = len(words_dict[key] & book_words)
  words_dict = sorted({v:k for k,v in words_dict.items()}.items())
  return [i[1] for i in words_dict[:-5]]

def get_user_rec_by_words(user_id,recommend_ids,read_ids):
  """
    Аргументы:
      user_id - id читателя
      read_ids - Список id прочитанных пользоватлем книг
      recommend_ids - Список id книг, рекомендуемых пользователю
    Возвращает:
      В 1й файл id пользователи и до 5 рекомендованных книг
      В 2й файл До 5 строк, сожержащих id читателя, название, автор, год издания, аннотация, id книги. 
        Каждое поле заключено в кавычки и разделено через ;
  """
  rec = get_same_books_from_given(recommend_ids, read_ids)
  print(rec)
  # arr = [user_id]
  # for r in rec:
  #   arr.append(r)
  # output_file1.write(';'.join(['"{}"'.format(i) for i in arr]))
  # output_file1.write('\n')

  # for r in rec:
  #   line = execute_with_connection(sql.SQL("SELECT main_catalog.title, authors.author, main_catalog.yea, annotation_text, main_catalog.rec_id FROM main_catalog LEFT JOIN authors using(author_id) LEFT JOIN annotations using(rec_id) WHERE main_catalog.rec_id = {};").format(sql.Literal(r)))
  #   if not line:
  #     continue
  #   res =[user_id]
  #   for i in line[0]:
  #     res.append(i)
  #   output_file2.write(';'.join(['"{}"'.format(i) if i else '' for i in res]))
  #   output_file2.write('\n')



# Вывод слов в таблицу
def output(values_list):
  """
    Аргументы:
      values_list - список кортежей в формате (id книги, ключевое слово)
  """
  if (len(values_list)>0):
    execute_with_connection(sql.SQL('insert into key_words values {};').format(sql.SQL(',').join(map(sql.Literal, values_list))))

# соединение с таблицой
def connect():
  """
    Возвращает: соединение с таблицей по аргументам, полученными через аргументы запуска скрипта
  """
  return psycopg2.connect(dbname = sys.argv[1], user = sys.argv[2], password = sys.argv[5], host = sys.argv[3], port = sys.argv[4])

# ВЫполнение запросов
def execute_query(conn,query):
  """
    Аргументы:
      conn - соединение с таблицей
      query - запрос
    Возвращает:
      Аттрибут cursor, описывающий результат выполнения запроса
  """
  cursor = conn.cursor()
  cursor.execute(query)
  return cursor

def execute_with_connection(query):
  """
    Аргументы:
      query - запрос
    Возвращает:
      Список кортежей, являющимися результатом выполнения запроса
      None если запрос не выполнен или в результате запроса нет вывода
  """
  conn = connect()
  res = ""
  try:
    cursor = execute_query(conn,query)
    conn.commit()
    # print('Executed query')
    res = cursor.fetchall()
  except BaseException as err:
    if log_err:
      print(err)
    res = None  
  conn.close()
  return res

# Преобразует полученные строки в лист кортежей (id, слово) и отправляет на вывод
def prepare_to_output(rows):
  tick = time.time()
  """
    Аргументы:
      rows - Список строк, содержащих в себе id книги и ее ключевые слова
  """
  values = []
  for row in rows:
    line = [i for i in row.split(' ') if len(i)>0]
    buffer = []
    if len(line)>1:
      try:
        num = int(line[0])
        words = set(line[1:])
        for word in words:
          if word.isalpha() and len(word)>2:
            buffer.append((num,word))   
        if len(buffer)==0:
          # print('Empty words with', num)
          execute_with_connection(sql.SQL("insert into key_words(rec_id) values({})").format(sql.Literal(num)))   
          continue
        for val in buffer:
          values.append(val)
      except ValueError as err:
        if log_err:
          print(err)
    else:
      num = int(line[0])
      # print('Empty words with', num)
      execute_with_connection(sql.SQL("insert into key_words(rec_id) values({})").format(sql.Literal(num)))      
  # print('Outputing to table. Ellapsed time:',time.time()-tick) 
  output(values)      

# Убирает окончания из слов и отправляет их на дальнейшую обработку
def pass_to_lemmatize(words):
  tick = time.time()
  """
    Аргументы:
      words - Длинная строка, содержащая id книг и их аннотации
  """
  rows = ' '.join([word for word in m.lemmatize(words)]).split(delim.strip())
  # print('Lemmatized. Ellapsed time:',time.time()-tick)
  prepare_to_output(rows)

# Получить пользовательские прочитанные книги 
def get_user_read_ids(user_id):
  """
    Аргументы:
      user_id - id читателя
    Возвращает:
      список прочитанных книг
  """
  lines = execute_with_connection(sql.SQL("select distinct catalogue_record_id from circulations where reader_id = {}").format(sql.Literal(user_id)))
  return [list(i)[0] for i in lines]

# Анализирует не занесенные в key_words аннотации, выделяет существительные и отправляет из на леммантизацию
def parse_batch():
  tick = time.time()
  """
    Возвращает:
      True, если запрос был выполнен успешно
      False, если не было обработано ни одной строки
  """
  lines = execute_with_connection(sql.SQL("select rec_id, annotation from books_for_csv b where not exists (select distinct rec_id from key_words k where b.rec_id = k.rec_id) and length(annotation)>54 and lower(annotation) like '%а%' limit {};").format(sql.Literal(batch_size)))
  
  if not lines:
    # print('Got nothing. Ellapsed time:',time.time()-tick)
    return False

  # print('Got batches. Ellapsed time:',time.time()-tick)

  dump_str_list = []
  tick = time.time()
  for line in lines:
    i, ann = line
    dump_str_list.append("{} {}".format(i, ann.strip()))

  dump_str_list = delim.join(dump_str_list)
  # print('Put to analize. Ellapsed time:',time.time()-tick) 
  tick = time.time()
  doc = nlp(dump_str_list)

  # print('Analzied batch. Ellapsed time:',time.time()-tick)

  dump_str_list = []    

  for token in doc:
    if (token.pos_ == "NOUN" or token.text == delim.strip() or token.text.isdigit()):
     dump_str_list.append(token.text)
    
  pass_to_lemmatize(' '.join(dump_str_list))
  return True

#Парсит, пока 5 раз подрят не сможет пройти запрос
def parse_until_nothing():
  i = 0
  while i < 5:
    i = 0 if parse_batch() else i+1


def get_recommend_usr(user_id, recommend_ids):
  """
    Аргументы:
      user_id - id читателя
      recommend_ids - Список id книг, рекомендуемых пользователю
  """
  read_ids = get_user_read_ids(user_id)
  get_user_rec_by_words(user_id,recommend_ids,read_ids)

log_err = True
delim = " AAAAA "
batch_size = 3000 # 2500 +- оптимально

nlp = spacy.load("ru_core_news_sm")
# print("Loaded model")

nlp.max_length = 4000000 # трогать аккуратно изначально на 1м стоит
m = Mystem()


# parse_until_nothing()

# output_file1 = open('out1.csv','w',encoding='utf-8')
# output_file2 = open('out2.csv','w',encoding='utf-8')

# get_recommend_usr(689794,[924153,1418709,1483632,149487,162412,869171,837536,12587]) #Выдает рекомендации

# print('End')
