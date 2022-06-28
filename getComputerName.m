% Name = getComputerName
% This function returns the hostname.
% Output is converted to lower case.
% 
% See also SYSTEM, GETENV
function Name = getComputerName
   [Status, Name] = system('hostname');
   % If the command 'hostname' failed:
   if (Status ~= 0)
      if ispc
         Name = getenv('COMPUTERNAME');
      else
         Name = getenv('HOSTNAME');
      end
   end
   
   % Remove any line feed/carriage return
   Name = Name((Name ~= newline) & (Name ~= char(13)));
   % Remove any trailing/leading space/tab characters and convert output to
   % lower case
   Name = strtrim(lower(Name));
end
