classdef RCdecoder
    
    properties (Constant)
        BitDefs = epsych.BitMask(0:19);
    end
    
    properties (Dependent)
        HitRate
    end
    
    methods
        function obj = RCdecoder(RC)
            
        end
        
        function c = decode(obj)
            
            for i = 1:length(obj.BitDefs)
                
            end
            
        end
        
        
        function hr = get.HitRate(obj)
            
        end
    end
    
end