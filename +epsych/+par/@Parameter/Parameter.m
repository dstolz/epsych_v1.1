classdef Parameter < handle & matlab.mixin.Copyable & matlab.mixin.SetGet
    % P = epsych.par.Parameter(Name,Expression,'Property','Value',...)

    % vvvvvvvvvvvvv Define Abstract Properties vvvvvvvvvvvvvvvvvvvvvv    
    properties (Abstract,SetObservable)
        Data
    end
    
    properties (Abstract,SetAccess = private)
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
        Select          (1,:) char   {mustBeMember(Select,{'index','randIndex','randRange','custom'})} = 'index';
        SelectFunction  (1,1) % function handle
        DispFormat      (1,:) char = '%g';
        ScaleFactor     (1,1) double = 1;
        
        Bounds          (1,2) double
        
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
        
%         function v = get.Value(obj)
%             switch obj.Select
%                 case 'index'
%                     v = obj.Values(obj.Index);
% 
%                 case 'randIndex'
%                     obj.Index = randi(obj.N,1);
%                     v = obj.Values(obj.Index);        
%                 
%                 case 'randRange'
%                     s = obj.Values;
%                     a = min(s);
%                     b = max(s);
%                     r = rand(1);
%                     v = r * (b - a) + a;
%                     
%                 case 'custom'
%                     v = feval(obj.SelectFunction,obj);
%                     v = v .* obj.ScaleFactor;
%             end
%             
%             if v < obj.ValueBounds(1), v = obj.ValueBounds(1); end
%             if v > obj.ValueBounds(2), v = obj.ValueBounds(2); end
%             
%             v = v .* obj.ScaleFactor;
%             
%         end

%         function v = get.Values(obj)
% 
%             if iscell(obj.Expression)
%                 v = feval(obj.Expression{:});
%                 
%             elseif ischar(obj.Expression)
%                 v = eval(obj.Expression);
%             
%             elseif obj.isBuffer
%                 error('Buffers not yet implemented for Parameter')
% 
%             else
%                 v = obj.Expression;
%             end            
% 
%         end
        


%         function set.ValueBounds(obj,vb)
%             assert(numel(vb)==2 & isnumeric(vb),'epsych.par.Parameter:set.ValueBounds:InvalidEntry', ...
%                 'Parameter ValueBounds must contain 2 numeric values');
%             obj.ValueBounds = sort(vb(:)','ascend');
%         end
        
        function set.Select(obj,s)
            obj.Select = s;
            switch s
                case 'randRange'
                    assert(obj.N == 2,'epsych.par.Parameter:set.Select:InvalidNumVals', ...
                        'The randRange select option requires the parameter to have exactly 2 values');
                    obj.isRange = true;
            end
        end


        function set.SelectFunction(obj,h)
            obj.SelectFunction = h;
            obj.Select = 'custom';
        end
        
        
        function p = get.isPaired(obj)
            p = ~isempty(obj.PairName);
        end
    end

    
end