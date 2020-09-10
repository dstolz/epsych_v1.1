classdef Config < handle
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

        function obj = Config(parent,type)
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
            global RUNTIME
            hObj.Value = epsych.Tool.check_function(event);
            obj.Config.(hObj.Tag) = str2func(hObj.Value);
            log_write('Verbose','Updated value of "%s" to %s',hObj.Tag,hObj.Value)

            RUNTIME.Config = copy(obj.Config);
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
            obj.Config.(hObj.Tag) = event.Value;

            RUNTIME.Config = copy(obj.Config);

            log_write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %s',hObj.Tag,event.Value)
        end

        function update_checkbox(obj,hObj,event)
            global RUNTIME
            obj.Config.(hObj.Tag) = event.Value;
            log_write(epsych.log.Verbosity.Verbose,'Updated value of "%s" to %d',hObj.Tag,event.Value)

            % one-off
            if isequal(hObj.Tag,'AutoLoadRuntimeConfig')
                setpref('epsych_Config','AutoLoadRuntimeConfig',event.Value)
            end

            RUNTIME.Config = copy(obj.Config);
        end

        function locate_file(obj,hObj,event,ext)
            global RUNTIME
            
            pn = getpref('epsych_ConfigSetup','locateFilePath',epsych.Info.user_directory);
            
            [fn,pn] = uigetfile(ext,'Locate file',pn);
            
            if isequal(fn,0), return; end
                        
            w = which(fn);
            
            setpref('epsych_ConfigSetup','locateFilePath',pn);
            
            if isempty(w)
                str = sprintf('File not found on Matlab''s path: "%s"',fn);
                uialert(ancestor(hObj,'figure'),str,'obj.Tag');
                return
            end
            
            fn = fn(1:end-2);
            
            RUNTIME.Config.(hObj.Tag) = str2func(fn);
            
            peer = findobj(hObj.Parent,'Tag',hObj.Tag,'-and','Type','uieditfield');
            peer.Value = fn;
            peer.Tooltip = pn;
            
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
        
    end % methods (Static)
end