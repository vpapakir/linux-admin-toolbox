#!/bin/bash
while read line
do
    name=$line
    nslookup $name >> DOMAINLOG.txt
    nslookup -query=ns $name >> DOMAINLOG.txt
    nslookup -query=mx $name >> DOMAINLOG.txt
done < $1
