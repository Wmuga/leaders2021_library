<?php
if (isset($_POST['id']))
{
    
$DBConnect = new mysqli("localhost", "teslasstec_mlib", "SUPER_SECRET_PASSWORD", "teslasstec_mlib");
if (!$DBConnect)
{
    echo ("База данных недоступна");
    exit;
}
$result1 = $DBConnect -> query("SELECT * FROM history_for_csv WHERE reader_id=".$_POST['id'].";");

$result2 = $DBConnect -> query("SELECT DISTINCT A.reader_id, B.title, B.author, B.yea, B.annotation, B.rec_id FROM `recs_for_scv` as A LEFT JOIN `books_for_csv` as B ON (A.`rec_id` = B.`rec_id`) WHERE A.`reader_id`=".$_POST['id']." LIMIT 5;");
if (!$result1) {
    echo "Произошла ошибка.\n";
    exit;
  }
  $loaded = 1;
  $DBConnect -> close();
}
else
{
    $loaded = 0;
}

?>

<!DOCTYPE html>
<html lang="ru">

<head>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.1/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-F3w7mX95PdgyTmZZMECAngseQB83DfGTowi0iMjiWaeVhAn4FJkqJByhZMI3AhiU" crossorigin="anonymous">

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css">


  <meta charset="UTF-8">
  <title> Каталог </title>
</head>

<body>
  <!--Header-->

  <header class="p-3 bg-dark">
    <div class="container-fluid">
      <div class="d-flex flex-wrap align-items-center"> <a href="/"
          class="fs-1 text-white text-decoration-none ps-3 pe-5">Московские
          библиотеки </a>

      </div>
    </div>
  </header>
  <!-- Data-->

  <div class="container my-3 p-3 shadow-sm">
    <!--Input-->
    <form action="index.php" class="d-flex border-bottom pb-3" method="post"> 
      <input type="search" class="form-control" name="id" placeholder="Введите id пользователя...">
      <input type="submit" value="Вывести книги" class="btn btn-warning ms-2 text-nowrap" >
</form>
    <!--Readed-->
<?php
if($loaded)
{
    echo '<p class="fs-3 border-bottom py-3">
    ID пользователя: '.$_POST['id'].'
  </p>';
    echo ("
        <p class=\"fs-2\">
    Прочитанные книги
  </p>
    ");
    foreach ($result1 as $row)
    {
        
        echo '
            <div class="container border border-1 rounded-2 py-2 my-2">
            <div class="fs-6">(ID книги: ';
                echo ($row['rec_id']);
      echo ')</div>
      <div class="fs-5">';
      if ($row['title'] != "")
      {
          echo ($row['title']);
      }
      else
      {
       echo ("Нет названия");
      }
      echo '</div>
      <div class="text-black-50">';
      if ($row['author'] != "")
      {
          echo ($row['author'].", ");
      }
      else
      {
       echo ("Нет автора, ");
      }
      if ($row['yea'] != "")
      {
          echo ($row['yea']." г.");
      }
      else
      {
       echo ("Нет года");
      }
      echo '</div>
      <hr class="mx-0 my-1">
      <div class="text-black-50">';
      if ($row['annotation'] != "")
      {
          echo ($row['annotation']);
      }
      else
      {
       echo ("Нет описания");
      }
      echo '</div>
    </div>
        ';
    }

    /* рекомендации */
    echo ("
    <p class=\"fs-2\">
Рекомендованные книги
</p>
");
foreach ($result2 as $row)
{
    
    echo '
        <div class="container border border-1 rounded-2 py-2 my-2">
        <div class="fs-6">(ID книги: ';
            echo ($row['rec_id']);
  echo ')</div>
  <div class="fs-5">';
  if ($row['title'] != "")
  {
      echo ($row['title']);
  }
  else
  {
   echo ("Нет названия");
  }
  echo '</div>
  <div class="text-black-50">';
  if ($row['author'] != "")
  {
      echo ($row['author'].", ");
  }
  else
  {
   echo ("Нет автора, ");
  }
  if ($row['yea'] != "")
  {
      echo ($row['yea']." г.");
  }
  else
  {
   echo ("Нет года");
  }
  echo '</div>
  <hr class="mx-0 my-1">
  <div class="text-black-50">';
  if ($row['annotation'] != "")
  {
      echo ($row['annotation']);
  }
  else
  {
   echo ("Нет описания");
  }
  echo '</div>
</div>
    ';
}
}
    

    ?>
</div>
<script>
function Send() {
  debugger;
var id = document.getElementById('input_id').value;   
var URL = "/index.php";

var http = new XMLHttpRequest();
var params = 'id='+id;
http.open('POST', URL, true);

//Send the proper header information along with the request
http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

http.onreadystatechange = function() {//Call a function when the state changes.
    if(http.readyState == 4 && http.status == 200) {
        alert(http.responseText);
    }
}
http.send(params);
}
</script>
</body>
</html>