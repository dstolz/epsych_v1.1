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
        DataClass = 'scalar';
    end    
    % ^^^^^^^^^^^^ Define Abstract Properties ^^^^^^^^^^^^^^^^^^^^^^
    
    methods
        function obj = Scalar(Name,Expression,varargin)
            
            % call superclass constructor
            obj = obj@epsych.par.Parameter(Name,Expression,varargin{:});
            
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
                case 'custom'
                    v = feval(obj.SelectFunction,obj.Data);
            end
            
            if v < obj.Limits(1), v = obj.Limits(1); end
            if v > obj.Limits(2), v = obj.Limits(2); end
                
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