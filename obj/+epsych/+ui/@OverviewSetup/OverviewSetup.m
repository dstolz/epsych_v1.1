classdef OverviewSetup < handle
    
    
    properties (Access = protected)
        tree                matlab.ui.container.Tree
        treeHardware        matlab.ui.container.TreeNode
        treeHardwareNodes   matlab.ui.container.TreeNode
        treeConfig          matlab.ui.container.TreeNode
        treeConfigNodes     matlab.ui.container.TreeNode
        treeSubject         matlab.ui.container.TreeNode
        treeSubjectNodes    matlab.ui.container.TreeNode
        
        panel               matlab.ui.container.Panel
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
            global RUNTIME LOG
            
            fig = ancestor(obj.parent,'figure');
            fig.Pointer = 'watch'; drawnow
            
            
            node = obj.tree.SelectedNodes;
            
            delete(get(obj.panel,'children'));
            
            LOG.write('Debug','Selecting display "%s" [%s]',node.Text,node.Tag)
            
            switch node.Tag(1:4)
                case 'parC' % parConfig
                    
                case 'Conf'
                    if endsWith(node.Tag,'Info')
                        g = uigridlayout(obj.panel);
                        g.RowHeight = {'1x'};
                        g.ColumnWidth = {'1x'};
                        h = uilabel(g,'Text',epsych.Info.print);
                        h.FontName = 'Consolas';
                        h.FontSize = 14;
                        h.VerticalAlignment = 'top';
                    else
                        h = epsych.ui.ConfigSetup(obj.panel,node.Tag(7:end));
                        %notify(RUNTIME,'RuntimeConfigChange');
                    end
                    
                
                case 'parS' % parSubjects
                    % TODO: Assign subjects to boxes
                    
                case 'AddS'
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
                        S = epsych.Subject;
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
                    
                case 'Subj'
                    ind = ismember({RUNTIME.Subject.Name},event.SelectedNodes.Text);
                    ind = find(ind,1);
                    S = RUNTIME.Subject(ind);
                    sdh = epsych.ui.SubjectDialog(S,obj.panel);
                    
                    addlistener(sdh,'FieldUpdated',@obj.subject_updated);
                    
                    node.NodeData = sdh;
                    
                    
                case 'AddH'                    
                    hw = epsych.ui.HardwareSetup(obj.panel);
                    
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
                    if isempty(ic)
                        h.Icon = epsych.Tool.icon('hardware');
                    else
                        h.Icon = ic;
                    end
                    
                    obj.add_contextmenu(h);

                    obj.tree.SelectedNodes = h;
                    
                    addlistener(hw,'HardwareUpdated',@obj.hardware_updated);
                                        
                case 'parH'
                    % TODO: List summary of hardware being used
                    
                    
                case 'Load'
                    obj.load_node;
                    
                case 'Prog'
                    LOG.create_gui(obj.panel);
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
            node = obj.tree.SelectedNodes;
            nodeParent = node.Parent;
            delete(node);
            obj.tree.SelectedNodes = nodeParent;
            
            ev.Source = hObj;
            ev.EventName = 'RemovedNode';
            obj.selection_changed(nodeParent,ev);
        end
        
        
        
        function load_node(obj,hObj,event)

            node = obj.tree.SelectedNodes;
            
            switch node.Tag(5:7)
                case 'Sub'
                    ext = '.esub';
                    extType = 'Subject';
                    
                case 'Har'
                    ext = '.ehar';
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
            vprintf('Verbose','Loaded %s: "%s"',extType,ffn)
            
        end
        
        
        function save_node(obj,hObj,event)
            
            node = obj.tree.SelectedNodes;
            
            switch node.Tag(1:3)
                case 'Sub'
                    ext = '.esub';
                    extType = 'Subject';
                    
                case 'Har'
                    ext = '.ehar';
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
            
            notify(RUNTIME,'RuntimeConfigChange');
        end
        
        function hardware_updated(obj,hObj,event)            
            node = obj.tree.SelectedNodes;
            node.Text = strcat(event.Hardware.Alias,' [',event.Hardware.Name,']');
            
            notify(RUNTIME,'RuntimeConfigChange');
        end
        
        
    end % methods (Access = private)
    
end











