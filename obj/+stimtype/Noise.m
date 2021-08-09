classdef Noise < stimtype.StimType
    
    properties
        HighPass  (1,1) double {mustBeNonnegative,mustBeFinite} = 25; % Hz
        LowPass   (1,1) double {mustBeNonnegative,mustBeFinite} = 20000; % Hz
        
        
    end
    
    methods
                
        function obj = Noise(varargin)
            obj = obj@stimtype.StimType(varargin{:});
        end
        
        function update_signal(obj)
            t = obj.Time;

            obj.Signal = randn(1,length(t));
            
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    
    end
    
end
