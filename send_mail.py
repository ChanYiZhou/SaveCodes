# -*- coding: UTF-8 -*-
import os as os
import subprocess as sup
import re as re
import smtplib  
from email.mime.text import MIMEText 
 
mailuser=os.environ.get("USER_NAME")
mailsmtp=os.environ.get("MAILSMTP")
password=os.environ.get("PASSWORD")
mailaim=os.environ.get("MAILAIM")

resp = sup.Popen(["tail", "-n", "1", "rsl.error.0000"], stdout = sup.PIPE)
outp = resp.communicate()[0]
regi = re.findall("SUCCESS",outp)

if regi:
    subject = "Congratulations!"
    contents = "The WRF model have runned successfuly!" 
else:
    subject = "Failure!"
    contents = "Please check it!"

def send_mail(mailaim,subject,contents):   
    msg = MIMEText(contents,_subtype='plain',_charset='gb2312')  
    msg['Subject'] = subject  
    msg['From'] = mailuser  
    msg['To'] = "".join(mailaim)  
    try: 
       # server = smtplib.SMTP() 
        server = smtplib.SMTP_SSL(mailsmtp,465)  
        server.connect(mailsmtp,465)  
        server.login(mailuser,password)  
        server.sendmail(mailuser, mailaim, msg.as_string())  
        server.close()  
        return True  
    except Exception, e:  
        print str(e)  
        return False  
if __name__ == '__main__':  
    if send_mail(mailaim,subject,contents):  
        print "Send Successfuly!"  
    else:  
        print "Fail to send!"
