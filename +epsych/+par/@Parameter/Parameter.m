classdef Parameter < handle & matlab.mixin.Copyable & matlab.mixin.SetGet
    % P = epsych.par.Parameter(Name,Expression,'Property','Value',...)

    % vvvvvvvvvvvvv Define Abstract Properties vvvvvvvvvvvvvvvvvvvvvv    
    properties (Abstract,SetObservable,AbortSet)
        Data
        Value
    end
    
    properties (Abstract,Dependent)
        DataStr
        ValueStr
    end
    
    properties (Abstract,Constant)
        Type        % Parameter type, i.e. scalar, vector, file, etc
    end
    % ^^^^^^^^^^^^ Define Abstract Properties ^^^^^^^^^^^^^^^^^^^^^^

    
    properties (SetObservable,AbortSet)
        Expression      % uses eval
        Index           (1,1) double {mustBeInteger,mustBePositive,mustBeNonempty} = 1;
        Name            (1,:) char = 'UNKNOWN';
        PairName        (1,:) char
        Select          (1,:) char   {mustBeMember(Select,{'value','discrete','randRange','userfcn'})} = 'value';
        SelectFunction  (1,1) % function handle
        DispFormat      (1,:) char = '%g';
        ScaleFactor     (1,1) double = 1;
        
        Limits          (1,2) double = [-inf inf];
        
        uiControl       (1,1) % epsych.par.uiControl
    end

    
    properties (Dependent)
        N
        isPaired        (1,1) logical
    end

    methods
        function obj = Parameter(Name,Expression,varargin)
            if nargin == 0, return; end

            if nargin >= 1 && ~isempty(Name), obj.Name = Name; end
            if nargin >= 2 && ~isempty(Expression), obj.Expression = Expression; end
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych:par:Parameter:InvalidProperty', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end
            
            
            if ~strcmpi('Select',varargin(1:2:end))
                if length(obj.Data) > 1
                    obj.Select = 'discrete';
                else
                    obj.Select = 'value';
                end
            end
        end
        
        
        function n = get.N(obj)
            n = length(obj.Data);
        end
        
        function set.Index(obj,idx)
            if idx < 1, idx = 1;         end
            if idx > obj.N, idx = obj.N; end
            obj.Index = idx;
        end
        
        
        function set.Expression(obj,e)
            if isnumeric(e)
                e = mat2str(e);
            end
            
            obj.Expression = e;            
        end
         
        function set.uiControl(obj,h)
            obj.uiControl = epsych.par.uiControl(obj,h);
            
        end


        function set.SelectFunction(obj,h)
            obj.SelectFunction = h;
            obj.Select = 'userfcn';
        end
        
        
        function p = get.isPaired(obj)
            p = ~isempty(obj.PairName);
        end

        
    end

    
end