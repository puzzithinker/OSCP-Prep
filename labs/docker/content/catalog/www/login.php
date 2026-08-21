<?php
error_reporting(E_ALL);
$msg = '';
$rows = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $u = $_POST['username'] ?? '';
    $p = $_POST['password'] ?? '';
    $db = new SQLite3('/opt/catalog.db');
    $q = "SELECT username, role FROM users WHERE username = '$u' AND password = '$p'";
    $res = @$db->query($q);
    if ($res === false) {
        $msg = 'Query failed: ' . htmlspecialchars($db->lastErrorMsg(), ENT_QUOTES, 'UTF-8');
    } else {
        while ($row = $res->fetchArray(SQLITE3_ASSOC)) {
            $rows[] = $row;
        }
        if (!$rows) {
            $msg = 'Invalid credentials.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Login — Catalog</title>
  <style>body { font-family: sans-serif; max-width: 640px; margin: 2rem auto; } table { border-collapse: collapse; } td, th { border: 1px solid #ccc; padding: 0.3rem 0.6rem; }</style>
</head>
<body>
  <h1>Staff login</h1>
  <?php if ($msg !== ''): ?><p><?php echo $msg; ?></p><?php endif; ?>
  <form method="post">
    <p><label>User <input name="username" required></label></p>
    <p><label>Pass <input name="password" type="password"></label></p>
    <button type="submit">Sign in</button>
  </form>
  <?php if ($rows): ?>
    <h2>Session</h2>
    <table>
      <tr><th>username</th><th>role</th></tr>
      <?php foreach ($rows as $r): ?>
        <tr>
          <td><?php echo htmlspecialchars((string)$r['username'], ENT_QUOTES, 'UTF-8'); ?></td>
          <td><?php echo htmlspecialchars((string)$r['role'], ENT_QUOTES, 'UTF-8'); ?></td>
        </tr>
      <?php endforeach; ?>
    </table>
    <?php
    $roles = array_column($rows, 'role');
    if (in_array('admin', $roles, true) || in_array('SummerCatalog1', $roles, true)):
    ?>
      <p>Admin panel is not shipped. SSH is enabled for <code>catalog_admin</code> on this host. Maintenance binary: <code>/usr/local/bin/dbmaint</code>.</p>
    <?php endif; ?>
  <?php endif; ?>
  <p><a href="/index.php">Home</a></p>
</body>
</html>
