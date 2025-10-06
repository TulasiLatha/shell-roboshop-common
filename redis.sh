
source ./common.sh

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis 7"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing Rdis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf 
VALIDATE $? "Allowing remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"
systemctl start redis
VALIDATE $? "Starting Redis"

print_total_time