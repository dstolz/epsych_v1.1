classdef Scalar < epsych.par.Parameter
    
    % vvvvvvvvvvvvv Define Abstract Properties vvvvvvvvvvvvvvvvvvvvvv    
    properties
        Value           (1,1)
        Data            (1,:)
    end
    
    properties (Dependent)
        N
        DataStr
        ValueStr
    end
    
    properties (Constant)
        Type = 'scalar';
    end
    
    % ^^^^^^^^^^^^ Define Abstract Properties ^^^^^^^^^^^^^^^^^^^^^^
    
    properties (SetAccess = immutable)
        isRange     (1,1) logical = false;
        isLogical   (1,1) logical = false;
    end
    
    
    
    methods
        function obj = Scalar(Name,Expression,varargin)
            
            % call superclass constructor
            obj = obj@epsych.par.Parameter(Name,Expression,varargin);
            
            if obj.isRange
                assert(length(obj.Data)==2, ...
                    'epsych:par:Scalar:InvalidData', ...
                    'A parameter that is range must have 2 values');
            end
            
            if obj.isLogical
                assert(islogical(obj.Data)&length(obj.Data)==1, ....
                    'epsych:par:Scalar:InvalidData', ...
                    'A parameter that is logical must have 1 logical value');
            end
        end
        
        
        function n = get.N(obj)
            n = length(obj.Values);
        end
        
        
        
        
        function c = get.DataStr(obj)
            c = cell(1,obj.N);
            for i = 1:obj.N
                c{i} = sprintf(obj.DispFormat,obj.Data(i)*obj.ScaleFactor);
            end
        end
        
        function s = get.ValueStr(obj)
            s = sprintf(obj.DispFormat,obj.Value*obj.ScaleFactor);
        end
    end
end