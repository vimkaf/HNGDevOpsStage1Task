#!/bin/bash
employeesfile=$1

#check if file exists
if [ ! -f "$employeesfile" ]; then
    echo "File not found!"
    exit 1
fi

generate_secure_password() {
    local password_length=8
    echo "$(openssl rand -base64 $password_length)"
}

logfile=/var/log/user_management.log
passwordfile="/var/secure/user_passwords.csv"

#log action of the script
log_action() {
    local action=$1
    echo "$action" >>$logfile && echo "$action"
}

# Ensure the password file exists and set appropriate permissions
sudo touch "$passwordfile"
sudo chmod 600 "$passwordfile"

while IFS=';' read -r username groups; do

    log_action "Processing user: $username"

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists!, Skipping user"
        continue
    fi

    sudo useradd -m -G "$groups" "$username"
    log_action "Added $username to $groups"

    #call the generate_secure_password
    password=$(generate_secure_password)

    # Set the user's password
    echo "$username:$password" | sudo chpasswd
    log_action "setting $username:$password"

    echo "User $username created with groups $groups and home directory."

    # Append the username and password to the CSV file
    echo "$username,$password" | sudo tee -a "$passwordfile" >/dev/null
    log_action "$username,$password written to $passwordfile"

done <"$employeesfile"
