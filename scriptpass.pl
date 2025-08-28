#! /usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$query_string = $ENV{'QUERY_STRING'};
($champ1, $champ2) = split (/&/, $query_string);
print $champ1, "<br>";
print $champ2;
exit(0);