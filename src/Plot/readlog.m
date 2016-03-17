function readlog(logfile, filter, firstchar)
 if nargin <  2 
     filter = ' ';
 end
 
 
% logfile = 'C:\Users\Aniol\Copy\MCV\PFM\results/short.log';

fid = fopen(logfile, 'r');

tline = fgetl(fid);
while ischar(tline)
    
   if nargin < 3
       first = 1;
   else
       ich = strfind(tline, firstchar);
       
       if numel(ich)>0
           first = ich(1)+1;
       else
           first = 1;
       end
   end
   if numel(strfind(tline, filter))>0 || nargin <  2
        disp(tline(first:end))
    end
    tline = fgetl(fid);
end
