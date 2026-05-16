<?php
// echo $_GET["mytoken"];
include("db.php");
if(isset($_GET["connectivity"])){
	echo json_encode(array("status"=>"200"));
}else if(isset($_GET["table"]) && isset($_GET["method"])){
	
	$sort = "";
	$ret = [];
	if(isset($_GET["sort"])){
		$sort = " order by " . $_GET["sort"];
	}
	
	
	
	$db = new db();
	$count = "*";
	if(isset($_GET["count"]) && $_GET["count"] == "true"){
		$count= " count(*) as count";
	}
	
	
	if($_GET["method"]=="get"){
		if($_GET["id"]==""){
		$sql = "select " . $count . "  from `" . $_GET["table"] . "` where " . $_GET["where"] . $sort;
		}else{
			$sql = "select * from `" . $_GET["table"] . "` where id='" . $_GET["id"] . "' and " . $_GET["where"] . $sort;
		}
		// echo $sql;
		
		
		$res = $db->query($sql);
	
		while($obj = mysqli_fetch_object($res)){
			$ret[] = $obj;
		}
		echo json_encode($ret);
	}else if($_GET["method"]=="set"){
		if(isset($_GET["data"])){
			if(exists($_GET["table"],$_GET["id"])){
				$_data =explode(",",str_replace("}","",str_replace("{","",json_decode($_GET["data"]))));
				$_set = [];
				foreach($_data as $element){
					$el = explode(":",$element);
					$_set[] = $el[0] . "='" . substr(str_replace("'","''",$el[1]),1) . "'";
				}
				$set = implode(",",$_set);
				$sql = "update `" . $_GET["table"] . "` set " . $set . " where id='" . $_GET["id"] . "'";
				$db->query($sql);
				
				// echo $sql;
				
				$res = $db->query("select * from `" . $_GET["table"] . "` where id='" . $_GET["id"] . "'");
				if($obj = mysqli_fetch_object($res)){
				echo json_encode($obj);
				}
			}else{
				$_data =explode(",",str_replace("}","",str_replace("{","",json_decode($_GET["data"]))));
				$columns = [];
				$values = [];
				foreach($_data as $element){
					$el = explode(":",$element);
					$columns[] = str_replace("mytoken","__token__",$el[0]);
					$values[] = "'" . substr(str_replace("'","''",$el[1]),1) . "'";
				}
				$sql = "insert into `" . $_GET["table"] . "` (" . implode(",",$columns) . ") values (" . implode(",",$values) . ")";
				// echo $sql;				
				$db->query($sql);
				$sql = "select * from `" . $_GET["table"] . "` where __token__ = " . $values[count($_data)-1];
				// echo "<hr>";
				// echo $sql;				
				$res = $db->query($sql);
				if($obj = mysqli_fetch_object($res)){
					echo json_encode($obj);
				}
			}
			
		}
	}else if($_GET["method"]=="delete"){
		$sql = "delete from `" . $_GET["table"] . "` where " . $_GET["where"];
		// echo $sql;
		$db->query($sql);
		echo json_encode(array("status"=>"200"));
	}
}


function exists($table,$id){
	$res = (new db())->query("select * from `" . $_GET["table"] . "` where id='" . $id . "'");
	return mysqli_fetch_object($res);
}


function Dump($data)
{
    print "<pre>\n";
    print_r($data);
    print "<pre>";
}


?>