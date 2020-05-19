classdef (ConstructOnLoad) Config < handle & dynamicprops & matlab.mixin.Copyable

    properties (AbortSet)
        LogDirectory  (1,:) char
        UserDirectory (1,:) char
        DataDirectory (1,:) char

        UserInterface (1,1) = @ep_GenericGUI;
        SaveFcn       (1,1) = @ep_SaveDataFcn;
        
        StartFcn    (1,1) = @epsych.expt.Runtime.start;
        TimerFcn    (1,1) = @epsych.expt.Runtime.timer;
        StopFcn     (1,1) = @epsych.expt.Runtime.stop;
        ErrorFcn    (1,1) = @epsych.expt.Runtime.error;

        AutoSaveRuntimeConfig (1,1) logical = true;
        AutoLoadRuntimeConfig (1,1) logical = true;
    end

    properties (Dependent)
        Status
    end

    properties (SetAccess = private)
        LastModified
    end


    properties (SetAccess = immutable)
        CreatedOn
    end

    methods
        function obj = Config(file)
            if nargin == 0, return; end % ConstructOnLoad

            if ischar(file) && isfile(file)
                obj = load(file,'-mat');
            else
                obj.CreatedOn = datestr(now);
            end
        end


        function modified(obj)
            obj.LastModified = datestr(now);
        end

        function s = get.Status(obj)
            if isempty(obj.SubjectConfig) ...
                || isempty(obj.BitmaskConfig) ...
                || isempty(obj.Hardware) ...
                s = epsych.ConfigStatus.NotReady;
            else
                s = epsych.ConfigStatus.Ready;
            end
        end

        function s = saveobj(obj)
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
                obj.UserDirectory = fullfile(epsych.Info.user_directory,'EPsych');
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