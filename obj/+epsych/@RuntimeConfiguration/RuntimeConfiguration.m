classdef (ConstructOnLoad) RuntimeConfiguration < handle & dynamicprops

    properties
        Config

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
    end

    methods (Static)
        function obj = loadobj(s)
            obj = s;
        end
    end
end