classdef Connector < handle & dynamicprops

    properties (SetAccess = protected)
        handle
    end

    properties (Abstract)
        Name         % name for the control
        Type         % typically the class name
        Description  % detailed information

        Mode         % updated from main program
    end

    properties (Abstract,Dependent)
        Status      % returns some indicator of connector status
    end

    methods (Abstract)
        prepare(obj,varargin)
        run(obj,varargin)
        cleanup(obj,varargin)
    end

    methods
        function obj = Connector
            % elevate Matlab.exe process to a high priority in Windows
            [~,~] = dos('wmic process where name="MATLAB.exe" CALL setpriority "high priority"');
        end
    end

end