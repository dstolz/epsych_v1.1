classdef (ConstructOnLoad) Hardware < handle & dynamicprops & matlab.mixin.Copyable
    % Inheritable superclass for defining hardware abstraction
    %
    % Superclass constructor must be called from inheriting subclass: 
    %   obj = obj@epsych.hw.Hardware;
    %
    % Abstract properties and methods must be defined in subclass
    %
    % h = interface(obj,parent);    % minimal gui to set custom parameters
    %
    % e = prepare(obj,varargin);    % complete any required tasks before run
    % e = start(obj,varargin);      % establish connection to hardware (if not already connected) and run
    % e = runtime(obj,varargin);    % called on each tick of the master clock
    % e = stop(obj,varargin);       % stop running hardware
    % 
    % e = write(obj,parameter,value); % write (update) parameter value
    % v = read(obj,parameter);    % read current parameter value
    % e = trigger(obj,parameter);     % send a trigger


    % vvvvvvvv ABSTRACT PROPERTIES AND METHODS vvvvvvvv
    properties (Abstract)
        Alias           % user-supplied identifier
    end
    
    properties (Abstract,Constant)
        Name            % name for the control
        Type            % typically the class name
        Description     % detailed information
        Vendor          % who made it
        MaxNumInstances % determines max number of instances of this hardware can be used at once
    end
    
    properties (Abstract,Dependent)
        Status          % returns indicator of connector status: epsych.hw.enStatus
    end

    properties (Abstract, Access = protected)
        ErrorME         % MException error message object
    end

    methods (Abstract)
        h = setup(obj,parent);      % minimal gui to set custom parameters
        e = prepare(obj,varargin);  % complete any required tasks before runtime
        e = start(obj,varargin);    % establish connection to hardware (if not already connected) and run
        e = runtime(obj,varargin);  % called on each tick of the master clock
        e = stop(obj,varargin);     % stop running hardware

        % write(obj,parameter,value); % write (update) parameter value
        % v = read(obj,parameter);    % read current parameter value
        % trigger(obj,parameter);     % send a trigger
    end

    % ^^^^^^^^^ ABSTRACT PROPERTIES AND METHODS ^^^^^^^^^



    properties (Dependent)
        isReady (1,1) logical
    end

    properties (Access = protected, Transient)
        % el_PostSet
    end
    methods
        % Constructor
        function obj = Hardware
            % % monitor changes in SetObservable hardware properties and notify anyone listening
            % m = metaclass(obj);
            % ind = [m.PropertyList.SetObservable];
            % if any(ind)
            %     psp = {m.PropertyList(ind).Name};
            %     obj.el_PostSet = cellfun(@(a) addlistener(obj,a,'PostSet',@epsych.expt.Runtime.runtime_updated),psp);
            % end
        end
    end % methods



    methods (Static)
        function c = available
            w = which('epsych.hw.Hardware');
            d = dir(fileparts(fileparts(w)));
            d(~startsWith({d.name},'@')) = [];
            c = cellfun(@(a) a(2:end),{d.name},'uni',0);
            c(ismember(c,'Hardware')) = [];
            ind = false(size(c));
            for i = 1:length(c)
                s = superclasses(['epsych.hw.' c{i}]);
                ind(i) = isempty(s) || ~ismember('epsych.hw.Hardware',s);
            end
            c(ind) = [];
        end
    end

end