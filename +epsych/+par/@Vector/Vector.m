classdef Vector < epsych.par.Parameter
    
    % vvvvvvvvvvvvv Define Abstract Properties vvvvvvvvvvvvvvvvvvvvvv
    properties
        Value           (1,1)
        Data            (1,:)
    end
    
    properties (Dependent)
        N
        ValuesStr
    end
    
    properties (Constant)
        Type = 'vector';
    end
    % ^^^^^^^^^^^^ Define Abstract Properties ^^^^^^^^^^^^^^^^^^^^^^
    
    
    
    
    
    methods
        function obj = Vector(Name,Expression,varargin)            
            % call superclass constructor
            obj = obj@epsych.par.Parameter(Name,Expression,varargin);
        end
        
        
        function n = get.N(obj)
            n = length(obj.Values);
        end
        
        
        function c = get.ValuesStr(obj)
            c = cell(1,obj.N);
            for i = 1:obj.N
                c{i} = sprintf(obj.DispFormat,obj.Values(i)*obj.ScaleFactor);
            end
        end
    end
end