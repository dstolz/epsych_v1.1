classdef BitmaskGen < handle
    
    properties
        filename (1,:) char
        
        VarTable
        DataTable
        
        tblIdx
        
    end
    
    properties (Access = protected)
        ExptTypeDropdown
        CopyButton
        DataTableTitle
        
        figSummary
        summary_hTitle
        summary_hLabel
        summary_hPanel
        
        bmIdx

        el_UpdatedBitmask
        
        
        Data
        
        BitmaskData         epsych.Bitmask
    end
    
    properties (Dependent)
        CurrentBitmask      epsych.Bitmask
    end
    
    properties (Access = private)
        defaultVars = {'Hit','Miss','CorrectReject','FalseAlarm','Reward','Punish','Timeout','StimulusTrial','CatchTrial'};
    end
    
    properties (Access = private, Hidden)
        VarMoveRowUp
        VarMoveRowDown
    end
    
    properties (SetAccess = immutable)
        parent % uifigure
    end
    
    events
        UpdatedBitmask
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
                    'Position',[400 250 720 360], ...
                    'Color',[0.9 0.9 0.9]);                
            end
            
            obj.create_gui;
            
            if ~isempty(obj.filename)
                obj.load(obj.filename);
            end
            
            if nargout == 0, clear obj; end
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
            load(obj.filename,'BitmaskData','StateMachineData','BitmaskTable','Options','-mat');
            obj.DataTable.Data = StateMachineData;
            obj.VarTable.Data  = BitmaskTable;
            obj.BitmaskData    = BitmaskData; %#ok<PROPLC>
            obj.ExptTypeDropdown.Value = Options.ExptType;
            fprintf(' done\n')
            
            setpref('epsych_BitmaskGen','projectDir',fileparts(obj.filename));
            
            figure(obj.parent);
            
            event.Indices = obj.tblIdx;
            obj.select_data([],event);
        end
        
        function save(obj,~,~)
            pn = getpref('epsych_BitmaskGen','projectDir',cd);
            [fn,pn] = uiputfile({'*.ebm','EPsych Bitmask File (*.ebm)'}, ...
                'Save Bitmask',pn);
            if isequal(fn,0), figure(obj.parent); return; end
            obj.filename = fullfile(pn,fn);
            
            StateMachineData = obj.DataTable.Data;
            BitmaskTable = obj.VarTable.Data;
            BitmaskTable(:,2) = num2cell(false(size(BitmaskTable,1),1));
            Options = struct('ExptType',obj.ExptTypeDropdown.Value);
            BitmaskData = obj.BitmaskData; %#ok<PROPLC>
            
            fprintf('Saving Bitmask Data "%s" ...',obj.filename)
            save(obj.filename,'BitmaskData','StateMachineData','BitmaskTable','Options','-mat');
            fprintf(' done\n')
            
            setpref('epsych_BitmaskGen','projectDir',pn);
            
            figure(obj.parent);
        end
        
        
        function bm = get.CurrentBitmask(obj)
            bm = [];
            obj.bmIdx(any(obj.bmIdx<1,2),:) = [];
            if ~isempty(obj.bmIdx)
                ind = sub2ind(size(obj.BitmaskData),obj.bmIdx(:,1),obj.bmIdx(:,2));
                bm = obj.BitmaskData(ind);
            end
        end
        
        

        function set.Data(obj,d)
            if ~iscell(d), d = num2cell(d); end
            obj.DataTable.Data = d;
            notify(obj,'UpdatedBitmask');
        end
        
        function d = get.Data(obj)
            d = cellfun(@uint16,obj.DataTable.Data);
        end
        
        
        
        function reset_data(obj,~,~)
            d = obj.Data;
            sz = size(d,2);
            d(5:end,:) = zeros(4,sz);
            obj.Data = d;
            
            obj.default_bitmask_data;
            
            event.Indices = obj.tblIdx;
            obj.select_data([],event);
        end
        
        
        function close_summary_fig(obj,~,~)
            delete(obj.el_UpdatedBitmask);
            delete(obj.figSummary);
        end

        function show_summary(obj,~,~)
            if isempty(obj.el_UpdatedBitmask) || ~isvalid(obj.el_UpdatedBitmask)
                obj.el_UpdatedBitmask = addlistener(obj,'UpdatedBitmask',@obj.show_summary);
            end


            if isempty(obj.figSummary) || ~isvalid(obj.figSummary)
                obj.figSummary = uifigure('Name','Bitmask Summary');
                obj.figSummary.Position = [500 150 630 600];
                obj.figSummary.Color = [0.9 0.9 0.9];
                obj.figSummary.CloseRequestFcn = @obj.close_summary_fig;
            
                g = uigridlayout(obj.figSummary);
                g.ColumnWidth = {'0.2x','1x','1x','1x','1x'};
                g.RowHeight   = {'0.25x','1x','1x','1x','1x'};
                
                h = uilabel(g);
                h.Layout.Column = [1 5];
                h.Layout.Row    = 1;
                h.HorizontalAlignment = 'center';
                h.FontSize = 16;
                h.FontWeight = 'bold';

                obj.summary_hTitle = h;

                for i = 1:5 % col
                    for j = 1:4 % row
                        p = uipanel(g);
                        p.Layout.Column = i;
                        p.Layout.Row    = j+1;
                        if i == 1
                            p.Title='S0';
                        end
                        
                        obj.summary_hPanel(j,i) = p;
                        
                        gp = uigridlayout(p);
                        gp.ColumnWidth = {'1x'};
                        gp.RowHeight   = {'1x'};
                        
                        h = uilabel(gp);
                        if i == 1 % S0
                            h.Text = 'x';
                            continue
                        end
                        h.Layout.Column = 1;
                        h.Layout.Row    = 1;
                        h.VerticalAlignment = 'top';
                    
                        obj.summary_hLabel(j,i) = h;
                    end
                end
            end
            
            figure(obj.figSummary);
            
            ind = ismember(obj.ExptTypeDropdown.ItemsData,obj.ExptTypeDropdown.Value);
            obj.summary_hTitle.Text = sprintf('Paradigm: %s',obj.ExptTypeDropdown.Items{ind});

            for i = 2:5 % col
                for j = 1:4 % row
                    set(obj.summary_hPanel(j,i),'Title',sprintf('S%d | output-%d [%d]',i-1,j-1,obj.BitmaskData(j,i).Mask));
                    
                    v = obj.BitmaskData(j,i).Values;
                    set(obj.summary_hLabel(j,i),'Text',obj.BitmaskData(j,i).Labels(v));
                end
            end
            set(obj.summary_hPanel, ...
                'BackgroundColor',[1 1 1], ...
                'FontWeight','normal');
            idx = obj.bmIdx;
            if isempty(idx), return; end
            set(obj.summary_hPanel(idx(:,1),idx(:,2)), ...
                'FontWeight','bold', ...
                'BackgroundColor',[.7 1 1]);
        end
        
    end
    
    methods (Access = private)
        function create_gui(obj)
            
            g = uigridlayout(obj.parent);
            g.ColumnWidth = {100,100,'1.5x','1x','1x','1x'};
            g.RowHeight   = {25,25,'1x'};
            
            
            % Variable Table
            hV = uitable(g);
            hV.Layout.Column  = [1 2];
            hV.Layout.Row     = 3;
