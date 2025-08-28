#!/usr/bin/env python3
import cgi

form = cgi.FieldStorage()
login = form.getfirst("login", "")
password = form.getfirst("pass", "")

print("Content-Type: text/html\n")
print(f"<html><body>login={login}<br>pass={password}</body></html>")
