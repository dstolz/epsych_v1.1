classdef Hardware < handle & dynamicprops
    % Abstract properties and methods must be defined in subclass

    properties (Abstract,Constant)
        Name         % name for the control
        Type         % typically the class name
        Description  % detailed information
    end
    
    properties (Abstract)
        State        % updated from main program
    end

    properties (Abstract,SetAccess = private)
        handle       % handle to ActiveX or SDK or whatever 
    end

    properties (Abstract,Dependent)
        Status       % returns some indicator of connector status
    end

    methods (Abstract)
        prepare(obj,varargin);
        run(obj,varargin);
        stop(obj,varargin);

        write(obj,parameter,value);
        v = read(obj,parameter);
        trigger(obj,parameter);
    end

    methods (Static)
        function c = available
            w = which('hardware.Hardware');
            r = fileparts(fileparts(w));
            d = dir(fullfile(r));
            c = {d.name};
            i = cellfun(@(a) a(1)=='@',c);
            c(i) = cellfun(@(a) a(2:end),c(i),'uni',0);
            ind = false(size(c));
            for i = 1:length(c)
                s = superclasses(['hardware.' c{i}]);
                ind(i) = isempty(s) || ~ismember('hardware.Hardware',s);
            end
            c(ind) = [];
        end
    end

end