classdef Subject < handle & dynamicprops

    properties
        Name    (1,:) char {mustBeNonempty} = 'NONAME';
        DOB     (1,1) datetime = datetime('today');
        ID      (1,1) double {mustBeFinite,mustBeNonempty,mustBeNonNan} = round(datenum(now)*1e12);
        BaselineWeightGrams (1,1) double {mustBePositive,mustBeFinite} = 1;
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
    end

end