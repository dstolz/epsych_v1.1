classdef epsych < handle
    
    properties
        ControlPanel
        Runtime
    end
    
    properties (SetAccess = 'immutable')
        Paths
    end
    
    methods
        function obj = epsych(varargin)
            global RUNTIME
            
            obj.Paths = obj.epsych_startup;
            
            
            % INITIALIZE RUNTIME OBJECT
            if isempty(RUNTIME) || ~isvalid(RUNTIME)
                RUNTIME = epsych.expt.Runtime;
                
            end
            
            % INITIALIZE SESSION LOG
            if isempty(RUNTIME.Log) || ~isvalid(RUNTIME.Log)
                fn = sprintf('EPsychLog_%s.txt',datestr(now,30));
                RUNTIME.Log = epsych.log.Log(fullfile(RUNTIME.Config.LogDirectory,fn));
            end

            obj.Runtime = RUNTIME;
            
            
            obj.ControlPanel = epsych.ui.ControlPanel(obj,varargin{:});
            
            
            
            % elevate Matlab.exe process to a high priority in Windows
            pid = feature('getpid');
            [~,msg] = dos(sprintf('wmic process where processid=%d CALL setpriority 128',pid));
            log_write('Debug',msg);
            
        end
        
        function delete(obj)
            delete(obj.Runtime);
            
            % be nice and return Matlab.exe process to normal priority in Windows
            pid = feature('getpid');
            [~,~] = dos(sprintf('wmic process where processid=%d CALL setpriority 32',pid));
            
            clear global RUNTIME
        end
        
        function subdirs = epsych_startup(obj,rootdir,showsplash)
            % epsych_startup;
            % epsych_startup(rootdir [,showsplash])
            % newp = epsych_startup(...)
            %
            % Finds all subdirectories in a given root directory, removes any
            % directories with 'svn', and adds them to the Matlab path.
            %
            % Typically, it is a good idea to call this function in the startup.m file
            % which should be located somewhere along the default Matlab path.
            % ex: ..\My Documents\MATLAB\startup.m
            %
            % Here's an example of what to include in startup.m:
            %    addpath('C:\gits\epsych');
            %    epsych_startup;
            %
            % Alternatively, call this function only after retrieving software updates
            % using SVN.
            %
            % Use a period '.' as the first character in a directory name to hide it
            % from being added to the Matlab path.  Ex: C:\MATLAB\work\epsych\.RPvds
            %
            % Default rootdir is wherever this function lives.
            
            
            
            warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
            warning('off','MATLAB:ui:actxcontrol:FunctionToBeRemoved');
            
            if nargin < 3 || isempty(showsplash), showsplash = true; end
            
            if showsplash, epsych_printBanner; end
            
            fprintf('\nSetting Paths for EPsych Toolbox ...')
            
            if nargin < 2 || isempty(rootdir)
                [rootdir,~] = fileparts(fileparts(mfilename('fullpath')));
            end
            
            assert(isfolder(rootdir),'Default directory "%s" not found. See help epsych_startup',rootdir)
            
            oldpath = genpath(rootdir);
            c = textscan(oldpath,'%s','Delimiter',';');
            warning('off','MATLAB:rmpath:DirNotFound');
            cellfun(@rmpath,c{1});
            warning('on','MATLAB:rmpath:DirNotFound');
            
            addpath(rootdir);
            
            p = genpath(rootdir);
            
            t = textscan(p,'%s','delimiter',';');
            i = cellfun(@(x) (strfind(x,'\.')),t{1},'UniformOutput',false);
            ind = cell2mat(cellfun(@isempty,i,'UniformOutput',false));
            subdirs = cellfun(@(x) ([x ';']),t{1}(ind),'UniformOutput',false);
            subdirs = cell2mat(subdirs');
            
            addpath(subdirs);
            path(path)
            fprintf(' done\n')
            
            if nargout == 0, clear subdirs; end
            
        end
    end
    
end