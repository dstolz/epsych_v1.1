classdef Hardware < handle

    
    properties
        HardwareObj    % epsych.hw.(Abstraction)
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
        
        function obj = Hardware(parent,HardwareObj)
            global RUNTIME
            
            if nargin < 2, HardwareObj = []; end
            
            obj.parent = parent;
            obj.create(parent);
            
            if isempty(HardwareObj)
                obj.add;
            else
                obj.HardwareObj = HardwareObj;
            end
            
            if isempty(obj.HardwareObj)
                return
            end
            
            obj.update(obj.HardwareObj);
            
            obj.HardwareObj.setup(obj.HardwarePanel);
                        
            h = findobj(parent,'tag','hardwareAlias');
            
            % suggest unique aliases % TODO: enforce unique aliases
            ua = cellfun(@(a) a.Alias,RUNTIME.Hardware,'uni',0);
            ua = matlab.lang.makeUniqueStrings(ua);
            RUNTIME.Hardware{end}.Alias = ua{end};
            obj.HardwareObj = RUNTIME.Hardware{end};
            h.Value = ua{end};
        end


        function update(obj,hObj)
            global RUNTIME
            
            if nargin < 2, hObj = []; end

            if isempty(RUNTIME.Hardware)
                RUNTIME.Hardware = {obj.HardwareObj};                
            elseif isempty(hObj)
                RUNTIME.Hardware{end+1} = obj.HardwareObj;
            else
                ind = cellfun(@(a) isequal(a.Alias,hObj.Alias),RUNTIME.Hardware);
                if ~any(ind), ind = numel(RUNTIME.Hardware)+1; end
                RUNTIME.Hardware{ind} = obj.HardwareObj;
            end
            
            ev = epsych.evHardwareUpdated(obj,obj.HardwareObj);
            notify(obj,'HardwareUpdated',ev);
        end


        function add(obj,hObj,event)
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
            
            hw = obj.HardwareObj;
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
            
            obj.HardwareObj = epsych.hw.(hwlist{sel})(obj);
            
            obj.update;
        end

        
        
    end % methods (Access = public)

    methods (Access = private)
        function alias_changed(obj,hObj,evnt)
            obj.HardwareObj.Alias = hObj.Value;
            ev = epsych.evHardwareUpdated(obj,obj.HardwareObj);
            notify(obj,'HardwareUpdated',ev);
        end
    end % methods (Access = private)

end



