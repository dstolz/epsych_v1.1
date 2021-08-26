classdef StimGenInterface < handle
    
    properties
        
    end
    
    properties (SetAccess = private)
        parent
        handles
        sgTypes
        sgObjs
        CurrentSignal
        
    end
    
    properties (Access = private)
        els
    end
    
    properties (Dependent)
        CurrentSGObj
    end
    
    methods
        
        function obj = StimGenInterface(parent)
            if nargin > 0, obj.parent = parent; end
            
            obj.sgTypes = stimgen.StimType.list;
            obj.sgObjs = cellfun(@(a) stimgen.(a),obj.sgTypes,'uni',0);
            
            obj.create;
            
            if nargout == 0, clear obj; end
        end
        
        
        function delete(obj)
            
        end
        
        
        function stimtype_changed(obj,src,event)
            
        end
        
        
        function commit_changes(obj,src,event)
            obj.CurrentSGObj.update_signal;
            
            obj.update_signal_plot;
        end
        
        function update_signal_plot(obj)
            h = obj.handles.SignalPlotLine;
            h.XData = obj.CurrentSGObj.Time;
            h.YData = obj.CurrentSGObj.Signal;
        end
        
        
        function sobj = get.CurrentSGObj(obj)
            st = obj.handles.TabGroup.SelectedTab;
            ind = ismember(obj.sgTypes,st.Title);
            sobj = obj.sgObjs{ind};
        end
        
    end
    
    methods (Access = private)
        function delete_main_figure(obj,src,event)
            
            pos = obj.parent.Position;
            setpref('StimGenInterface','parent_pos',pos);
            
            delete(obj.els);
            
            delete(src);
        end
        
        function create(obj)
            if isempty(obj.parent), obj.parent = uifigure('Name','StimGen'); end
            
            f = obj.parent;
            
            pos = f.Position;
            
            pos = getpref('StimGenInterface','parent_pos',pos);
            
            f.Position = pos;
            f.Scrollable = 'on';
            f.DeleteFcn = @obj.delete_main_figure;
            movegui(f,'onscreen');
            
            
            
            g = uigridlayout(f);
            g.ColumnWidth = {250,'1x',250};
            g.RowHeight   = {200,'1x',75};
            
            
            % signal plot
            ax = uiaxes(g);
            ax.Layout.Column = [1 2];
            ax.Layout.Row = 1;
            grid(ax,'on');
            box(ax,'on');
            xlabel(ax,'time (s)');
            obj.handles.SignalPlotAx = ax;
            
            h = line(ax,nan,nan);
            obj.handles.SignalPlotLine = h;
            
            % stimgen interface
            tg = uitabgroup(g);
            tg.Layout.Column = [1 2];
            tg.Layout.Row    = [2 3];
            tg.Tag = 'StimGenTabs';
            tg.TabLocation = 'left';
            tg.SelectionChangedFcn = @obj.stimtype_changed;
            obj.handles.TabGroup = tg;
            
            for i = 1:length(obj.sgTypes)
                try
                    sgt = obj.sgTypes{i};
                    sgo = obj.sgObjs{i};
                    fnc = @sgo.create_gui;
                    t = uitab(tg,'Title',sgt,'CreateFcn',fnc);
                    t.Scrollable = 'on';
                catch me
                    t.Title = sprintf('%s ERROR',sgt);
                end
            end
            
            
            
            
            
            % commit button
            h = uibutton(g);
            h.Layout.Column = 3;
            h.Layout.Row = 3;
            h.Text = 'Commit';
            h.FontSize = 20;
            h.FontWeight = 'bold';
            h.FontAngle = 'italic';
            h.ButtonPushedFcn = @obj.commit_changes;
            obj.handles.btn_CommitChanges = h;
            
            
            
        end
    end
end