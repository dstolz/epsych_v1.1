classdef Tone < stimtype.StimType
    
    properties
        Frequency (1,1) double {mustBePositive,mustBeFinite} = 1000; % Hz
        
    end
    
    methods
        function obj = Tone(varargin)
            
        end
    end
end