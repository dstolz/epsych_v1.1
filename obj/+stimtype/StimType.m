classdef StimType
    
    properties
        Duration     (1,1) double {mustBePositive,mustBeFinite} = 0.1;  % seconds
        GateDuration (1,1) double {mustBePositive,mustBeFinite} = 0.002; % seconds
        GateFcn      (1,1) string = "cos2";
        
        Fs           (1,1) double {mustBePositive,mustBeFinite} = 48828.125; % Hz
    end
    
    properties (Dependent)
        N
    end
    
    methods (Abstract)
        
            
    end
    
    methods
        function y = generate(obj)
            
            y = 
        end
        
        
        function n = get.N(obj)
            
        end
    end
    
end