%             hV.RowName        = [];
            hV.ColumnName     = {'Variable','State'};
            hV.ColumnWidth    = {'auto',60};
            hV.ColumnEditable = [true true];
            D = cell(15,2);
            D(:,2) = {false};
            hV.Data = D;
            %hV.ColumnFormat   = {[{'< REMOVE >'}; obj.defaultVars(:)]','logical'};
            hV.ColumnFormat   = {'char','logical'};
            hV.CellEditCallback = @obj.variable_updated;
            hV.CellSelectionCallback = @obj.variable_selected;

            % Move selected row up/down
            hpg = uigridlayout(g);
            hpg.Layout.Column = [1 2];
            hpg.Layout.Row    = 2;
            hpg.ColumnSpacing = 5;
            hpg.RowSpacing = 0;
            hpg.Padding = [0 0 0 0];
            hpg.ColumnWidth = {'1x',40,40};
            hpg.RowHeight   = {'1x'};
            
            hRU = uibutton(hpg);
            hRU.Layout.Column = 2;
            hRU.Text = char(9650);
            hRU.Tag = 'up';
            hRU.ButtonPushedFcn = @obj.move_var_row;
            
            
            hRD = uibutton(hpg);
            hRD.Layout.Column = 3;
            hRD.Text = char(9660);
            hRD.Tag = 'down';
            hRD.ButtonPushedFcn = @obj.move_var_row;
            
            
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
            
            % Reset Data table
            hR = uibutton(g);
            hR.Layout.Column = 4;
            hR.Layout.Row    = 1;
            hR.Text          = 'Reset';
            hR.ButtonPushedFcn = @obj.reset_data;
            
            % Show Summary button
            hY = uibutton(g);
            hY.Layout.Column = 5;
            hY.Layout.Row    = 1;
            hY.Text          = 'Show Summary';
            hY.ButtonPushedFcn = @obj.show_summary;
            
            % Copy button
            hC = uibutton(g);
            hC.Layout.Column = 6;
            hC.Layout.Row    = 1;
            hC.Text          = 'Copy Table';
            hC.ButtonPushedFcn = @obj.copy_datatable;
            
            
            % Expt Dropdown
            hE = uidropdown(g);
            hE.Layout.Column = 3;
            hE.Layout.Row    = 1;
            hE.ValueChangedFcn = @obj.expt_changed;
            
            % Data Table Label
            hL = uilabel(g);
            hL.Layout.Column = [3 6];
            hL.Layout.Row    = 2;
            hL.Text          = 'State Machine Data Table';
            hL.HorizontalAlignment = 'center';
            hL.FontSize      = 16;
            hL.FontWeight    = 'bold';
            
            % Data Table
            hD = uitable(g);
            hD.Layout.Column  = [3 6];
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


            obj.CopyButton       = hC;
            obj.ExptTypeDropdown = hE;
            obj.VarTable         = hV;
            obj.DataTable        = hD;
            obj.DataTableTitle   = hL;
            obj.VarMoveRowUp     = hRU;
            obj.VarMoveRowDown   = hRD;
            
            obj.DataTable.Data = num2cell(zeros(8,5,'uint16'));
            
            obj.default_bitmask_data;

            obj.load_expts;
        end
        
        function move_var_row(obj,src,event)

            idx = unique(obj.VarTable.Selection(:,1));
            if isempty(idx); return; end
            
            obj.VarMoveRowUp.Enable   = 'off';
            obj.VarMoveRowDown.Enable = 'off';
            drawnow
            
            d = obj.VarTable.Data;
            if isempty(d{end,1}), d(end,:) = []; end
            
            
            if isequal(src.Tag,'down'), idx = flipud(idx); end
            
            newIdx = 1:size(d,1);
            
            for i = 1:length(idx)
                ii = idx(i);
                switch src.Tag
                    case 'up'
                        if ii == 1, continue; end
                        newIdx = [newIdx(1:ii-2) newIdx(ii) newIdx(ii-1) newIdx(ii+1:end)];
                        
                    case 'down'
                        if ii == size(d,1), continue; end
                        newIdx = [newIdx(1:ii-1) newIdx(ii+1) newIdx(ii) newIdx(ii+2:end)];
                end
            end
%             
%             d = d(newIdx,:);
%             
%             d{end+1,1} = '';
%             d{end,2} = 0;
%             obj.VarTable.Data = d;
            
            arrayfun(@(o) o.reorder_bits(newIdx-1),obj.BitmaskData);
            
            bm = reshape([obj.BitmaskData.Mask],size(obj.BitmaskData));
            obj.Data(5:end,:) = bm;
            
            obj.update_variable_table;
            
%             % TESTING
%             clc
%             for i = 1:numel(obj.BitmaskData), disp(obj.BitmaskData(i).Labels); end
            
            if isequal(src.Tag,'up'), sel = idx - 1; else, sel = idx + 1; end
            sel = repmat(sel(:)',2,1);
            sel = sel(:);
            sel(:,2) = repmat([1; 2],length(sel)/2,1);
            sel(sel(:,1) > size(d,1) | sel(:,1) < 1,:) = [];          
            obj.VarTable.Selection = sel;
            
            ev.Indices = sel;
            obj.variable_selected(obj.VarTable,ev);           
            
            
        end
        
        function variable_selected(obj,src,event)
            idx = unique(event.Indices(:,1));
            
            idx(idx==size(src.Data,1)) = [];
            
            
            if isempty(idx)
                obj.VarMoveRowUp.Enable   = 'off';
                obj.VarMoveRowDown.Enable = 'off';
                
            elseif idx == 1
                obj.VarMoveRowUp.Enable   = 'off';
                obj.VarMoveRowDown.Enable = 'on';
                
            elseif idx == size(src.Data,1)-1
                obj.VarMoveRowUp.Enable   = 'on';
                obj.VarMoveRowDown.Enable = 'off';
                
            else
                obj.VarMoveRowUp.Enable   = 'on';
                obj.VarMoveRowDown.Enable = 'on';
            end
            
            drawnow
        end
        
        function variable_updated(obj,src,event)                        
            r = event.Indices;
            
            if isempty(obj.bmIdx)
                uialert(obj.parent, ...
                    sprintf('You must select a cell in the Bitmask table\n\ni.e. The white area of the State Machine Data Table.'), ...
                    'Bitmask','Icon','info');
                src.Data(r(1),r(2)) = {event.PreviousData};
                return
            end
            
            % check for duplicates
            if r(2) == 1
                ind = true(size(obj.Data,1),1);
                ind(r(1)) = false;
                if ismember(event.NewData,src.Data(ind,1))
                    src.Data(r(1),1) = {event.PreviousData};
                    uialert(obj.parent,'Duplicates are not allowed', ...
                        'Bitmask','Icon','warning');
                    return
                end
            end
            
                        
            lbl = src.Data{r(1),1};
            val = src.Data{r(1),2};
            
            bm = obj.CurrentBitmask;

            if isempty(lbl)
                src.Data{r(1),2} = false;
                return
            elseif isequal(lbl,'< REMOVE >')
                src.Data(r(1),:) = [];
                arrayfun(@(a) a.remove_bit(event.PreviousData),obj.BitmaskData);
                
            elseif ~ismember(lbl,bm(1).Labels)
                if ~isempty(event.PreviousData)
                    arrayfun(@(a) a.remove_bit(event.PreviousData),obj.BitmaskData);
                end
                arrayfun(@(a) a.add_bit(lbl,r(1)-1),obj.BitmaskData);
                
            else
                arrayfun(@(a) a.update_bit(lbl,val),bm);
            end
            
            ind = sub2ind(size(obj.Data),obj.bmIdx(:,1)+4,obj.bmIdx(:,2));
            obj.Data(ind) = [bm.Mask];
        end
        
        function select_data(obj,src,event)
            if isempty(event.Indices)
                % ignore                
            elseif event.Indices(end,1) <= 4
                obj.bmIdx = [];
                obj.VarTable.Enable = 'off';
            else
                obj.bmIdx = [event.Indices(:,1)-4, event.Indices(:,2)];
                obj.VarTable.Enable = 'on';
                obj.update_variable_table;
            end
            
            obj.tblIdx = event.Indices;
            
            notify(obj,'UpdatedBitmask');
        end
        
        function edit_data(obj,src,event)
            x = event.Indices(end,:);
            d = event.NewData;
            
            if x(1) <= 4
                if d > 4
                    uialert(obj.parent,'Values must be less than or equal to the number of states (<=4)','Invalid Value','Icon','info')
                    obj.Data{x(1),x(2)} = event.PreviousData;
                end
            
            elseif x(2) == 1
                uialert(obj.parent,'State 0 (S0) must always be zero.','Invalid Value','Icon','info')
                obj.Data{x(1),x(2)} = 0;
                
            else
                bm = obj.CurrentBitmask;
%                 d.Mask = d; % TODO:...
                obj.update_variable_table;
            end

            notify(obj,'UpdatedBitmask');
        end
        
        function update_variable_table(obj)
            bm = obj.CurrentBitmask;
            if numel(bm) > 1
                vals = all(cell2mat({bm.Values}'));
            else
                vals = bm.Values;
            end
            d = [bm(1).Labels', num2cell(vals)'];
            d(end+1,:) = {'',false};
            obj.VarTable.Data = d;
        end
        
        function expt_changed(obj,src,event)
            et = obj.ExptTypeDropdown.Value;
            pn  = fileparts(which('epsych.ui.BitmaskGen'));
            switch et
                case 'Save'
                    name = inputdlg('Enter a name for the experiment type:','BitmaskGen',1);
                    if isempty(name), return; end
                    name = char(name);
                    fn  = matlab.lang.makeValidName(name);
                    fn  = [fn '.ebmx'];
                    ffn = fullfile(pn,fn);
                    fprintf('Saving new template: "%s" [%s] ...', name,ffn)
                    data = obj.DataTable.Data(1:4,:);
                    vars = obj.VarTable.Data;
                    vars(:,2) = num2cell(false(size(vars,1),1));
                    save(ffn,'data','vars','name','-mat');
                    obj.load_expts;
                    obj.ExptTypeDropdown.Value = fn;
                    fprintf(' done\n')
                    
                otherwise
                    ffn = fullfile(pn,et);
                    fprintf('Loading template: "%s" [%s] ...', et,ffn)
                    load(ffn,'data','vars','-mat');
                    d = obj.DataTable.Data;
                    d(1:4,:) = repmat({0},4,size(d,2));
                    if isnumeric(data), data = num2cell(data); end
                    d(1:4,1:size(data,2)) = data;
                    obj.DataTable.Data = d;
                    obj.VarTable.Data = vars;
                    obj.defaultVars = vars(~cellfun(@isempty,vars(:,1)),1);
                    obj.default_bitmask_data;
                    fprintf(' done\n')
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
            s = sprintf(['The data table has been copied to the clipboard.\n\n', ...
                'Highlight all cells in your RPvds state machine data table and use ''Ctrl+v'' to paste.']);
            uialert(obj.parent,s,'Data Table Copied','Icon','success');
        end
        
        function load_expts(obj)
            pn = fileparts(which('epsych.ui.BitmaskGen'));
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
        
        
        
        function default_bitmask_data(obj)    
            sz = size(obj.DataTable.Data);
            bm(4,sz(2)) = epsych.Bitmask(obj.defaultVars);
            for i = 1:numel(bm)
                bm(i) = epsych.Bitmask(obj.defaultVars);
                [r,c] = ind2sub([4 sz(2)],i);
                bm(i).UserData = [r c];
            end
            obj.BitmaskData = bm;
        end
        
    end % methods (Access = private)
end