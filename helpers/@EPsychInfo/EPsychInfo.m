classdef EPsychInfo < handle
    % class contains general inormation for the EPsych software
    
    properties (SetAccess = private)
        root
        iconPath
        chksum
        commitDate
        meta
    end
    
    properties (Constant)
        Version  = '1.1';
        DataVersion = '1.1';        
        Author = 'Daniel Stolzberg';
        AuthorEmail = 'daniel.stolzberg@gmail.com';
        License = 'GNU General Public License v3.0';
        
    end
    
    methods
        % Constructor
        function obj = EPsychInfo()
            
        end
        
        function r = get.root(obj)
            r = fileparts(which('epsych_startup'));
        end
        
        function m = get.meta(obj)
            m.Author      = obj.Author;
            m.AuthorEmail = obj.AuthorEmail;
            m.Copyright   = 'Copyright to Daniel Stolzberg, 2019';
            m.License     = obj.License;
            m.Version     = obj.Version;
            m.DataVersion = obj.DataVersion;
            m.Checksum    = obj.chksum;
            m.commitDate  = obj.commitDate;
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
        
        function c = get.commitDate(obj)
            fn = fullfile(obj.root,'.git','logs','HEAD');
            d  = dir(fn);
            c  = d.date;
        end
        
        function img = icon_img(obj,type)
            d = dir(obj.iconPath);
            d(ismember({d.name},{'.','..'})) = [];
            
            mustBeMember(type,{d.name})
            
            ffn = fullfile(obj.iconPath,type);
            y = dir([ffn '*']);
            ffn = fullfile(y(1).folder,y(1).name);
            [img,map] = imread(ffn);
            if isempty(map)
                img = im2double(img);
            else
                img = ind2rgb(img,map);
            end
            img(img == 0) = nan;
        end
        
    end
    
    methods (Static)
        
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
        
        function r = validate_filename(ffn)
            ffn = cellstr(ffn);
            r = false(size(ffn));
            for i = 1:numel(ffn)
                [~,fn,ext] = fileparts(ffn{i});
                fn = [fn ext]; %#ok<AGROW>
                r(i) = length(fn) <= 255 ...
                    && length(ffn{i}) <= 32000 ...
                    && isempty(regexp(ffn{i}, ['^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)', ...
                    '(\..+)?$)[^\x00-\x1f\\?*:\"><|/]+$'], 'once'));
            end
        end
        
        function str = truncate_str(str,maxn,side)
            if nargin < 3 || isempty(side), side = 'left'; end
            mustBeMember(side,{'left' 'right'});
            str = cellstr(str);
            for i = 1:numel(str)
                if length(str{i}) < maxn
                    str{i} = str{i};
                elseif isequal(lower(side),'right')
                    str{i} = [str{i}(1:end-maxn) '...'];
                else
                    str{i} = ['...' str{i}(end-maxn+1:end)];
                end
            end
        end
        
        function keep_figure_on_top(hFig,state)
            % keep_figure_on_top(hFig,state)
            %
            % Maintain figure (figure handle = hFig) on top of all other windows if
            % state = true.
            %
            % No errors or warnings are thrown if for some reason this function is
            % unable to keep hFig on top.
                        
            narginchk(2,2);
            assert(ishandle(hFig),'The first input (hFig) must be a valid figure handle');
            assert(islogical(state)||isscalar(state),'The second input (state) must be true (1) or false (0)');
            
            
            drawnow expose
            
            try %#ok<TRYNC>
                warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                J = get(hFig,'JavaFrame');
                if verLessThan('matlab','8.1')
                    J.fHG1Client.getWindow.setAlwaysOnTop(state);
                else
                    J.fHG2Client.getWindow.setAlwaysOnTop(state);
                end
                warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            end
        end
    end
    
    
end