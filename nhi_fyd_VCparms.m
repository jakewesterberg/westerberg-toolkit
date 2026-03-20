function vcpar = nhi_fyd_VCparms()
%database parameters
    vcpar.User = 'dbuser_VandC'; 
    vcpar.Passw = '0R#y8YDcJtDz';   
    vcpar.Database = 'roelfsemalab';
    vcpar.Server = 'fyd2.nin.nl';
    vcpar.Tbl = 'sessions';
    vcpar.Fields = { 'project', 'dataset', 'subject', 'stimulus', ...
                     'excond', 'setup', 'date', 'sessionid',  ...
                     'investid', 'logfile', 'url', 'server'};
