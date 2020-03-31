classdef CustomizationSetup < handle
    % User-settable functions, directories, and options
    
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
            global RUNTIME
            v = RUNTIME.Config.(hObj.Tag);
            if isa(v,'function_handle')
                hObj.Value = func2str(v);
            else
                hObj.Value = v;
            end
            
        end
        
        function update_function(obj,hObj,event)
            global RUNTIME
            hObj.Value = obj.check_function(event);
            RUNTIME.Config.(hObj.Tag) = str2func(hObj.Value);
            RUNTIME.Log.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %s',hObj.Tag,hObj.Value)
        end

        function update_directory(obj,hObj,event)
            global RUNTIME
            if ~isfolder(event.Value)
                sel = uiconfirm(ancestor(obj.parent,'figure'), ...
                    sprintf('Directory does not exist: "%s"\n\nWould you like to create it?',event.Value), ...
                    'Invalid Directory', ...
                    'Options',{'Create','Cancel'}, ...
                    'DefaultOption','Create','CancelOption','Cancel');
                if isequal(sel,'Cancel')
                    hObj.Value = event.PreviousValue;
                    return; 
                end
                mkdir(event.Value);
                
            end
            RUNTIME.Config.(hObj.Tag) = event.Value;
            RUNTIME.Log.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %s',hObj.Tag,event.Value)
        end

        function update_checkbox(obj,hObj,event)
            global RUNTIME
            RUNTIME.Config.(hObj.Tag) = event.Value;
            RUNTIME.Log.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %d',hObj.Tag,event.Value)

            % one-off
            if isequal(hObj.Tag,'AutoLoadRuntimeConfig')
                setpref('epsych_Config','AutoLoadRuntimeConfig',event.Value)
            end
        end

        function locate_directory(obj,hObj,event)
            global RUNTIME

            d = uigetdir(RUNTIME.Config.(hObj.Tag),'Choose a Directory');
            if isequal(d,0), return; end
            RUNTIME.Config.(hObj.Tag) = d;
            h = findall(0,'Tag',hObj.Tag,'-and','Type','uieditfield');
            h.Value = d;

            if isequal(hObj.Tag,'LogDirectory')
                epsych.Tool.restart_required(obj.parent);
            end
        end
    end % methods

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
    end % methods (Static)
end