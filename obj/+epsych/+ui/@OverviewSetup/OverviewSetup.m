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
            
            if nargout == 0, clear obj; end
        end

        function delete(obj)
            delete(obj.parent)
        end
        
%         function update(obj,~,evnt)
%             global RUNTIME
            
%             h = findobj(obj.treeConfig);
%             h(~ismember({h.Tag},fieldnames(RUNTIME.Config))) = [];
%             obj.update_node_text(h,RUNTIME.Config);           
            
            
%             if ~isempty(RUNTIME.Subject)
%                 delete(obj.treeSubjectNodes);
%                 sn = {RUNTIME.Subject.Name};
%                 sn = cellfun(@(a,b) sprintf('%d. %s',a,b),num2cell(1:numel(sn)),sn,'uni',0);
%                 for i = 1:length(sn)
%                     sh = uitreenode(obj.treeSubject,'Text',sn{i},'Tag',sprintf('Subject_%d',i));
                    
%                     n        = uitreenode(sh,'Text','Name:','Tag','Name');
%                     n(end+1) = uitreenode(sh,'Text','Ready:','Tag','isReady');
%                     n(end+1) = uitreenode(sh,'Text','Active:','Tag','Active');
%                     n(end+1) = uitreenode(sh,'Text','ID:','Tag','ID');
%                     n(end+1) = uitreenode(sh,'Text','DOB:','Tag','DOB');
%                     n(end+1) = uitreenode(sh,'Text','Sex:','Tag','Sex');
%                     n(end+1) = uitreenode(sh,'Text','Baseline Weight:','Tag','BaselineWeight');
%                     n(end+1) = uitreenode(sh,'Text','Protocol:','Tag','ProtocolFile');
%                     n(end+1) = uitreenode(sh,'Text','Note:','Tag','Note');
%                                         
%                     obj.update_node_text(n,RUNTIME.Subject(i));
                    
%                     obj.treeSubjectNodes(i) = sh;
%                 end
%             end
            
            
            
            %h = findobj(obj.treeHardware);
            %(~ismember({h.Tag},fieldnames(RUNTIME.Hardware))) = [];
            %obj.update_node_text(h);
%         end
        
    end
    
    methods (Access = private)
        function update_node_text(obj,h,F)

            for i = 1:numel(h)
                r = h(i).Text(1:find(h(i).Text==':',1,'first'));
                v = F.(h(i).Tag);
                if isequal(class(v),'function_handle')
                    v = func2str(v);
                end
                
                if isnumeric(v)
                    v = mat2str(v);
                end
                
                if islogical(v)
                    if v
                        v = 'True';
                    else
                        v = 'False';
                    end
                end
                    
                h(i).Text = sprintf('%s %s',r,v);
            end
        end
        
        function selection_changed(obj,src,event)
            global RUNTIME
            
            prevNode = event.PreviousSelectedNodes;
            if ~isempty(prevNode)
                switch prevNode.Tag(1:3)
                    case 'Sub'
                        if isa(prevNode.NodeData,'epsych.ui.SubjectDialog')
                            ind = ismember({RUNTIME.Subject.Name},prevNode.NodeData.Subject.Name);
                            RUNTIME.Subject(ind) = prevNode.NodeData.Subject;
                            prevNode.Text = prevNode.NodeData.Subject.Name;
                        end
                end
            end
            
            node = obj.tree.SelectedNodes;
            
            delete(get(obj.panel,'children'));
            
            switch node.Tag(1:3)
                case 'Add'
                        h = node.Parent.Children;
                        sind = ismember({h.Tag},'AddSubject');
                        h(sind) = [];
                        if isempty(h)
                            str = 'New Subject';
                        else
                            str = matlab.lang.makeUniqueStrings([{h.Text} {'New Subject'}]);
                            str = str{end};
                        end
                        h = uitreenode(node.Parent,node,'Text',str,'Tag',sprintf('Subject_%d',length(h)+1));
                        move(h,node,'before');
                        
                        obj.tree.SelectedNodes = h;
                                                
                        S = epsych.Subject;
                        S.Name = str;
                        
                        if isempty(RUNTIME.Subject)
                            RUNTIME.Subject = S;
                        else
                            RUNTIME.Subject(end+1) = S;
                        end
                        
                        ev.SelectedNodes = h;
                        ev.PreviousSelectedNodes = node;
                        ev.Source = src;
                        ev.EventName = 'SubjectAdded';
                        obj.selection_changed(src,ev);
                        
                case 'Sub'
                        ind = ismember({RUNTIME.Subject.Name},event.SelectedNodes.Text);
                        S = RUNTIME.Subject(ind);
                        sdh = epsych.ui.SubjectDialog(S,obj.panel);
                        
                        node.NodeData = sdh;                        
                    
                case 'Con'
                    epsych.ui.ConfigSetup(obj.panel);
                    
                case 'Har'
                    epsych.ui.HardwareSetup(obj.panel);
                    
            end
        end
    end
    
end











