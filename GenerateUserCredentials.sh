#!/bin/bash
# UUID on end of output file

## to uniquely identify multiple runs of the script
uid=$(uuidgen)

# Output file
output_file="/Users/$USER/Desktop/GeneratedUserCredentials_$uid.txt"

#Total number of accounts
X=$1

# Generate usernames and passwords
echo "Generating $X Account Names & Passwords" >> $output_file
echo >> $output_file
for n in $(seq "$X");
  do
    echo "User $((n++))" >> $output_file
    echo -n "Username: " >> $output_file; Username=$(apg -a 1 -M ncl -n 1 -m 8 -E iIlL1oO0B8) >> $output_file; echo $Username >> $output_file
    echo -n "Password: " >> $output_file; Password=$(apg -a 1 -M ncl -n 1 -m 8 -E iIlL1oO0B8) >> $output_file; echo $Password >> $output_file
    echo -e >> $output_file
done
