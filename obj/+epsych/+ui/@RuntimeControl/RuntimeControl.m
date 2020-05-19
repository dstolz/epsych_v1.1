classdef RuntimeControl < handle
    
    properties
        
    end

    properties (Access = protected)
        StateLabel   matlab.ui.control.Label
        % StateLamp    matlab.ui.control.Lamp
        StateIcon    matlab.ui.control.UIAxes
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
            global RUNTIME

            narginchk(0,2)
            
            if nargin == 2, obj.Orientation = Orientation; end
            
            create(obj,parent)
            
            obj.parent = parent;

            addlistener(RUNTIME,'PreStateChange',@obj.listener_PreStateChange);
            addlistener(RUNTIME,'PostStateChange',@obj.listener_PostStateChange);

            if nargout == 0, clear obj; end
        end
        
        function update_state(obj,btn)
            global RUNTIME LOG

            switch btn
                case 'Run|Halt'
                    switch RUNTIME.State
                        case epsych.enState.Prep
                            LOG.write('Verbose','Updating State: Prep -> Run');
                            RUNTIME.State = epsych.enState.Run;

                        case [epsych.enState.Run, epsych.enState.Preview]
                            LOG.write('Verbose','Updating State: %s -> Halt',char(RUNTIME.State));
                            RUNTIME.State = epsych.enState.Halt;

                        case epsych.enState.Halt
                            LOG.write('Verbose','Updating State: Halt -> Run');
                            RUNTIME.State = epsych.enState.Run;
                    end

                case 'Pause'
                    switch RUNTIME.State
                        case epsych.enState.Pause
                            LOG.write('Verbose','Updating State: Pause -> Resume');
                            RUNTIME.State = epsych.enState.Resume;

                        case [epsych.enState.Run, epsych.enState.Preview]
                            LOG.write('Verbose','Updating State: %s -> Pause',char(RUNTIME.State));
                            RUNTIME.State = epsych.enState.Pause;
                    end
            end
            
        end
        
    end % methods (Access = public)

    methods (Access = private)
        function listener_PreStateChange(obj,hObj,event)
            % update GUI component availability

            obj.RunButton.Enable = 'off';
            obj.PauseButton.Enable = 'off';
            
            epsych.Tool.set_icon(obj.StateIcon,'Waiting');

            drawnow

            
        end
        

        function listener_PostStateChange(obj,hObj,event)            
            % update GUI component availability
            
            
            switch event.State
                case epsych.enState.Prep
                    icon = 'config';

                case epsych.enState.Run
                    obj.RunButton.Enable = 'on';
                    obj.PauseButton.Enable = 'on';
                    icon = 'Running';

                case epsych.enState.Preview
                    obj.RunButton.Enable = 'on';
                    obj.PauseButton.Enable = 'on';
                    icon = 'preview';

                case epsych.enState.Pause
                    obj.RunButton.Enable = 'on';
                    obj.PauseButton.Enable = 'on';
                    icon = 'pause';

                case epsych.enState.Resume
                    obj.RunButton.Enable = 'on';
                    obj.PauseButton.Enable = 'on';
                    icon = 'Running';

                case epsych.enState.Halt
                    obj.RunButton.Enable = 'on';
                    obj.PauseButton.Enable = 'off';
                    icon = 'finish_line';
                    
                case epsych.enState.Error
                    obj.RunButton.Enable = 'off';
                    obj.PauseButton.Enable = 'off';
                    icon = 'Error';
            end

            epsych.Tool.set_icon(obj.StateIcon,icon);
            
            drawnow
        end
    end % methods (Access = private)
end