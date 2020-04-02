classdef Log < handle
    % L = epsych.log.Log([logFilename]);
    %
    % Verbosity controlled message logging.
    %
    % L.write('message'); % always print to screen and log
    % L.write(Verbosity,'message'); % print to screen and log if Verbosity is >= current obj.Verbosity (epsych.log.Verbosity)
    % L.write([Verbosity],'message %d of %d',1,10); % sprintf syntax
    % L.write([alwaysLog],[Verbosity],'message',....)
    % L.write([alwaysLog],[Verbosity],Structure) % limited, does not print name of structure variable
    % L.write(MException)
    % L = obj.write([alwaysLog],[Verbosity],msg,...); return message
    %
    % Use epsych.log.Verbosity enumeration class to control message priority
    %
    % DJS 2020
    
    properties
        Verbosity       (1,1) epsych.log.Verbosity = epsych.log.Verbosity.Important;
        
        hEchoTextArea           matlab.ui.control.TextArea
        LogFilenameLabel        matlab.ui.control.Label
        LogVerbosityDropDown    matlab.ui.control.DropDown
        
        LogFilename     (1,:) char
    end
    
    properties (Hidden,Transient)
        fid
    end
    
    
    methods
        create_gui(obj,parent);
        
        % Constructor
        function obj = Log(LogFilename,parent)
            if nargin == 0 || isempty(LogFilename)
                return
            end
            
            obj.LogFilename = LogFilename;
            
            if nargin == 2
                obj.create_gui(parent);
            end
            
        end
        
        % Destructor
        function delete(obj)
            obj.write(true,'Log Closed')
            try
                fclose(obj.fid);
            end
        end
        
        function set.Verbosity(obj,v)
            if ischar(v)
                v = epsych.log.Verbosity.(v);
            elseif isnumeric(v)
                v = epsych.log.Verbosity(int8(v));
            end
            obj.Verbosity = v;
            
            if ~isempty(obj.LogVerbosityDropDown) && isvalid(obj.LogVerbosityDropDown)
                obj.LogVerbosityDropDown.Value = v;
            end
            
            obj.write(true,epsych.log.Verbosity.Important,'Verbosity level set to: %s (%d)',v.char,int8(v));
        end
        
        function set.LogFilename(obj,ffn)
            obj.LogFilename = ffn;
            obj.fid = fopen(obj.LogFilename,'wt');
            if obj.fid == -1
                fprintf(2,'Unable to create log file: "%s"\n',obj.LogFilename)
                return
            end
            
            if ~isempty(obj.LogFilenameLabel) && isvalid(obj.LogFilenameLabel)
                obj.LogFilenameLabel.Text = obj.LogFilename;
            end
            
            obj.write(true,epsych.log.Verbosity.Important,'Log Initialized: %s',obj.LogFilename);
        end
        
        function msg = write(obj,varargin)
            % obj.write('message'); % always print to screen and log
            % obj.write(Verbosity,'message'); % print to screen and log if Verbosity is >= current obj.Verbosity (epsych.log.Verbosity)
            % obj.write([Verbosity],'message %d of %d',1,10); % sprintf syntax
            % obj.write([alwaysLog],[Verbosity],'message',....)
            % obj.write([alwaysLog],[Verbosity],Structure) % limited, does not print name of structure variable
            % obj.write(MException)
            % msg = obj.write([alwaysLog],[Verbosity],msg,...); return message
            
            
            tstr = datestr(now,'HH:MM:SS.FFF');
            
            msg = '';
            v = [];
            alwaysLog = false;
            
            for i = 1:length(varargin)
                if islogical(varargin{i}) % alwaysLog as logical
                    alwaysLog = varargin{i};
                    
                elseif ischar(varargin{i}) && isequal(lower(varargin{i}),'alwayslog') % alwaysLog as char
                    alwaysLog = true;
                    
                elseif isnumeric(varargin{i}) % verbosity as number or epsych.log.Verbosity enum
                    v = varargin{i};
                    
                elseif ischar(varargin{i}) % char version of epsych.log.Verbosity
                    try % best to avoid this syntax when worried about timing
                        v = epsych.log.Verbosity.(varargin{i});
                    catch % message first
                        msg = varargin{i};
                        break
                    end
                    

                elseif isstruct(varargin{i}) % display fields of the structure (only first level)
                    smsg = evalc('disp(varargin{i})');
                    msg = sprintf('Structure Fields: \n%s',smsg);
                    break
                    
                elseif isa(varargin{i},'MException') % error object - always printed and logged
                    alwaysLog = true;
                    v = epsych.log.Verbosity.Error;
                    msg = sprintf('%s\n\t%s\n\t',varargin{i}.identifier,varargin{i}.message);
                    dbs = varargin{i}.stack;
                    dbstr = '';
                    for j = 1:length(dbs)
                        dbstr = sprintf('Stack %d\n\tfile:\t%s\n\tname:\t%s\n\tline:\t%d', ...
                            j,msg.stack(j).file,msg.stack(j).name,msg.stack(j).line);
                    end
                    msg = sprintf('%s%s',msg,dbstr);
                    break
                end
            end
            
            if i < length(varargin)
                e = varargin(i+1:end);
                i = cellfun(@(a) isa(a,'function_handle'),e);
                if any(i)
                    e(i) = cellfun(@func2str,e(i),'uni',0);
                end
                msg = sprintf(msg,e{:});
            end
            
            % return early if we're not printing anything to the screen or the log file
            if ~alwaysLog && (isempty(v) || v > obj.Verbosity)
                msg = ''; % no message
                if nargout == 0, clear msg; end
                return
            end
            
            if isempty(v),   v = epsych.log.Verbosity.Verbose; end
            if isnumeric(v), v = epsych.log.Verbosity(v);  end
            if ischar(v),    v = epsych.log.Verbosity.(v); end
            
            msg = strrep(msg,'\','\\');
            
            msgTs = sprintf('%s: %s\n',tstr,msg);
            
            msgLog = sprintf('%s %2d %-10s %s: %s\n',tstr,int8(v),v.char,obj.get_stack_string,msg);
            
            
            noFile = obj.fid == -1;
            if ~noFile
                x = fopen(obj.fid);
                if isempty(x)
                    obj.fid = fopen(obj.LogFilename,'a+');
                end
            end
            
            if isempty(msg), v = epsych.log.Verbosity.PrintOnly; end % prints a blank line w/ timestamp, function, and line number
            
            noEchoTextArea = isempty(obj.hEchoTextArea) || ~isvalid(obj.hEchoTextArea);
            
            switch v
                case epsych.log.Verbosity.PrintOnly
                    if ~noFile, fprintf(obj.fid,msgLog); end
                    
                case epsych.log.Verbosity.ScreenOnly
                    if noEchoTextArea
                        fprintf(msgTs)
                    else
                        obj.hEchoTextArea.Value = [{msgTs}; obj.hEchoTextArea.Value];
                    end
                    
                case epsych.log.Verbosity.Error
                    if ~noFile, fprintf(obj.fid,msgLog); end
                    if noEchoTextArea
                        fprintf(2,msgTs); % red text
                    else
                        obj.hEchoTextArea.Value = [{msgTs}; obj.hEchoTextArea.Value];
                    end
                    
                otherwise
                    if v <= obj.Verbosity
                        if ~noFile, fprintf(obj.fid,msgLog); end
                        if noEchoTextArea
                            fprintf(msgTs)
                        else
                            obj.hEchoTextArea.Value = [{msgTs}; obj.hEchoTextArea.Value];
                        end
                        
                    elseif alwaysLog
                        if ~noFile, fprintf(obj.fid,msgLog); end
                    end
            end
            
            
            
            if nargout == 1
                msg = strrep(msg,'\\','\');
            else
                clear msg
            end
            
        end
        
        function open(obj)
            h = actxserver('WScript.Shell');
            
            try
                try
                    h.Run(sprintf('start "%s"',obj.LogFilename));
                catch
                    h.Run(sprintf('notepad++ -l "%s"',obj.LogFilename));
                end
            catch me
                edit(obj.LogFilename);
            end
            
            delete(h);
            clear h
        end
        
        
        
        function init_log_verbosity(obj,hObj,event)
            v = getpref('epsych_Log','logVerbosity',epsych.log.Verbosity.Important);
            hObj.Items = string(epsych.log.Verbosity(1:5));
            hObj.ItemsData = epsych.log.Verbosity(1:5);
            hObj.Value    = v;
            obj.Verbosity = v;
        end
        
        function update_log_verbosity(obj,hObj,event)
            obj.Verbosity = event.Value;
            setpref('epsych_Log','logVerbosity',event.Value);
        end
    end
    
    
    methods (Static)
        function fn = generate_LogFilename
            if exist('vlog','dir') ~= 7
                mkdir('vlog');
            end
            
            fn = sprintf('vlog_%s.txt',datestr(now,30));
            fn = fullfile('vlog',fn);
        end
        
        function s = get_stack_string
            s = '';
            st = dbstack(2);
            if isempty(st), return; end
            s = sprintf('%s,%d',st(1).name,st(1).line);
        end
        
    end
    
end