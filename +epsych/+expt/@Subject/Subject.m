classdef Subject < handle & dynamicprops & matlab.mixin.Copyable

    properties
        Name            (1,:) char {mustBeNonempty} = 'NO NAME';
        DOB             (1,1) datetime = datetime('today');
        ID              (1,:) char
        Sex             (1,:) char {mustBeMember(Sex,{'male','female'})} = 'female';
        BaselineWeight  (1,1) double {mustBePositive,mustBeFinite} = 1;
        ProtocolFile    (1,:) char
        BitmaskFile     (1,:) char    
        Note            (1,1) string

        Active          (1,1) logical = true;

        Data            (1,1) % epsych.Data
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
            f = {'Name','DOB','ID','Sex','ProtocolFile','BitmaskFile'};
            
            e = cellfun(@(a) isempty(obj.(a)),f);
            
            cellfun(@(a,b) log_write('Verbose','Subject "%s" - "%s" ready = %s',obj.Name,a,mat2str(b)),f,num2cell(~e));
                        
            ready = ~any(e);
        end
    end

end










