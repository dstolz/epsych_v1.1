classdef (ConstructOnLoad) Config < handle & dynamicprops & matlab.mixin.Copyable

    properties (AbortSet)
        LogDirectory  (1,:) char
        UserDirectory (1,:) char
        DataDirectory (1,:) char

        UserInterface (1,1) = @ep_GenericGUI;
        SaveFcn       (1,1) = @ep_SaveDataFcn;
        
        StartFcn      (1,1) = @epsych.expt.Runtime.startFcn;
        TimerFcn      (1,1) = @epsych.expt.Runtime.timerFcn;
        StopFcn       (1,1) = @epsych.expt.Runtime.stopFcn;
        ErrorFcn      (1,1) = @epsych.expt.Runtime.errorFcn;
        
        TimerPeriod   (1,1) double {mustBePositive,mustBeFinite} = .01;

        AutoSaveRuntimeConfig     (1,1) logical = true;
        AutoLoadRuntimeConfig     (1,1) logical = true;
    end

    properties (Dependent)
        Status
    end

    properties (SetAccess = private)
        LastModified
        Filename
        CreatedOn
    end

    methods
        function obj = Config(file)
            if nargin == 0, return; end % ConstructOnLoad

            if ischar(file) && isfile(file)
                obj = load(file,'-mat');
                obj.Filename = file;
            else
                obj.CreatedOn = datestr(now);
            end
        end


        function s = get.Status(obj)
            D = {'LogDirectory','UserDirectory','DataDirectory'};
            s = all(cellfun(@(a) isfolder(obj.(a)),D));
            
            D = {'UserInterface','SaveFcn','StartFcn','TimerFcn','StopFcn','ErrorFcn'};
            s = s && all(cellfun(@(a) isa(obj.(a),'function_handle') && ~isempty(which(func2str(obj.(a)))),D));
        end

        function s = saveobj(obj)
            obj.LastModified = datestr(now);
            if isempty(obj.CreatedOn)
                obj.CreatedOn = obj.LastModified;
            end
            s = obj;
        end

        
        function d = get.LogDirectory(obj)
            if isempty(obj.LogDirectory)
                obj.LogDirectory = fullfile(obj.UserDirectory,'Logs');
            end
            try
                if ~isfolder(obj.LogDirectory), mkdir(obj.LogDirectory); end
                d = obj.LogDirectory;
            catch me
                log_write('Error',me);
                d = epsych.Info.user_directory;
            end
            
        end

        function d = get.UserDirectory(obj)
            if isempty(obj.UserDirectory)
                obj.UserDirectory = epsych.Info.user_directory;
                if ~isfolder(obj.UserDirectory), mkdir(obj.UserDirectory); end
            end
            d = obj.UserDirectory;
        end
        
        function set.UserDirectory(obj,d)
            assert(isfolder(d),'epsych:expt:Config:UserDirectory:InvalidDirectory', ...
                sprintf('Directory "%s" does not exist',d))
            obj.UserDirectory = d;
            setpref('epsych_Info','user_directory',d);
        end

        function d = get.DataDirectory(obj)
            if isempty(obj.DataDirectory)
                obj.DataDirectory = fullfile(obj.UserDirectory,'Data');
            end
            if ~isfolder(obj.DataDirectory)
                mkdir(obj.DataDirectory);
            end
            d = obj.DataDirectory;
        end
    end % methods (Access = public)


    methods (Static)
        function obj = loadobj(s)
            obj = s;
        end
    end
end