classdef RuntimeControl < handle
    
    properties
        
    end

    properties (Access = protected)
        % StateLabel   matlab.ui.control.Label
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

            RUNTIME.State = epsych.enState.Prep;

            if nargout == 0, clear obj; end
        end
        
        function update_state(obj,hObj,event,btn)
            global RUNTIME LOG

            switch btn
                case 'Run|Halt'
                    switch RUNTIME.State
                        case epsych.enState.Ready
                            LOG.write('Verbose','Updating State: Prep -> Run');
                            RUNTIME.State = epsych.enState.Run;

                        case {epsych.enState.Run, epsych.enState.Preview, epsych.enState.Pause, epsych.enState.Resume}
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

                        case {epsych.enState.Run, epsych.enState.Preview, epsych.enState.Resume}
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

            epsych.Tool.set_icon(obj.StateIcon,'Thinking');

            drawnow
            
        end
        

        function listener_PostStateChange(obj,hObj,event)            
            % update GUI component availability
            
            
            switch event.State
                case epsych.enState.Prep
                    obj.RunButton.Enable   = 'off';
                    obj.PauseButton.Enable = 'off';
                    stateIndicatorIcon   = 'config';
                    runButtonIcon   = 'play';
                    pauseButtonIcon = 'interface';

                case epsych.enState.Ready
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'off';
                    stateIndicatorIcon   = 'Ready';
                    runButtonIcon   = 'play';
                    pauseButtonIcon = 'interface';

                case epsych.enState.Run
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'on';
                    stateIndicatorIcon   = 'Running';
                    runButtonIcon   = 'stop';
                    pauseButtonIcon = 'interface';

                case epsych.enState.Preview
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'on';
                    stateIndicatorIcon   = 'preview';
                    runButtonIcon   = 'stop';
                    pauseButtonIcon = 'interface';

                case epsych.enState.Pause
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'on';
                    stateIndicatorIcon   = 'pause';
                    runButtonIcon   = 'stop';
                    pauseButtonIcon = 'play_pause';

                case epsych.enState.Resume
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'on';
                    stateIndicatorIcon   = 'Running';
                    runButtonIcon   = 'stop';
                    pauseButtonIcon = 'interface';

                case epsych.enState.Halt
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'off';
                    stateIndicatorIcon   = 'finish_line';
                    runButtonIcon   = 'play';
                    pauseButtonIcon = 'interface';
                    
                case epsych.enState.Error
                    obj.RunButton.Enable   = 'on';
                    obj.PauseButton.Enable = 'off';
                    stateIndicatorIcon   = 'Error';
                    runButtonIcon   = 'play';
                    pauseButtonIcon = 'interface';
            end

            epsych.Tool.set_icon(obj.StateIcon,stateIndicatorIcon);
            obj.RunButton.Icon   = epsych.Tool.icon(runButtonIcon);
            obj.PauseButton.Icon = epsych.Tool.icon(pauseButtonIcon);

            drawnow
        end
    end % methods (Access = private)
end