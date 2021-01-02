classdef TankRegister < handle
    
    properties (SetObservable = true)
        localTankPath
        showRegTankPaths    = false;
        showNotRegTankPaths = false;
    end
    
    properties (SetAccess = protected)
        localTanksFFN
    end
    
    properties (Access = private)
        TT      % TTank.X
        TDTfig
        
        guiFig
        guiListRegistered
        guiListNotRegistered
    end
    
    properties (Dependent)
        TanksSelected
    end
    
    
    
    
    
    methods
        
        function obj = TankRegister(localTankPath)
            if nargin < 1 || isempty(localTankPath)
                pth = ['C:\Users\' getenv('username')];
                localTankPath = getpref('TankRegister','localTankPath',pth);
            end
            obj.localTankPath = localTankPath;

%             obj.setup_tt;
            
            obj.create_gui;
        end
        
        function delete(obj)
            obj.TT.ReleaseServer;
            delete(obj.TT);
            delete(obj.TDTfig);
            close(obj.guiFig);
        end
        
        function refresh_registered_tanks(obj)
            tanks = obj.get_registered_tanks;
            if ~obj.showRegTankPaths
                for i = 1:numel(tanks)
                    [~,tanks{i},~] = fileparts(tanks{i});
                end
            end
            v = get(obj.guiListRegistered,'Value');
            v(v>numel(tanks)) = [];
            if isempty(v), v = 1; end
            set(obj.guiListRegistered,'Value',v,'String',tanks);
        end
        
        function refresh_not_registered_tanks(obj)
            tanks = obj.get_local_tanks(obj.localTankPath);
            
            rtanks = obj.get_registered_tanks;
            ind = ismember(tanks,rtanks);
            tanks(ind) = [];
            
            obj.localTanksFFN = tanks;
            
            if ~obj.showNotRegTankPaths
                for i = 1:numel(tanks)
                    [~,tanks{i},~] = fileparts(tanks{i});
                end
            end
            
            v = get(obj.guiListNotRegistered,'Value');
            v(v>numel(tanks)) = [];
            if isempty(v), v = 1; end
            set(obj.guiListNotRegistered,'Value',v,'String',tanks);
        end
        
        
        function set.localTankPath(obj,pth)
            assert(ischar(pth),'TankRegister:localTankPath:MustBeChar', ...
                'localTankPath must be a char string');
            obj.localTankPath = pth;
            setpref('TankRegister','localTankPath',obj.localTankPath);
            obj.refresh_not_registered_tanks;
        end
        
    end % methods (Access = public)
    
    
    
    
    
    
    
    
    methods (Access = private)
        
        
%         function setup_tt(obj)
%             obj.TDTfig = figure('Visible','off','Name','TTankFig');
%             obj.TT = actxcontrol('TTank.X','parent',obj.TDTfig);
%             obj.TT.ConnectServer('Local','Me');
%         end
        
        function create_gui(obj)
            obj.guiFig = figure('Position',[1 1 800 450]);
            set(obj.guiFig,'Name','Tank Register','NumberTitle','off', ...
                'MenuBar','none','units','normalized');
            movegui(obj.guiFig,'center');
            

            
            % not registered
            hp = uipanel(obj.guiFig,'Position',[0.01 0.01 0.4 0.98], ...
                'BackgroundColor',get(obj.guiFig,'Color'), ...
                'BorderType','none','units','normalized');
            
            h = uicontrol(hp,'style','pushbutton',...
                'units','normalized','Position',[0.01 0.92 0.35 0.07], ...
                'string','Select Dir','Tooltip','Select tank directory', ...
                'FontSize',12,'FontWeight','Bold', ...
                'Callback',@obj.gui_select_dir);
            
            h = uicontrol(hp,'style','pushbutton',...
                'units','normalized','Position',[0.7 0.92 0.29 0.07], ...
                'string','Sort','Tooltip','Sort not registered tanks by name', ...
                'FontSize',12,'FontWeight','Bold', ...
                'Callback',@obj.gui_sort_not_registered);
            
            h = uicontrol(hp,'style','listbox', ...
                'units','normalized','Position',[0.01 0.01 0.98 0.9], ...
                'FontName','Consolas','FontSize',14, ...
                'BackgroundColor','w','Max',1000);
            obj.guiListNotRegistered = h;
            
            
            % registered
            hp = uipanel(obj.guiFig,'Position',[0.59 0.01 0.4 0.98], ...
                'BackgroundColor',get(obj.guiFig,'Color'), ...
                'BorderType','none','units','normalized');
            
            h = uicontrol(hp,'style','pushbutton',...
                'units','normalized','Position',[0.7 0.92 0.29 0.07], ...
                'string','Sort','Tooltip','Sort registered tanks by name', ...
                'FontSize',12,'FontWeight','Bold', ...
                'Callback',@obj.gui_sort_registered);
            
            h = uicontrol(hp,'style','listbox', ...
                'FontName','Consolas','FontSize',14, ...
                'units','normalized','Position',[0.01 0.01 0.98 0.9], ...
                'BackgroundColor','w','Max',1000);
            obj.guiListRegistered = h;
            
            
            % center
            hp = uipanel(obj.guiFig,'Position',[0.42 0.01 0.16 0.9], ...
                'BackgroundColor',get(obj.guiFig,'Color'), ...
                'BorderType','none','units','normalized');
            
            h = uicontrol(hp,'style','pushbutton', ...
                'units','normalized','Position',[0.01 0.55 0.98 0.1], ...
                'string','> Register >','Tooltip','Register Tank', ...
                'FontSize',12,'FontWeight','Bold', ...
                'Callback',@obj.gui_register_tanks);
            
            
            h = uicontrol(hp,'style','pushbutton', ...
                'units','normalized','Position',[0.01 0.4 0.98 0.1], ...
                'string','< Unregister <','Tooltip','Unregister Tank', ...
                'FontSize',12,'FontWeight','Bold', ...
                'Callback',@obj.gui_unregister_tanks);
            
            obj.refresh_not_registered_tanks;
            obj.refresh_registered_tanks;
        end
        
        function gui_register_tanks(obj,~,~)
            v = get(obj.guiListNotRegistered,'Value');
            if isempty(v), return; end
            
            t = obj.localTanksFFN;
            t = t(v);
            
            obj.add_tank_to_registry(t);
            
            obj.refresh_not_registered_tanks;
            obj.refresh_registered_tanks;
        end
        
        function gui_unregister_tanks(obj,~,~)
            v = get(obj.guiListRegistered,'Value');
            if isempty(v), return; end
            
            t = obj.get_registered_tanks;
            t = t(v);
            
            obj.rem_tank_from_registry(t);
            
            obj.refresh_not_registered_tanks;
            obj.refresh_registered_tanks;
        end
        
        function gui_select_dir(obj,~,~)
            pn = uigetdir(obj.localTankPath,'Tank Path');
            
            if isequal(pn,0), return; end
            
            obj.localTankPath = pn;
            
        end
        
        
        function gui_sort_registered(obj,~,~)
            t = get(obj.guiListRegistered,'String');
            if issorted(t)
                t = flipud(sort(t));
            else
                t = sort(t);
            end
            set(obj.guiListRegistered,'String',t,'Value',1);
        end
        
        function gui_sort_not_registered(obj,~,~)
            t = get(obj.guiListNotRegistered,'String');
            if issorted(t)
                t = flipud(sort(t));
                obj.localTanksFFN = flipud(sort(obj.localTanksFFN));
            else
                t = sort(t);
                obj.localTanksFFN = sort(obj.localTanksFFN);
            end
            set(obj.guiListNotRegistered,'String',t,'Value',1);
        end
    end % methods (Access = private)
    
    
    
    
    
    
    
    
    
    
    methods (Static)
        
        
        function ffn = tank_registry_file
            ffn = ['C:\Users\' getenv('username') '\AppData\Local\TDT\EnumTanks.txt'];
        end
        
        function add_tank_to_registry(tanks)
            tanks = cellstr(tanks);
            
            ind = cellfun(@isempty,tanks);
            tanks(ind) = [];
            
            % check for duplicates
            rt = TankRegister.get_registered_tanks;
            tanks = union(rt,tanks);
            
            tanks = sort(tanks);
            
            fid = fopen(TankRegister.tank_registry_file,'w');
            for i = 1:numel(tanks)
                fprintf(fid,'%s\n',tanks{i});
            end
            fclose(fid);
        end
        
        function rem_tank_from_registry(tankPath)
            tankPath = cellstr(tankPath);
            tanks = TankRegister.get_registered_tanks;
            ind = ismember(tanks,tankPath);
            tanks(ind) = [];
            
            fid = fopen(TankRegister.tank_registry_file,'w');
            for i = 1:numel(tanks)
                fprintf(fid,'%s\n',tanks{i});
            end
            fclose(fid);
        end
        
        function tanks = get_registered_tanks
            % read registered from common text file
            fid = fopen(TankRegister.tank_registry_file,'r');
            assert(fid > 0,'TankRegister:get_registered_tanks:TankRegNotFound', ...
                'Unable to locate TDT tank registry!');
            tanks = {};
            while ~feof(fid)
                tanks{end+1} = fgetl(fid);
            end
            fclose(fid);
            tanks = tanks(:);
        end
        
        function tn = get_local_tanks(localDir)
            if nargin < 1 || isempty(localDir)
                localDir = getpref('TankRegister','localDir',cd);
            end
            d = dir(fullfile(localDir));
            
            d(~[d.isdir]) = [];
            
            tn = {d.name};
            tn(ismember(tn,{'.','..'})) = [];
            
            tn = cellfun(@(a) fullfile(localDir,a),tn,'uni',0);
            tn = tn(:);
            
            c = false(size(tn));
            for i = 1:length(tn)
                td = dir(tn{i});
                
                if isempty(td), continue; end
                
                c(i) = TankRegister.number_of_blocks({td.name}) > 0;
            end
            tn(~c) = [];
        end
        
        function n = number_of_blocks(tankPath)
            tankPath = cellstr(tankPath);
            x = cellfun(@(a) length(a)>6 && isequal(a(1:6),'Block-'),tankPath);
            n = sum(x);
        end
    end % methods (Static)
end
