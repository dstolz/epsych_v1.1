classdef Subject < handle & dynamicprops & matlab.mixin.Copyable

    properties
        Name            (1,:) char {mustBeNonempty} = 'NO NAME';
        DOB             (1,1) datetime = datetime('today');
        ID              (1,:) char
        Sex             (1,:) char {mustBeMember(Sex,{'male','female','unknown'})} = 'unknown';
        BaselineWeight  (1,1) double {mustBePositive,mustBeFinite} = 1;
        ProtocolFile    (1,:) char
        BitmaskFile     (1,:) char    
        Note            (1,1) string

        Active          (1,1) logical = true;
    end

    properties (Dependent)
        isReady (1,1) logical
    end

    properties (Constant)
        CreatedOn = datetime('now');
    end

    methods
        function obj = Subject(varargin)
            pn = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(varargin{i},pn);
                if isempty(ind)
                    obj.addprop(varargin{i});
                    obj.(varargin{i}) = varargin{i+1};
                else
                    obj.(pn{ind}) = varargin{i+1};
                end
            end
        end

        function ready = get.isReady(obj)
            % TODO: test data fields
            ready = true;
        end
    end

end