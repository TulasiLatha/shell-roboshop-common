#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.tulasidevops.fun

mkdir -p $LOGS_FOLDER
echo "SRIPT started executed at : $(date)" | tee -a $LOG_FILE

check_root(){
if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi
}

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"
}

app-setup(){
    mkdir -p /app
     VALIDATE $? "Creating app directory"

     curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"

     cd /app 
    VALIDATE $? "Changing to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name &>>$LOG_FILE
    VALIDATE $? "unzip $app_name"
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enable $app_name"

}
app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}
print_total_time(){
    END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "script executed in : $Y $TOTAL_TIME seconds $N"
}