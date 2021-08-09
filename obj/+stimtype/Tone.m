classdef Tone < stimtype.StimType
    
    properties
        Frequency (1,1) double {mustBePositive,mustBeFinite} = 1000; % Hz
        OnsetPhase (1,1) double = 0;
    end
    
    methods
        function obj = Tone(varargin)
            obj = obj@stimtype.StimType(varargin{:});
        end
        
        function update_signal(obj)
            t = obj.Time;
            
            obj.Signal = sin(2.*pi.*obj.Frequency.*t+obj.OnsetPhase);
            
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    end
end