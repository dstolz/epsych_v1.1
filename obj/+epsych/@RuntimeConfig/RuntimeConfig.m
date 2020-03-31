classdef (ConstructOnLoad) RuntimeConfig < handle & dynamicprops

    properties
        
        LogDirectory  (1,:) char
        UserDirectory (1,:) char
        DataDirectory (1,:) char

        UserInterface (1,1) = @ep_GenericGUI;
        SaveFcn       (1,1) = @ep_SaveDataFcn;
        
        % TODO: Default timer functions need to be revamped for new object format
        StartFcn    (1,1) = @ep_TimerFcn_Start;
        TimerFcn    (1,1) = @ep_TimerFcn_RunTime;
        StopFcn     (1,1) = @ep_TimerFcn_Stop;
        ErrorFcn    (1,1) = @ep_TimerFcn_Error;

        AutoSaveRuntimeConfig (1,1) logical = true;
    
        SubjectConfig
        BitmaskConfig
    end

    properties (Dependent)
        Status
    end

    properties (SetAccess = private)
        LastModified
        ConfigSaved     (1,1) logical = false;
    end

    properties (SetAccess = immutable)
        CreatedOn
    end

    methods
        function obj = RuntimeConfiguration(file)
            if nargin == 0, return; end % ConstructOnLoad

            if ischar(file) && isfile(file)
                obj = load(file,'-mat');
            else
                obj.CreatedOn = datestr(now);
            end
        end

        function modified(obj)
            obj.LastModified = datestr(now);
            obj.ConfigSaved = false;
        end

        function s = get.Status(obj)
            if isempty(obj.SubjectConfig) ...
                || isempty(obj.BitmaskConfig) ...
                || isempty(obj.Hardware) ...
                || ~obj.ConfigSaved
                s = epsych.ConfigStatus.NotReady;
            else
                s = epsych.ConfigStatus.Ready;
            end
        end

        function s = saveobj(obj)
            obj.ConfigSaved = true;
            s = obj;
        end

        
        function d = get.LogDirectory(obj)
            if isempty(obj.LogDirectory)
                obj.LogDirectory = fullfile(obj.UserDirectory,'Logs');
            end
            if ~isfolder(obj.LogDirectory), mkdir(obj.LogDirectory); end
            d = obj.LogDirectory;
        end

        function d = get.UserDirectory(obj)
            if isempty(obj.UserDirectory)
                ud = char(java.lang.System.getProperty('user.home'));
                obj.UserDirectory = fullfile(ud,'EPsych');
                if ~isfolder(obj.UserDirectory), mkdir(obj.UserDirectory); end
            end
            d = obj.UserDirectory;
        end

        function d = get.DataDirectory(obj)
            if isempty(obj.DataDirectory)
                obj.DataDirectory = fullfile(obj.UserDirectory,'Data');
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