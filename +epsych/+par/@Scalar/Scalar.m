classdef Scalar < epsych.par.Parameter
    
    % vvvvvvvvvvvvv Define Abstract Properties vvvvvvvvvvvvvvvvvvvvvv    
    properties (SetObservable)
        Data
        Value
    end
    
    properties (Dependent)
        DataStr
        ValueStr
    end
    
    properties (Constant)
        Type = 'scalar';
    end    
    % ^^^^^^^^^^^^ Define Abstract Properties ^^^^^^^^^^^^^^^^^^^^^^
    
    methods
        function obj = Scalar(Name,Expression,varargin)
            
            % call superclass constructor
            obj = obj@epsych.par.Parameter(Name,Expression,varargin{:});
            
            if ~strcmpi('Select',varargin(1:2:end))
                if length(obj.Data) > 1
                    obj.Select = 'discrete';
                else
                    obj.Select = 'value';
                end
            end
        end
        
  
        function v = get.Value(obj)
            switch obj.Select
                case 'value'
                    v = obj.Data(1);
                case 'randRange'
                    [a,b] = bounds(obj.Data);
                    v = rand(1) * (b-a)+a;
                case 'randIndex'
                    v = randi(obj.N,1);
                case 'discrete'
                    v = obj.Data(obj.Index);
            end
        end
        
        function set.Data(obj,v)     
            obj.Expression = v;
        end
        
        function d = get.Data(obj)
            d = eval(obj.Expression);
        end
        
        function c = get.DataStr(obj)
            c = cell(1,obj.N);
            for i = 1:obj.N
                c{i} = sprintf(obj.DispFormat,obj.Data(i)/obj.ScaleFactor);
            end
        end
        
        function s = get.ValueStr(obj)
            s = sprintf(obj.DispFormat,obj.Value/obj.ScaleFactor);
        end
    end
end