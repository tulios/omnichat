db = db.getMongo().getDB("omnichat");
print( "switched to db " + db.getName() );

var key = "C3747C316C161E4C11A18CD1F8C2456F85EFBC9D";
var email = "contatopicheme@gmail.com";
var created_at = 1316740611557;
var hosts = ["http://localhost:3000", "http://127.0.0.1:3000", "http://omnichat.herokuapp.com"];

if (!db.migrations.findOne({version: "001"})) {
  db.accounts.remove();
  db.accounts.save({key: key, email: email, created_at: created_at, hosts: hosts});

  account = db.accounts.findOne({key: key});
  if (account) {
    print("Account " + key + " for " + email + " succesfuly created!");
    db.migrations.save({version: "001"});
  }
} else {
  print("version 001 already applied")
}