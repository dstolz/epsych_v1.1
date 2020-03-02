classdef BitmaskGen < handle
    
    properties
        filename (1,:) char
    end
    
    properties (Access = protected)
        VarTable
        DataTable
        ExptTypeDropdown
        CopyButton
        DataTableTitle
        
        bmIdx
    end
    
    properties (Dependent)
        CurrentBitmask
    end
    
    properties (SetAccess = immutable)
        parent % uifigure
    end
    
    
    methods
        function obj = BitmaskGen(varargin)
            
            for i = 1:length(varargin)
                switch class(varargin{i})
                    case {'char','string'}
                        obj.filename = varargin{i};
                    case 'matlab.ui.Figure'
                        obj.parent = varargin{i};
                end
            end
            
            
            if isempty(obj.parent)
                obj.parent = uifigure( ...
                    'Name','Bitmask Generator', ...
                    'NumberTitle', 'off', ...
                    'Position',[400 250 720 360]);
            end
            
            obj.create_gui;
            
            if ~isempty(obj.filename)
                obj.load(obj.filename);
            end
        end
        
        function load(obj,src,~)
            if ~isa(src,'char') && ~isa(src,'string')
                pn = getpref('epsych_BitmaskGen','projectDir',cd);
                [fn,pn] = uigetfile( ...
                    {'*.ebm','EPsych Bitmask File (*.ebm)'}, ...
                    'Load Bitmask',pn);
                if isequal(fn,0), figure(obj.parent); return; end
                obj.filename = fullfile(pn,fn);
            end
            fprintf('Loading Bitmask Data "%s" ...',obj.filename)
            load(obj.filename,'data','vars','opts','-mat');
            obj.DataTable.Data = data;
            obj.VarTable.Data  = vars;
            obj.ExptTypeDropdown.Value = opts.ExptType;
            fprintf(' done\n')
            
            setpref('epsych_BitmaskGen','projectDir',pn);
            
            figure(obj.parent);
        end
        
        function save(obj,~,~)
            pn = getpref('epsych_BitmaskGen','projectDir',cd);
            [fn,pn] = uiputfile({'*.ebm','EPsych Bitmask File (*.ebm)'}, ...
                'Save Bitmask',pn);
            if isequal(fn,0), figure(obj.parent); return; end
            obj.filename = fullfile(pn,fn);
            
            data = obj.DataTable.Data;
            vars = obj.VarTable.Data;
            vars(:,2) = num2cell(false(size(vars,1),1));
            opts = struct('ExptType',obj.ExptTypeDropdown.Value);
            
            fprintf('Saving Bitmask Data "%s" ...',obj.filename)
            save(obj.filename,'data','vars','opts','-mat');
            fprintf(' done\n')
            
            setpref('epsych_BitmaskGen','projectDir',pn);
            
            figure(obj.parent);
        end
        
        
        function m = get.CurrentBitmask(obj)
            if isempty(obj.bmIdx)
                m = nan;
            else
                m = obj.DataTable.Data{obj.bmIdx(1),obj.bmIdx(2)};
            end
        end
        
    end
    
    methods (Access = private)
        function create_gui(obj)
            
            g = uigridlayout(obj.parent);
            g.ColumnWidth = {'0.5x','0.5x',50,'1.25x'};
            g.RowHeight   = {25,25,'1x'};
            
            
            
            % Variable Table
            exptVars = arrayfun(@char,enumeration('epsych.Bitmask'),'uni',0);
            exptVars = [{'< REMOVE >'}; exptVars];
            hV = uitable(g);
            hV.Layout.Column  = [1 2];
            hV.Layout.Row     = [2 3];
            hV.RowName        = [];
            hV.ColumnName     = {'Variable','State'};
            hV.ColumnWidth    = {'auto',40};
            hV.ColumnEditable = [true true];
            D = cell(15,2);
            D(:,2) = {false};
            hV.Data = D;
            hV.ColumnFormat   = {exptVars','logical'};
            hV.CellEditCallback = @obj.variable_updated;

            % Load button
            hS = uibutton(g);
            hS.Layout.Column = 1;
            hS.Layout.Row    = 1;
            hS.Text          = 'Load';
            hS.ButtonPushedFcn = @obj.load;
            
            % Save button
            hS = uibutton(g);
            hS.Layout.Column = 2;
            hS.Layout.Row    = 1;
            hS.Text          = 'Save';
            hS.ButtonPushedFcn = @obj.save;
            
            % Copy button
            hC = uibutton(g);
            hC.Layout.Column = 5;
            hC.Layout.Row    = 1;
            hC.Text          = 'Copy Table';
            hC.ButtonPushedFcn = @obj.copy_datatable;
            
            
            % Expt Dropdown
            hE = uidropdown(g);
            hE.Layout.Column = 4;
            hE.Layout.Row    = 1;
            hE.ValueChangedFcn = @obj.expt_changed;
            
            % Data Table Label
            hL = uilabel(g);
            hL.Layout.Column = [3 5];
            hL.Layout.Row    = 2;
            hL.Text          = 'RPvds State Machine Data Table';
            hL.HorizontalAlignment = 'center';
            hL.FontSize      = 16;
            hL.FontWeight    = 'bold';
            
            % Data Table
            hD = uitable(g);
            hD.Layout.Column  = [3 5];
            hD.Layout.Row     = 3;
            hD.ColumnName     = {'S0','S1','S2','S3','S4'};
            hD.ColumnEditable = true;
            hD.ColumnFormat   = {'numeric','numeric','numeric','numeric','numeric'};
            hD.ColumnWidth    = num2cell(80.*ones(1,5));
            hD.RowName        = {'If None','If JmpA','If JmpB','If Both','Output-0','Output-1','Output-2','Output-3'};
            hD.FontSize       = 16;
            hD.CellSelectionCallback = @obj.select_data;
            hD.CellEditCallback      = @obj.edit_data;
            hD.BackgroundColor = [ones(4,1)*[1 1 0.5]; ones(4,3)];

            obj.CopyButton = hC;
            obj.ExptTypeDropdown = hE;
            obj.VarTable  = hV;
            obj.DataTable = hD;
            obj.DataTableTitle = hL;
            
            obj.DataTable.Data = num2cell(zeros(8,5,'uint32'));
            
            obj.load_expts;
        end
        
        function variable_updated(obj,src,event)                        
            r = event.Indices;
            
            if r(1) == size(src.Data,1)
                src.Data(end+1,:) = {'',false};
            end
            
            v = src.Data{r(1),1};
            if isempty(v)
                src.Data{r(1),2} = false;
                return
                
            elseif isequal(v,'< REMOVE >')
                src.Data(r(1),:) = [];
            end
            
            if isempty(obj.bmIdx), return; end

            d = src.Data;
            
            d(cellfun(@isempty,d(:,1)),:) = [];
            n = [d{:,2}];
            m = cellfun(@epsych.Bitmask,d(:,1));
            m(~n) = [];
            k(m) = true;
            
            obj.DataTable.Data{obj.bmIdx(1),obj.bmIdx(2)} = epsych.BitmaskGen.encode(k);
            
        end
        
        function select_data(obj,src,event)
            if event.Indices(1) <= 4 || event.Indices(2) == 1
                obj.bmIdx = [];
            else
                obj.bmIdx = event.Indices(end,:);
                obj.update_variable_table;
            end
        end
        
        function edit_data(obj,src,event)
            x = event.Indices(end,:);
            d = event.NewData;
            
            if x(1) <= 4
                if d > 4
                    uialert(obj.parent,'Values must be less than or equal to the number of states (<=4)','Invalid Value','Icon','info')
                    src.Data{x(1),x(2)} = event.PreviousData;
                end
            
            elseif x(2) == 1
                uialert(obj.parent,'State 0 (S0) must always be zero.','Invalid Value','Icon','info')
                src.Data{x(1),x(2)} = 0;
                
            else
                obj.update_variable_table;
            end
        end
        
        function update_variable_table(obj)
            a = obj.CurrentBitmask;
            m = epsych.Bitmask(find(bitget(a,1:32,'uint32'))); %#ok<FNDSB>
            d = obj.VarTable.Data;
            d(cellfun(@isempty,d),:) = [];
            if ~isempty(m)
                u = union(d(:,1),m);
                d = [u num2cell(false(length(u),1))];
            end
            ind = false(size(d,1),1);
            for i = 1:length(m)
                ind = ind | ismember(d(:,1),char(m(i)));
            end
            d(end+1,1) = {''};
            d(:,2)     = num2cell([ind; false]);
            obj.VarTable.Data = d;
            
        end
        
        function expt_changed(obj,src,event)
            et = obj.ExptTypeDropdown.Value;
            pn  = fileparts(which('epsych.BitmaskGen'));
            switch et
                case 'Save'
                    name = inputdlg('Enter a name for the experiment type:','BitmaskGen',1);
                    if isempty(name), return; end
                    name = char(name);
                    fn  = matlab.lang.makeValidName(name);
                    fn  = [fn '.ebmx'];
                    ffn = fullfile(pn,fn);
                    fprintf('Saving new template: "%s" ...', name)
                    data = obj.DataTable.Data(1:4,:);
                    vars = obj.VarTable.Data;
                    vars(:,2) = num2cell(false(size(vars,1),1));
                    save(ffn,'data','vars','name','-mat');
                    obj.load_expts;
                    obj.ExptTypeDropdown.Value = fn;
                    fprintf(' done\n')
                    
                otherwise
                    load(fullfile(pn,et),'data','vars','-mat');
                    d = obj.DataTable.Data;
                    d(1:4,:) = repmat({0},4,size(d,2));
                    if isnumeric(data), data = num2cell(data); end
                    d(1:4,1:size(data,2)) = data;
                    obj.DataTable.Data = d;
                    obj.VarTable.Data = vars;
                    
            end
            setpref('epsych_BitmaskGen','expt',obj.ExptTypeDropdown.Value);
        end
        
        function copy_datatable(obj,~,~)
            
            d = obj.DataTable.Data;
            d = reshape([d{:}],size(d));
            
            s = '';
            for j = 1:size(d,1)
                s = sprintf('%s%d\t%d\t%d\t%d\t%d\n',s,d(j,:));
            end
            
            clipboard('copy',s)
            s = ['The data table has been copied to the clipboard.\n', ...
                'Highlight all cells in your RPvds state machine data table and use ''Ctrl+v'' to paste.'];
            uialert(obj.parent,s,'Data Table Copied','Icon','success');
        end
        
        function load_expts(obj)
            pn = fileparts(which('epsych.BitmaskGen'));
            d = dir(fullfile(pn,'*.ebmx'));
            fn = {d.name};
            names = fn;
            for i = 1:length(fn)
                load(fullfile(pn,fn{i}),'name','-mat');      
                names{i} = name;
            end
            obj.ExptTypeDropdown.Items     = [names {'Save Template ...'}];
            obj.ExptTypeDropdown.ItemsData = [fn {'Save'}];
            obj.ExptTypeDropdown.Value     = obj.ExptTypeDropdown.ItemsData{1};
            
            obj.expt_changed;
        end
    end
    
    methods (Static)
        function m = encode(ind)
            m = sum(2.^(find(ind)-1));
        end
        
        function ind = decode(a)
            ind = false(1,32);
            for i = 1:length(a)
                ind = ind | bitget(a,1:32,'uint32');
            end
        end
    end
    
end