classdef RuntimeControl < handle
    
    properties
        
    end

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
        
        function update_state(obj,btn)
            global RUNTIME

            switch btn
                case 'Run|Halt'
                    switch RUNTIME.State
                        case epsych.State.Prep
                            RUNTIME.State = epsych.State.Run;

                        case [epsych.State.Run, epsych.State.Preview]
                            RUNTIME.State = epsych.State.Halt;

                        case epsych.State.Halt
                            RUNTIME.State = epsych.State.Run;
                    end

                case 'Pause'
                    switch RUNTIME.State
                        case epsych.State.Pause
                            RUNTIME.State = epsych.State.Resume;

                        case [epsych.State.Run, epsych.State.Preview]
                            RUNTIME.State = epsych.State.Pause;
                    end
            end
            
        end
        
    end
end