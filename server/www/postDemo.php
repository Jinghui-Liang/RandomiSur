<?php
require_once(__DIR__ . '/private/dbConnect.php');
$dbCon = new dbConnect();
$pdo = $dbCon->getPDO();

$json_string = json_decode(file_get_contents('php://input'), true);

try {

    // $demo_data = array(
    //     ':p_id' => $json_string['p_id'], 
    //     ':value' => $json_string['value'],
    //     ':property' => $json_string['property']
    // );

    // echo $demo_data;
    // $query = "INSERT INTO demo (p_id, value, property) VALUES (
    //        JSON_EXTRACT(json_string, '$.p_id'),
    //        JSON_EXTRACT(json_string, '$.value'),
    //        JSON_EXTRACT(json_string, '$.property'))";

    // $query = "INSERT INTO demo (p_id, value, property) VALUES (:p_id, :value, :property)";

    // $stmt = $pdo->prepare($query);
    // $stmt->execute($demo_data);

    $sql_proc = 'CALL ' . $json_string['proc_method'] . '(?)';
    $sth = $pdo->prepare($sql_proc);
    foreach ($json_string['json_trials'] as $x) {
        $sth->bindValue(1, json_encode($x), PDO::PARAM_STR);
        $sth->execute();
    };

    echo 'demo post success';

} catch(PDOException $e) {
    http_response_code(500);
    echo $e -> getMessage();
    };

?>
