classdef CustomizationSetup < handle

    properties
        LogDirectory    (1,:) char = '< default >';
        UserInterface   (1,:) char = 'ep_GenericGUI';
        SaveFcn         (1,:) char = 'ep_SaveDataFcn';
        StartFcn        (1,:) char = 'ep_TimerFcn_Stop';
        TimerFcn        (1,:) char = 'ep_TimerFcn_RunTime';
        StopFcn         (1,:) char = 'ep_TimerFcn_Stop';
        ErrorFcn        (1,:) char = 'ep_TimerFcn_Error';
    end

    properties (SetAccess = immutable)
        parent
    end

    methods
        create(obj,parent);

        function obj = CustomizationSetup(parent)
            obj.create(parent);
            obj.parent = parent;
        end

        function create_field(obj,hObj,event)
            hObj.Value = obj.(hObj.Tag);
        end
        
        function update_field(obj,hObj,event)
            obj.(hObj.Tag) = obj.check_function(event);
            hObj.Value = obj.(hObj.Tag);
        end

        function create_log_field(obj,hObj,event)
            global RUNTIME
            hObj.Value = RUNTIME.Info.LogDirectory;
        end

        function update_log_directory(obj,hObj,event)
            if ~isfolder(event.Value)
                uialert(ancestor(obj.parent,'figure'), ...
                    sprintf('Directory does not exist: "%s"',event.Value), ...
                    'Invalid Directory', ...
                    'Icon','Warning');
                hObj.Value = event.PreviousValue;
            end
            obj.LogDirectory = event.Value;
        end

        function locate_log_directory(obj,hObj,event)
            global RUNTIME
            d = uigetdir(RUNTIME.Info.LogDirectory,'Choose Log Directory');
            if isequal(d,0), return; end
            obj.LogDirectory = d;
            epsych.Tool.restart_required(obj.parent);
        end

        function set.LogDirectory(obj,d)
            global RUNTIME
            RUNTIME.Info.LogDirectory = d;
        end

        function set.UserInterface(obj,s)
            h = findobj(obj.parent,'Tag','UserInterface');
            h.Value = s;
            obj.UserInterface = s;
        end
        
        function set.StartFcn(obj,s)
            h = findobj(obj.parent,'Tag','StartFcn');
            h.Value = s;
            obj.StartFcn = s;
        end
        
        function set.TimerFcn(obj,s)
            h = findobj(obj.parent,'Tag','TimerFcn');
            h.Value = s;
            obj.TimerFcn = s;
        end
        
        function set.StopFcn(obj,s)
            h = findobj(obj.parent,'Tag','StopFcn');
            h.Value = s;
            obj.StopFcn = s;
        end
        
        function set.ErrorFcn(obj,s)
            h = findobj(obj.parent,'Tag','ErrorFcn');
            h.Value = s;
            obj.ErrorFcn = s;
        end
    end

    methods (Static)
        function r = check_function(e)
            r = e.Value;
            if exist(e.Value,'file') == 2
                e.Source.BackgroundColor = [1 1 1];
                e.Source.FontColor = [0 0 0];
            else
                e.Source.BackgroundColor = [1 0.4 0.4];
                e.Source.FontColor = [1 1 1];
                msg = sprintf('The function "%s" was not found on Matlab''s path.',e.Value);
                uialert(ancestor(e.Source,'figure'),msg,'Invalid Entry','icon','warning');
            end
        end
    end
end