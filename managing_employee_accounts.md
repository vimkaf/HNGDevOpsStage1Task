# Managing Employee Accounts in Bash Script

## Overview

This Bash script is designed to automate the process of creating user accounts for employees based on input from a specified file. It checks for the existence of the file, reads employee details from it, creates user accounts if they do not already exist, assigns them to specified groups, generates secure passwords, and logs all actions to a designated log file.

This script is a task for the HNG DevOps Internship Program

[Learn More about HNG Internship](https://hng.tech/internship)

[Learn More about HNG Hire](https://hng.tech/hire)

## Script Components

### File Existence Check

The script starts by checking if the input file (`$1`) exists. If not, it exits with an error message.

```bash
employeesfile=$1

if [ ! -f "$employeesfile" ]; then
    echo "File not found!"
    exit 1
fi
```

### Function: generate_secure_password
This function generates a secure random password using OpenSSL.

```bash
generate_secure_password() {
    local password_length=8
    echo "$(openssl rand -base64 $password_length)"
}
```

### Logging Actions
All significant actions performed by the script are logged to /var/log/user_management.log.

```bash
logfile=/var/log/user_management.log

log_action() {
    local action=$1
    echo "$action" >> $logfile && echo "$action"
}
```

### Password File Setup
The script ensures that the password file (/var/secure/user_passwords.csv) exists and sets appropriate permissions.

```bash
passwordfile="/var/secure/user_passwords.csv"

sudo touch "$passwordfile"
sudo chmod 600 "$passwordfile"
```

### User Creation Loop
The main part of the script reads each line from the employees file, extracts the username and groups, and performs the following actions:

 - Checks if the user already exists.
 - Creates the user with specified groups if not already existing.
 - Generates a secure password and sets it for the user.
 - Logs each action to the log file.
 - Appends the username and password to the password file.

```bash
while IFS=';' read -r username groups; do
    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists!, Skipping user"
        continue
    fi

    sudo useradd -m -G "$groups" "$username"
    log_action "Added $username to $groups"

    password=$(generate_secure_password)
    echo "$username:$password" | sudo chpasswd
    log_action "setting $username:$password"

    echo "User $username created with groups $groups and home directory."

    echo "$username,$password" | sudo tee -a "$passwordfile" >/dev/null
    log_action "$username,$password written to $passwordfile"

done < "$employeesfile"

```

### Resources
Here are resources that aided me in completing this script.
- [https://blog.devops.dev/creating-users-groups-and-policies-in-linux-574bcc38de9d](https://blog.devops.dev/creating-users-groups-and-policies-in-linux-574bcc38de9d)
- [https://devdocs.io/bash/word-splitting](https://devdocs.io/bash/word-splitting)
- [https://www.youtube.com/watch?v=tK9Oc6AEnR4&ab_channel=freeCodeCamp.org](https://www.youtube.com/watch?v=tK9Oc6AEnR4&ab_channel=freeCodeCamp.org)
- [https://linuxize.com/post/bash-exit/](https://linuxize.com/post/bash-exit/)
- [https://www.geeksforgeeks.org/tee-command-linux-example/](https://www.geeksforgeeks.org/tee-command-linux-example/)
