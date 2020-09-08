classdef OverviewSetup < handle
    
    
    properties (Access = protected)
        tree                matlab.ui.container.Tree
        treeHardware        matlab.ui.container.TreeNode
        treeHardwareNodes   matlab.ui.container.TreeNode
        treeConfig          matlab.ui.container.TreeNode
        treeConfigNodes     matlab.ui.container.TreeNode
        treeSubject         matlab.ui.container.TreeNode
        treeSubjectNodes    matlab.ui.container.TreeNode
        
        mainPanel           matlab.ui.container.Panel
        logPanel            matlab.ui.container.Panel
    end
    
    properties (SetAccess = immutable)
        parent
    end
    
    methods
        create(obj,parent);
        
        % Constructor
        function obj = OverviewSetup(parent)
            narginchk(1,1)
            
            create(obj,parent)
            
            obj.parent = parent;
            
            obj.tree.SelectedNodes = obj.treeConfig;
            ev.SelectedNodes = obj.treeConfig;
            ev.PreviousSelectedNodes = [];
            ev.Source = [];
            ev.EventName = 'Initialize';
            obj.selection_changed([],ev);
            
            if nargout == 0, clear obj; end
        end
        
        function delete(obj)
            delete(obj.parent)
        end
        
        
    end % methods (Access = public)
    
    methods (Access = private)
        
        function selection_changed(obj,src,event)
            global RUNTIME
            
            fig = ancestor(obj.parent,'figure');
            fig.Pointer = 'watch'; drawnow
            
            node = obj.tree.SelectedNodes;
            
            delete(get(obj.mainPanel,'children'));
            
            if ~isequal(node.Tag,'ProgramLog')
                obj.logPanel.Visible = 'off';                
            end
            
            
            log_write('Debug','Selecting display "%s" [%s]',node.Text,node.Tag)
            
            
            switch node.Tag(1:4)
                case 'parC' % parConfig
                    epsych.ui.ConfigSetup(obj.mainPanel,'logo');
                    expand(node);

                case 'Conf' % Config
                    epsych.ui.ConfigSetup(obj.mainPanel,node.Tag(7:end));
                    
                case 'parS' % parSubjects
                    % TODO: Assign subjects to boxes
                    
                    if isempty(RUNTIME.Subject)
                        str = 'You must add at least one subject';
                    else
                        str = {RUNTIME.Subject.Name};
                    end
                    
                    g = uigridlayout(obj.mainPanel);
                    g.ColumnWidth = {'1x'};
                    g.RowHeight = {'1x'};
                    h = uitextarea(g);
                    h.Editable = 'off';
                    h.Value = str;
                    h.FontSize = 16;
                    h.FontName = 'Consolas';
                    
                    expand(node);
                    
                case 'AddS' % AddSubject
                    h = node.Parent.Children;
                    sind = ismember({h.Tag},'AddSubject');
                    h(sind) = [];
                    if isempty(h)
                        str = 'Unnamed Subject';
                    else
                        str = matlab.lang.makeUniqueStrings([{h.Text} {'Unnamed Subject'}]);
                        str = str{end};
                    end
                   
                    if isequal(event.EventName,'LoadedSubject')
                        S = event.LoadedData;
                    else
                        S = epsych.expt.Subject;
                        S.Name = str;
                    end
                    
                    h = uitreenode(node.Parent,node,'Text',S.Name,'Tag',sprintf('Subject_%d',length(h)+1));
                    move(h,node,'before');
                    
                    obj.tree.SelectedNodes = h;
                    
                    if isempty(RUNTIME.Subject)
                        RUNTIME.Subject = S;
                    else
                        RUNTIME.Subject(end+1) = S;
                    end
                    
                    h.Icon = epsych.Tool.icon('mouse');
                    
                    obj.add_contextmenu(h);
                    
                    ev.SelectedNodes = h;
                    ev.PreviousSelectedNodes = node;
                    ev.Source = src;
                    ev.EventName = 'SubjectAdded';
                    obj.selection_changed(src,ev);
                    
                    notify(RUNTIME,'RuntimeConfigChange');
                    
                case 'Subj' % Subject_#
                    ind = ismember({RUNTIME.Subject.Name},event.SelectedNodes.Text);
                    S = RUNTIME.Subject(ind);
                    sdh = epsych.ui.SubjectDialog(S,obj.mainPanel);
                    
                    addlistener(sdh,'FieldUpdated',@obj.subject_updated);
                    
                    node.NodeData = sdh;
                    
                    
                case 'parH' % parHardware
                    %m = metaclass('epsych.hw.Hardware'); % doesn't work??
                    fn = {'Name','Type','Description','Vendor','MaxNumInstances','Status'};
                    ml = max(cellfun(@length,fn))+1;
                    
                    ahw = epsych.hw.Hardware.available;
                    
                    p = sprintf('Available Hardware Modules:\n\n');
                    for h = 1:length(ahw)
                        for i = 1:length(fn)
                            hw = epsych.hw.(ahw{h});
                            v = hw.(fn{i});
                            if isnumeric(v), v = mat2str(v); end
                            p = sprintf('%s% *s: %s\n',p,ml,fn{i},v);
                        end
                        p = sprintf('%s%s\n',p,repmat('-',1,50));
                    end
                    
                    g = uigridlayout(obj.mainPanel);
                    g.RowHeight = {'1x'};
                    g.ColumnWidth = {'1x'};
                    h = uitextarea(g);
                    h.Value = p;
                    h.FontName = 'Consolas';
                    h.FontSize = 16;
                    h.BackgroundColor = [1 1 1];
                    h.Editable = 'off';
                    
                    expand(node);
                   
                case 'AddH' % AddHardware
                    if isequal(event.EventName,'LoadedHardware')
                        hw = epsych.ui.HardwareSetup(obj.mainPanel,event.LoadedData);
                    else
                        hw = epsych.ui.HardwareSetup(obj.mainPanel);
                    end
                    
                    if isempty(hw.Hardware) % user cancelled
                        obj.tree.SelectedNodes = obj.treeHardware;
                        obj.selection_changed(src,event);
                        log_write('Verbose','No more hardware is available.')
                        return
                    end
                    
                    h = node.Parent.Children;
                    sind = ismember({h.Tag},'AddHardware');
                    h(sind) = [];
                    if isempty(h)
                        str = hw.Hardware.Alias;
                    else
                        str = matlab.lang.makeUniqueStrings([{h.Text} {hw.Hardware.Alias}]);
                        str = str{end};
                    end
                    str = strcat(str,' [',hw.Hardware.Name,']');
                    h = uitreenode(node.Parent,node,'Text',str,'Tag',sprintf('Hardware_%d',length(h)+1));
                    move(h,node,'before');
                    
                    h.NodeData = hw;
                    
                    ic = epsych.Tool.icon(hw.Hardware.Vendor);
                    if exist(ic,'file')
                        h.Icon = ic;
                    else
                        h.Icon = epsych.Tool.icon('hardware');                        
                    end
                    
                    obj.add_contextmenu(h);
                    
                    obj.tree.SelectedNodes = h;
                    
                    log_write('Verbose','Added Hardware: "%s"',str);
                    
                    addlistener(hw,'HardwareUpdated',@obj.hardware_updated);
                     
                case 'Hard' % Hardware
                    ind = cellfun(@(a) startsWith(node.Text,a.Alias),RUNTIME.Hardware);
                    hardware = RUNTIME.Hardware{ind};
                    epsych.ui.HardwareSetup(obj.mainPanel,hardware);
                    
                case 'Load' % Load
                    obj.load_node;
                    
                case 'Prog' % ProgramLog
                    obj.logPanel.Visible = 'on';
            end
            fig.Pointer = 'arrow';
        end
        
        
        function add_contextmenu(obj,node)
            cm = uicontextmenu(ancestor(obj.parent,'figure'));
            
            m = uimenu(cm,'Text','&Remove','Tag','Remove');
            m.MenuSelectedFcn = @obj.remove_node;
            m.Accelerator = 'R';
            
            m = uimenu(cm,'Text','&Save','Tag','Save');
            m.MenuSelectedFcn = @obj.save_node;
            m.Accelerator = 'S';
            
            node.ContextMenu = cm;
        end
        
        
        function remove_node(obj,hObj,event)
            global RUNTIME
            
            node = obj.tree.SelectedNodes;
            if ~isempty(node.Children), return; end
            
            n = node.Text;
            nodeParent = node.Parent;
            delete(node);
            obj.tree.SelectedNodes = nodeParent;
            
            log_write('Verbose','Removed %s node: "%s"',nodeParent.Text,n);
            
            switch nodeParent.Text
                case 'Subjects'
                    ind = ismember({RUNTIME.Subject.Name},n);
                    RUNTIME.Subject(ind) = [];
                    
                case 'Hardware'
                    ind = cellfun(@(a) startsWith(n,a.Alias),RUNTIME.Hardware);
                    RUNTIME.Hardware(ind) = [];
            end
            
            notify(RUNTIME,'RuntimeConfigChange');
            
            ev.Source = hObj;
            ev.EventName = 'RemovedNode';
            obj.selection_changed(nodeParent,ev);
        end
        
        
        
        function load_node(obj,hObj,event)            
            global RUNTIME

            node = obj.tree.SelectedNodes;
            
            switch node.Tag(5:7)
                case 'Sub'
                    ext = '.esub';
                    extType = 'Subject';
                    
                case 'Har'
                    ext = '.ehwr';
                    extType = 'Hardware';
            end
            
            pn = getpref('epsych_Config',sprintf('%sNodePath',extType),epsych.Info.user_directory);

            [fn,pn] = uigetfile({['*' ext],extType}, ...
                sprintf('Save %s',extType),pn);
            
            if isequal(fn,0), return; end

            ffn = fullfile(pn,fn);           
            
            load(ffn,extType,'-mat');
            
            setpref('epsych_Config',sprintf('%sNodePath',extType),pn);

            ev.SelectedNodes = node.Parent;
            ev.EventName = sprintf('Loaded%s',extType);
            eval(sprintf('ev.LoadedData = %s;',extType));
            obj.tree.SelectedNodes = obj.(sprintf('tree%sNodes',extType))(end-1);
            obj.selection_changed([],ev);
            
            notify(RUNTIME,'RuntimeConfigChange');
            
            log_write('Verbose','Loaded %s: "%s"',extType,ffn)
        end
        
        
        function save_node(obj,hObj,event)
            
            node = obj.tree.SelectedNodes;
            
            switch node.Tag(1:3)
                case 'Sub'
                    ext = '.esub';
                    extType = 'Subject';
                    
                case 'Har'
                    ext = '.ehwr';
                    extType = 'Hardware';
            end
            
            pn = getpref('epsych_Config',sprintf('%sNodePath',extType),epsych.Info.user_directory);

            [fn,pn] = uiputfile({['*' ext],extType}, ...
                sprintf('Save %s',extType),pn);
            
            if isequal(fn,0), return; end
            
            ffn = fullfile(pn,fn);           
            
            eval(sprintf('%s = node.NodeData.%s;',extType,extType));
            
            save(ffn,extType);
            
            vprintf('Verbose','Saved %s: "%s"',extType,ffn)
            
            setpref('epsych_Config',sprintf('%sNodePath',extType),pn);
        end
        
        
        function subject_updated(obj,hObj,event)
            global RUNTIME
            
            node = obj.tree.SelectedNodes;
            
            ind = ismember({RUNTIME.Subject.Name},node.NodeData.Subject.Name);
            RUNTIME.Subject(ind) = node.NodeData.Subject;
            node.Text = node.NodeData.Subject.Name;
            if node.NodeData.Subject.Active
                node.Icon = epsych.Tool.icon('mouse');
            else
                node.Icon = epsych.Tool.icon('mouse_grey');
            end
           
            log_write('Verbose','Subject "%s" updated',RUNTIME.Subject(ind).Name);
            
            notify(RUNTIME,'RuntimeConfigChange');
        end
        
        function hardware_updated(obj,hObj,event)
            global RUNTIME
            
            node = obj.tree.SelectedNodes;
            node.Text = strcat(event.Hardware.Alias,' [',event.Hardware.Name,']');
            
            log_write('Verbose','Hardware "%s" updated',node.Text);
            
            notify(RUNTIME,'RuntimeConfigChange');
        end
        
        
    end % methods (Access = private)
    
end











