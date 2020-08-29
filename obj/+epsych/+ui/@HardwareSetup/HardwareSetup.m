classdef HardwareSetup < handle

    
    properties
        Hardware    % epsych.hw.(Abstraction)
    end
    
    properties (SetAccess = private)
        HardwarePanel   matlab.ui.container.Panel
    end
    
    properties (SetAccess = immutable)
        parent
    end

    events
        HardwareUpdated
    end

    methods
        create(obj,parent);
        
        function obj = HardwareSetup(parent)
            obj.parent = parent;
            obj.create(parent);
            obj.add_hardware;
            
            if isempty(obj.Hardware)
                return
            end
            
            h = findobj(parent,'tag','hardwareAlias');
            h.Value = obj.Hardware.Alias;
        end


        function update_hardware(obj)
            global RUNTIME

            if isempty(RUNTIME.Hardware)
                RUNTIME.Hardware = {obj.Hardware};
            else
                ind = cellfun(@(a) isequal(a.Name,obj.Hardware.Name),RUNTIME.Hardware);
                if ~any(ind), ind = length(ind)+1; end
                RUNTIME.Hardware{ind} = obj.Hardware;
            end
            
            ev = epsych.evHardwareUpdated(obj,obj.Hardware);
            notify(obj,'HardwareUpdated',ev);
        end


        function add_hardware(obj,hObj,event)
            hwlist = epsych.hw.Hardware.available;
            hw = obj.Hardware;
            if ~isempty(hw)
                hwlist = setdiff(hwlist,cellfun(@(a) a.Name,hw,'uni',0));
            end
            
            if isempty(hwlist)
                uialert(obj.parent, ...
                    'Unable to add more Hardware.', ...
                    'Add Hardware','Icon','warning');
                return
            end

            ots = epsych.Tool.figure_state(obj.parent,false);

            [sel,ok] = listdlg( ...
                'Name','Add Hardware', ...
                'PromptString','Select Hardware', ...
                'SelectionMode','single', ...
                'ListString',hwlist);
                
            epsych.Tool.figure_state(obj.parent,ots);

            figure(ancestor(obj.parent,'figure'));

            if ~ok, return; end
            
            obj.Hardware = epsych.hw.(hwlist{sel});
            obj.Hardware.setup(obj.HardwarePanel);
            
            
            obj.update_hardware;

        end

        
        
    end % methods (Access = public)

    methods (Access = private)
        function alias_changed(obj,hObj,evnt)
            obj.Hardware.Alias = hObj.Value;
            obj.update_hardware;
        end
    end % methods (Access = private)

end



