#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export RECIPIENT="enter_a_valid_email_address_here"
export DATAFILE="${DIR}/topology.csv"
export COUNT=2
export PINGLOG="/var/log/linux_health_check_ping.log"
