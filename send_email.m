function send_email(mail_address,mail_passd,mail_rece,varargin)
% To send email to aim-email from your email address.
% Input arguments:
%      mail_address  :  your  email address.(send)   String
%      mail_passd    :  your passward of email address.  String
%      mail_rece     :  email address received.    String
%   Optional input arguments:
%      mail_subject  :  email subject.  String
%      mail_contents :  email contents.  String
%      mail_attach   :  attachments within mail is sended.
%      mail_smtp     :  setting email smtp. if you want to base on your 
%                       email to set it, you must pay attention to port
%                       setting of your email.  String 
%   Now! it support to emails such as qq,126,163 and gmail and so on. you just change
%   mail_smtp to relative email server setting.
%      example:  mail_smtp = 'smtp.126.com'

if nargin <3
    error('Too less input arguments!')
end

mail_smtp = 'smtp.139.com';
mail_attach = '';

if isempty(varargin)
    mail_subject = 'Default Subject';
    mail_contents = 'Default Contents';
elseif length(varargin) == 2 
    mail_subject = varargin{1};
    mail_contents = varargin{2};
elseif length(varargin) == 3
    mail_subject = varargin{1};
    mail_contents = varargin{2};
    mail_attach = varargin{3};
elseif length(varargin) == 4
    mail_smtp = varargin{4};
end

% To set email specifications, you can change it based on setting for your 
% email.
setpref('Internet','E_mail',mail_address);
setpref('Internet','SMTP_Server',mail_smtp);
setpref('Internet','SMTP_Username',mail_address);
setpref('Internet','SMTP_Password',mail_passd);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465'); 

% send email
if isempty(mail_attach)
    sendmail(mail_rece,mail_subject,mail_contents);
else
    if isstruct(mail_attach)
        mail_attach = struct2cell(mail_attach);
    end
    sendmail(mail_rece,mail_subject,mail_contents,mail_attach(1,:));
end

end
