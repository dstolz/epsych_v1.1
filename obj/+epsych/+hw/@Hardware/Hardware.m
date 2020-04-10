classdef Hardware < handle & dynamicprops & matlab.mixin.Copyable
    % Abstract properties and methods must be defined in subclass
    %
    % h = interface(obj,parent);  % minimal gui to set custom parameters
    % prepare(obj,varargin);      % complete any required tasks before run
    % run(obj,varargin);          % establish connection to hardware (if not already connected) and run
    % stop(obj,varargin);         % stop running hardware
    % 
    % write(obj,parameter,value); % write (update) parameter value
    % v = read(obj,parameter);    % read current parameter value
    % trigger(obj,parameter);     % send a trigger

    properties (Abstract,Constant)
        Name         % name for the control
        Type         % typically the class name
        Description  % detailed information
    end
    
    properties (Abstract)
        State        % updated from main program
    end

    properties (Abstract,Dependent)
        Status       % returns some indicator of connector status
    end

    methods (Abstract)
        h = setup(obj,parent);      % minimal gui to set custom parameters
        prepare(obj,varargin);      % complete any required tasks before run
        run(obj,varargin);          % establish connection to hardware (if not already connected) and run
        stop(obj,varargin);         % stop running hardware

        write(obj,parameter,value); % write (update) parameter value
        v = read(obj,parameter);    % read current parameter value
        trigger(obj,parameter);     % send a trigger
    end

    methods (Static)
        function c = available
            w = which('epsych.hw.Hardware');
            r = fileparts(fileparts(w));
            d = dir(fullfile(r));
            d(~[d.isdir]) = [];
            c = {d.name};
            c(cellfun(@(a) a(1)~='@',c)) = [];
            c = cellfun(@(a) a(2:end),c,'uni',0);
            ind = false(size(c));
            for i = 1:length(c)
                s = superclasses(['epsych.hw.' c{i}]);
                ind(i) = isempty(s) || ~ismember('epsych.hw.Hardware',s);
            end
            c(ind) = [];
        end
    end

end