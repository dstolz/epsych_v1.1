classdef HardwareSetup < handle

    properties (Access = protected)
        TabGroup                matlab.ui.container.TabGroup
        
        AddHardwareButton       matlab.ui.control.Button
        RemoveHardwareButton    matlab.ui.control.Button
    end
    
    properties
        Hardware
    end
    

    
    properties (SetAccess = immutable)
        parent
    end


    methods
        create(obj,parent);
        
        function obj = HardwareSetup(parent)
            obj.create(parent);
            obj.parent = parent;
        end


        function update_hardware(obj)
            global RUNTIME

%             RUNTIME.Hardware = copy(obj.Hardware);
            RUNTIME.Hardware = obj.Hardware;
        end


        function add_hardware_callback(obj,hObj,event)
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

            ots = epsych.Tool.figure_state(hObj,false);

            [sel,ok] = listdlg( ...
                'Name','Add Hardware', ...
                'PromptString','Select Hardware', ...
                'SelectionMode','single', ...
                'ListString',hwlist);
                
            epsych.Tool.figure_state(hObj,ots);

            if ~ok, return; end
            
            obj.add_hardware_tab(hwlist(sel));
            
            obj.update_hardware;


%             setpref('interface_HardwareSetup','dfltHardware',hw);
        end

        
        function add_hardware_tab(obj,hw)
            ht = uitab(obj.TabGroup,'Scrollable','on');

            if iscell(hw), hw = hw{1}; end
            
            if ischar(hw)
                hw = epsych.hw.(hw);
            end
            
            ht.UserData = hw;
            
            hw.setup(ht);
            
            n = sum(ismember(cellfun(@class,obj.Hardware,'uni',0),class(hw)));
            ht.Title = sprintf('%s [%d]',hw.Name,n);

            obj.TabGroup.SelectedTab = ht;    
        end
        
        function set.Hardware(obj,hw)
            assert(iscell(hw),'epsych.ui.HardwareSetup','Hardware must be a cell array');
            
            delete(obj.TabGroup.Children);
            
            for i = 1:length(hw)
                obj.add_hardware_tab(hw{i});
            end
        end
        
        function hw = get.Hardware(obj)
            ch = obj.TabGroup.Children;
            if isempty(ch)
                hw = {};
            else
                hw = {ch.UserData};
            end
        end
        
        function remove_hardware_callback(obj,hObj,event)
            delete(obj.TabGroup.SelectedTab);
            obj.update_hardware;
        end
    end

end