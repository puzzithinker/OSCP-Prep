<?php
$msg = '';
$blocked = ['php', 'php3', 'php4', 'php5', 'phar', 'pht'];
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['invoice'])) {
    $f = $_FILES['invoice'];
    $name = $f['name'];
    $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));
    if (in_array($ext, $blocked, true)) {
        $msg = 'Rejected: executable PHP extensions are not allowed.';
    } elseif ($f['error'] !== UPLOAD_ERR_OK) {
        $msg = 'Upload error code ' . (int)$f['error'];
    } else {
        $destDir = __DIR__ . '/uploads';
        if (!is_dir($destDir)) {
            mkdir($destDir, 0775, true);
        }
        $safe = basename($name);
        $dest = $destDir . '/' . $safe;
        if (move_uploaded_file($f['tmp_name'], $dest)) {
            $msg = 'Stored as uploads/' . htmlspecialchars($safe, ENT_QUOTES, 'UTF-8');
        } else {
            $msg = 'Failed to store file.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Invoice upload — Harbor</title>
  <style>body { font-family: sans-serif; max-width: 640px; margin: 2rem auto; }</style>
</head>
<body>
  <h1>Vendor invoice upload</h1>
  <p>Accepted: images and office documents. PHP is blocked.</p>
  <?php if ($msg !== ''): ?>
    <p><strong><?php echo $msg; ?></strong></p>
  <?php endif; ?>
  <form method="post" enctype="multipart/form-data">
    <input type="file" name="invoice" required>
    <button type="submit">Upload</button>
  </form>
  <p><a href="/index.php">Home</a> · <a href="/uploads/">uploads/</a></p>
</body>
</html>
