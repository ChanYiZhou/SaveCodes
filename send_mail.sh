#!/bin/sh
 
mailuser=`echo $USER_NAME`
mailaim=`echo $MAILAIM`
subject="WRF"
content="wrf_notice.txt"
mailsmtp=`echo $MAILSMTP`
password=`echo $PASSWORD`
success="SUCCESS"

if [ -f rsl.error.0000 ]
then
    response=`tail -n 1 rsl.error.0000 | awk -F ' ' '"SUCCESS"{print $4}'`
    cfl=`grep "cfl" rsl.error.0000`
fi
#debug statements below
#echo $response
#echo $mail_from
#echo mail_to
#echo mail_smtp
#echo password
 
if [ $response = $success ]
then
    info="Congratulations!"
else
    if [ -n "$cfl" ]
    then
        info="Sorry!Please check it!Try to reduce the time_step and re-run!"
    else
        info="Sorry!Please check it!"
    fi
fi

# contents
echo "FROM:$mailuser
To:$mailaim
Subject:$subject

$info" > $content
 
# send mail
curl -s --url "${mailsmtp}" --mail-from "${mailuser}" --mail-rcpt ${mailaim} \
--upload-file $content --ssl --user "${mailuser}:${password}" 

#delete file
rm -f $content
