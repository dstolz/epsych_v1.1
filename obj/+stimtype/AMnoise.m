classdef AMnoise < stimtype.Noise & stimtype.StimType
    
    properties
        AMDepth (1,1) double {mustBeInRange(AMDepth,0,1)} = 1; % [0 1] 
        AMRate  (1,1) double {mustBePositive,mustBeFinite} = 5; % Hz
        OnsetPhase (1,1) double = 0; % degrees
        
        ApplyViemeisterCorrection (1,1) logical = true;
    end
    
    
    methods
                
        function obj = AMnoise(varargin)
            obj = obj@stimtype.StimType(varargin{:});
            
            obj.create_listeners;
        end
        
        
        function update_signal(obj)
            obj.temporarilyDisableSignalMods = true;
            
            update_signal@stimtype.Noise(obj);
            noise = obj.Signal;
            
            obj.temporarilyDisableSignalMods = false;

            
            am = cos(2.*pi.*obj.AMRate.*obj.Time+deg2rad(obj.OnsetPhase));
            am = (am + 1)./2;
            am = am .* obj.AMDepth + obj.AMDepth;
            
            if obj.ApplyViemeisterCorrection
                am = am .* sqrt(1/(obj.AMDepth^2/2+1));
            end
            
            obj.Signal = noise .* am;
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    
    end
    
end
