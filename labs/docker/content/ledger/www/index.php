<?php
$page = $_GET['page'] ?? 'home';
if (stripos($page, 'php://') !== false || stripos($page, 'data://') !== false) {
    http_response_code(400);
    echo 'Remote wrappers disabled.';
    exit;
}
# relative include from the web root so path traversal is the intended bug
chdir($_SERVER['DOCUMENT_ROOT'] ?? __DIR__);
$file = 'pages/' . $page;
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Ledger CMS</title>
  <style>body { font-family: sans-serif; max-width: 720px; margin: 2rem auto; }</style>
</head>
<body>
  <h1>Ledger CMS</h1>
  <nav>
    <a href="/index.php?page=home">Home</a>
    <a href="/index.php?page=about">About</a>
    <a href="/index.php?page=contact">Contact</a>
  </nav>
  <hr>
  <?php include $file; ?>
</body>
</html>
