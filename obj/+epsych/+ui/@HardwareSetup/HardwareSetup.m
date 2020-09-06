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
        
        function obj = HardwareSetup(parent,Hardware)
            global RUNTIME
            
            if nargin < 2, Hardware = []; end
            
            obj.parent = parent;
            obj.create(parent);
            
            if isempty(Hardware)
                obj.add_hardware;
            else
                obj.Hardware = Hardware;
            end
            
            if isempty(obj.Hardware)
                return
            end
            
            obj.update_hardware;
            
            obj.Hardware.setup(obj.HardwarePanel);
                        
            h = findobj(parent,'tag','hardwareAlias');
            
            % suggest unique aliases % TODO: enforce unique aliases
            ua = cellfun(@(a) a.Alias,RUNTIME.Hardware,'uni',0);
            ua = matlab.lang.makeUniqueStrings(ua);
            RUNTIME.Hardware{end}.Alias = ua{end};
            obj.Hardware = RUNTIME.Hardware{end};
            h.Value = ua{end};
        end


        function update_hardware(obj,hObj)
            global RUNTIME
            
            if nargin < 2, hObj = []; end

            if isempty(RUNTIME.Hardware)
                RUNTIME.Hardware = {obj.Hardware};                
            else
                ind = cellfun(@(a) isequal(a,hObj),RUNTIME.Hardware);
                if ~any(ind), ind = numel(RUNTIME.Hardware)+1; end
                RUNTIME.Hardware{ind} = obj.Hardware;
            end
            
            ev = epsych.evHardwareUpdated(obj,obj.Hardware);
            notify(obj,'HardwareUpdated',ev);
        end


        function add_hardware(obj,hObj,event)
            global RUNTIME
            
            hwlist = epsych.hw.Hardware.available;
            
            if ~isempty(RUNTIME.Hardware)
                rhn = cellfun(@(a) a.Name,RUNTIME.Hardware,'uni',0);
                mni = cellfun(@(a) a.MaxNumInstances,RUNTIME.Hardware);
                
                u = unique(rhn);
                cni = cellfun(@(a) sum(strcmp(a,rhn)),u);
                ind = arrayfun(@(a) any(a == cni),mni);
                hwlist(ismember(hwlist,rhn(ind))) = [];
            end
            
            if isempty(hwlist)
                uialert(ancestor(obj.parent,'figure'), ...
                    'No more hardware is available.', ...
                    'EPsych');
                return
            end
            
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
            
            obj.Hardware = epsych.hw.(hwlist{sel})(obj);
            
        end

        
        
    end % methods (Access = public)

    methods (Access = private)
        function alias_changed(obj,hObj,evnt)
            obj.Hardware.Alias = hObj.Value;
            obj.update_hardware;
        end
    end % methods (Access = private)

end



