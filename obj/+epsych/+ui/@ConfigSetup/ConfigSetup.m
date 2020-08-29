classdef ConfigSetup < handle
    % User-settable functions, directories, and options
    
    properties
        Config  epsych.expt.Config = epsych.expt.Config;
    end

    properties (SetAccess = immutable)
        parent
        type
    end

    methods
        create(obj,parent,type);

        function obj = ConfigSetup(parent,type)
            narginchk(2,2)
            
            obj.create(parent,type);
            obj.parent = parent;
            obj.type = type;
        end

        function set.Config(obj,C)
            % TODO: Update fields based on new Config
            m = metaclass(C);
            ind = ismember({m.PropertyList.SetAccess},'public');
            p = {m.PropertyList(ind).Name};
            for i = 1:length(p)
                h = findobj(obj.parent,'Tag',p{i},'-and','type','uieditfield');
                if isempty(h)
                    h = findobj(obj.parent,'Tag',p{i},'-and','type','uicheckbox');
                end
                if isempty(h), continue; end
                if isa(C.(p{i}),'function_handle')
                    h.Value = func2str(C.(p{i}));
                else
                    h.Value = C.(p{i});
                end
            end
        end

        function create_field(obj,hObj,event)
            v = obj.Config.(hObj.Tag);
            if isa(v,'function_handle')
                hObj.Value = func2str(v);
            else
                hObj.Value = v;
            end
        end
        
        function update_function(obj,hObj,event)
            global RUNTIME LOG
            hObj.Value = obj.check_function(event);
            obj.Config.(hObj.Tag) = str2func(hObj.Value);
            LOG.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %s',hObj.Tag,hObj.Value)

            RUNTIME.Config = copy(obj.Config);
        end

        function update_directory(obj,hObj,event)
            global RUNTIME LOG
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
            obj.Config.(hObj.Tag) = event.Value;

            RUNTIME.Config = copy(obj.Config);

            LOG.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %s',hObj.Tag,event.Value)
        end

        function update_checkbox(obj,hObj,event)
            global RUNTIME LOG
            obj.Config.(hObj.Tag) = event.Value;
            LOG.write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %d',hObj.Tag,event.Value)

            % one-off
            if isequal(hObj.Tag,'AutoLoadRuntimeConfig')
                setpref('epsych_Config','AutoLoadRuntimeConfig',event.Value)
            end

            RUNTIME.Config = copy(obj.Config);
        end

        function locate_directory(obj,hObj,event)
            global RUNTIME
            d = uigetdir(obj.Config.(hObj.Tag),'Choose a Directory');
            if isequal(d,0), return; end
            obj.Config.(hObj.Tag) = d;
            h = findall(0,'Tag',hObj.Tag,'-and','Type','uieditfield');
            h.Value = d;

            if isequal(hObj.Tag,'LogDirectory')
                epsych.Tool.restart_required(obj.parent);
            end

            RUNTIME.Config = copy(obj.Config);
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