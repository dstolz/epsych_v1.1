classdef FigOnTop < handle

    properties
        State       (1,1) logical = false;

        usePref     (1,1) logical = false;
        prefGroup   (1,:) char
        prefVar     (1,:) char = 'AlwaysOnTop';
    end

    properties (SetAccess = private)
        parent  % matlab.ui.container....
        handle  % matlab.ui.control.Checkbox
    end

    methods
        % Constructor
        function obj = FigOnTop(parent,state,prefGroup,prefVar)
            narginchk(0,4)

            if nargin == 0 || isempty(parent), return; end

            obj.create(parent);

            if nargin == 2 || isempty(state), state = 0; end
            
            if nargin == 4 && ~isempty(prefVar)
                obj.prefVar = prefVar;
            end

            if nargin >= 3 && ~isempty(prefGroup)
                obj.prefGroup = prefGroup;
                obj.usePref = true;
                state = getpref(obj.prefGroup,obj.prefVar,state);
                obj.handle.Value = state;
                drawnow
            end
            
            obj.State = state;
        end

        function create(obj,parent)
            h = uicheckbox(parent);
            h.Text = 'Always on Top';
            h.Tag = 'AlwaysOnTopObj';
            h.ValueChangedFcn = @obj.update;

            obj.handle = h;
            obj.parent = parent;
        end

        function set.State(obj,state)
            epsych.Tool.figure_state(obj.parent,state);
            if obj.usePref
                setpref(obj.prefGroup,obj.prefVar,state);
            end
        end

        function s = get.State(obj)
            s = epsych.Tool.figure_state(obj.parent);
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
        
    end

end