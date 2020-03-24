classdef RuntimeControl < handle
    properties (Access = protected)
        StateLabel   matlab.ui.control.Label
        StateLamp    matlab.ui.control.Lamp
        PauseButton  matlab.ui.control.Button
        RunButton    matlab.ui.control.Button
    end
    
    properties (SetAccess = immutable)
        Orientation (1,:) char {mustBeMember(Orientation,{'horizontal','vertical'})} = 'horizontal';
        parent
    end
    
    methods
        create(obj,parent);
        
        function obj = RuntimeControl(parent,Orientation)
            narginchk(0,2)
            
            if nargin == 2, obj.Orientation = Orientation; end
            
            create(obj,parent)
            
            obj.parent = parent;
            
            if nargout == 0, clear obj; end
        end
        
        function update_state(obj)
            global RUNTIME

            % TODO: Connector has not yet been developed.
            RUNTIME = epsych.Runtime(Connector);
            
        end
        
    end
end