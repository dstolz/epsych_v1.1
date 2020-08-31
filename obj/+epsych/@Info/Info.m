classdef Info < handle
    % class contains general inormation for the EPsych software
    
    properties (SetAccess = private)
        iconPath
        chksum
        commitTimestamp
        meta
    end
    
    properties (Constant)
        Version     = '2.0';
        DataVersion = '2.0';        
        Author      = 'Daniel Stolzberg, PhD';
        AuthorEmail = 'daniel.stolzberg@gmail.com';
        License     = 'GNU General Public License v3.0';
        Website     = 'https://github.com/dstolz/epsych_v1.1';
    end
    
    methods
        % Constructor
        function obj = Info()

        end
        
        
        function m = get.meta(obj)
            m.Author      = obj.Author;
            m.AuthorEmail = obj.AuthorEmail;
            m.Copyright   = 'Copyright to Daniel Stolzberg, 2020';
            m.License     = obj.License;
            m.Version     = obj.Version;
            m.DataVersion = obj.DataVersion;
            m.Website     = obj.Website;
            m.Checksum    = obj.chksum;
            m.commitTimestamp = obj.commitTimestamp;
            m.CurrentTimestamp = datestr(now);
        end
        
        function p = get.iconPath(obj)
            p = fullfile(obj.root,'icons');
        end
        
            
        function chksum = get.chksum(obj)
            chksum = nan;

            fid = fopen(fullfile(obj.root,'.git','logs','HEAD'),'r');
            if fid < 3, return; end
            while ~feof(fid), g = fgetl(fid); end
            fclose(fid);
            
            a = find(g==' ');
            chksum = g(a(1)+1:a(2)-1);
        end
        
        function c = get.commitTimestamp(obj)
            try
                fn = fullfile(obj.root,'.git','logs','HEAD');
                d  = dir(fn);
                c  = d.date;
            catch
                warning('EPsychInfo:get:commitTimestamp','Not using the git version!')
                c = datestr(0);
            end
        end
        
        
    end % methods (public)
    
    methods (Static)
        function r = root
            r = fileparts(which('epsych_startup'));
        end

        function d = user_directory
            d = char(java.lang.System.getProperty('user.home'));
        end
        
        function s = last_modified_str(datens)
            % s = last_modified_str(datens)
            %
            % Accepts filename, date string, or datenum and returns:
            % 'File last modifed on Sun, May 05, 2019 at 12:19 PM'
            
            narginchk(1,1);
            
            if ischar(datens)
                if exist(datens,'file') == 2
                    d = dir(datens);
                    datens = d(1).date;
                end
                datens = datenum(datens);
            end
                
            s = sprintf('File last modifed on %s at %s', ...
                datestr(datens,'ddd, mmm dd, yyyy'),datestr(datens,'HH:MM PM'));
        end
        
        function p = print
            e = epsych.Info;
            m = e.meta;
            
            fn = fieldnames(m);
            ml = max(cellfun(@length,fn));
            p = '';
            for i = 1:length(fn)
                v = m.(fn{i});
                p = sprintf('%s% *s: %s\n',p,ml,fn{i},v);
            end
        end
    end
    
    
end