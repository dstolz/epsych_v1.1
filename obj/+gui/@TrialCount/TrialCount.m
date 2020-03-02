classdef TrialCount < handle
    
    properties
        BoxID   (1,1) uint8 {mustBeNonempty,mustBeNonNan} = 1;
    end

    properties (Access = protected)
        txt_TrialCount
        txt_TrialType
        txt_CurrentTrialIndex
        
        lbl_TrialCount
        lbl_TrialType
        lbl_CurrentTrialIndex
               
        
    end
    
    properties (Access = private)
        hl_NewTrial
    end

    properties (SetAccess = immutable)
        parent
    end
    
    methods
        % Constructor
        function obj = TrialCount(parent,BoxID)
            global RUNTIME
            
            obj.parent = parent;
            if nargin == 2 && ~isempty(BoxID), obj.BoxID = BoxID; end
            
            obj.hl_NewTrial = addlistener(RUNTIME.HELPER(obj.BoxID),'NewTrial',@obj.update);
        end
        
        % Destructor
        function delete(obj)
            delete(obj.hl_NewTrial);
        end
        
        function set.parent(obj,parent)
            obj.parent = parent;
            obj.create;
        end
        
        function create(obj)
            ou = get(obj.parent,'Units');
            
            set(obj.parent,'Units','Normalized');
            
            obj.lbl_TrialCount = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','Trial Count', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','right', ...
                'Units','normalized', ...
                'Position',[0 0.6 0.5 0.25]);
            
            obj.txt_TrialCount = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','---', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','center', ...
                'Units','normalized', ...
                'Position',[0.51 0.6 0.49 0.25]);
            
            obj.lbl_TrialType = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','Trial Type', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','right', ...
                'Units','normalized', ...
                'Position',[0 0.3 0.5 0.22]);
            
            obj.txt_TrialType = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','---', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','center', ...
                'Units','normalized', ...
                'Position',[0.51 0.3 0.49 0.22]);
            
            obj.lbl_CurrentTrialIndex = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','Trial Index', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','right', ...
                'Units','normalized', ...
                'Position',[0 0.1 0.5 0.22]);
            
            obj.txt_CurrentTrialIndex = uicontrol(obj.parent, ...
                'Style','text', ...
                'String','---', ...
                'FontUnits','points', ...
                'FontSize',14, ...
                'HorizontalAlignment','center', ...
                'Units','normalized', ...
                'Position',[0.51 0.1 0.49 0.22]);
            
            set(obj.parent,'Units',ou);
            
        end
        
        
        function update(obj,source,event)
            trc = event.Data.DATA(end).TrialID;
            if isempty(trc), trc = '---'; end
            obj.txt_TrialCount.String = trc;
            
            idx = event.Data.NextTrialID;
            if isempty(idx), idx = '---'; end
            obj.txt_CurrentTrialIndex.String = idx;
            
            ttind = ismember(event.Data.writeparams,'TrialType');
            if isempty(idx)
                tt = '---';
            else
                tt = event.Data.trials{idx,ttind};
            end
            obj.txt_TrialType.String = tt;
        end

        
        function set.BoxID(obj,id)
            global RUNTIME
            obj.BoxID = id;
            delete(obj.el_NewTrial); % destroy old listener and create a new one for the new BoxID
            obj.el_NewTrial = addlistener(RUNTIME.HELPER(obj.BoxID),'NewTrial',@obj.new_trial);
        end
    end
    
    
end



