#!/bin/bash

netstat -tulpan | awk '{print $4}' | grep ":" | rev | cut -d ":" -f1 | rev | sort -n | uniq
