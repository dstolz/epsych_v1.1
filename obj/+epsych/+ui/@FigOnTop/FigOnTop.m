classdef FigOnTop < handle

    properties
        State       (1,1) logical = false;

        usePref     (1,1) logical = false;
        prefGroup   (1,:) char
        prefVar     (1,:) char = 'AlwaysOnTop';
    end

    properties (SetAccess = immutable)
        parent  % matlab.ui.container....
        handle  % matlab.ui.control.Checkbox
    end

    methods
        % Constructor
        function obj = FigOnTop(parent,state,prefGroup,prefVar)
            narginchk(1,3)

            obj.parent = parent;
            obj.handle = obj.create;

            if nargin < 2, state = 0; end
            
            if nargin == 4 && ~isempty(prefVar)
                obj.prefVar = prefVar;
            end

            if nargin >= 3 && ~isempty(prefGroup)
                obj.prefGroup = prefGroup;
                obj.usePref = true;
                state = getpref(obj.prefGroup,obj.prefVar,state);
                obj.handle.Value = state;
            end
            
            obj.State = state;
        end

        function h = create(obj)
            h = uicheckbox(obj.parent);
            h.Text = 'Always on Top';
            h.Tag = 'AlwaysOnTopObj';
            h.ValueChangedFcn = @obj.update;
        end

        function set.State(obj,state)
            obj.fig_on_top(obj.parent,state);
            if obj.usePref
                setpref(obj.prefGroup,obj.prefVar,state);
            end
        end

        function s = get.State(obj)
            s = obj.fig_on_top(obj.parent);
        end

        function set.usePref(obj,tf)
            if tf && isempty(obj.prefGroup)
                error('epsych:FigOnTop:usePref:MustSetPrefGroup', ...
                    'Must set the prefGroup before setting usePref = true');
            end
            obj.usePref = tf; 
        end

        function update(obj,hObj,event)
            obj.State = event.Value;
        end
    end

    methods (Static)
        function prevState = fig_on_top(h,state)
            narginchk(1,2);

            drawnow expose

            figh = ancestor(h,'figure');

            if nargin < 2, state = []; end % return state without setting it

            try %#ok<TRYNC>
                warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                
                if isa(figh,'matlab.ui.Figure')
                    warning('off','MATLAB:structOnObject');
                    f = struct(figh);
                    c = struct(f.Controller);
                    p = struct(c.PlatformHost);
                    prevState = p.CEF.isAlwaysOnTop;
                    if isempty(prevState), prevState = false; end
                    if ~isempty(state)
                        p.CEF.setAlwaysOnTop(state);
                    end
                    warning('on','MATLAB:structOnObject');

                elseif verLessThan('matlab','8.1')
                    J = get(figh,'JavaFrame');
                    prevState = J.fHG1Client.getWindow.isAlwaysOnTop;
                    if ~isempty(state)
                        J.fHG1Client.getWindow.setAlwaysOnTop(state);
                    end
                else
                    J = get(figh,'JavaFrame');
                    prevState = J.fHG2Client.getWindow.isAlwaysOnTop;
                    if ~isempty(state)
                        J.fHG2Client.getWindow.setAlwaysOnTop(state);
                    end
                end
                warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            
            end

        end
    end

end