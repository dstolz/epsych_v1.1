classdef StimGenInterface < handle & gui.Helper
    
    properties
        StimObjList % stimgen objects
        StimListIdx (1,1) double {mustBeInteger} = 0;
        StimReps    (:,1) double {mustBeInteger};
        StimNames   (:,1) string
        StimISI     {}
    end
    
    properties (SetAccess = private)
        parent
        handles
        sgTypes
        sgObjs
        CurrentSignal
        
        StimRepsRemaining (:,1) double {mustBeInteger} = 0;
    end
    
    properties (Access = private)
        els
    end
    
    properties (Dependent)
        CurrentSGObj
    end
    
    methods
        
        function obj = StimGenInterface(parent)
%             global AX
            
%             obj.TDTActiveX = AX;
            
            if nargin > 0, obj.parent = parent; end
            
            obj.sgTypes = stimgen.StimType.list;
            obj.sgObjs = cellfun(@(a) stimgen.(a),obj.sgTypes,'uni',0);
            
            obj.create;
            
            if nargout == 0, clear obj; end
        end
        
        
        function delete(obj)
            
        end
        
        
        
        
        function playback_control(obj,src,event)
            
            c = src.Text;
            
            switch lower(c)
                
                case 'run'
                    
                case 'stop'
                    
                case 'pause'
                    
            end
            
        end
        
        
        
        
        
        
        function stimtype_changed(obj,src,event)
            obj.update_signal_plot;
        end
        
        function add_stim_to_list(obj,src,event)
            h = obj.handles;
            
            n = h.Reps.Value;
            
            sn = h.StimName.Value;
            
            v = h.ISI.Value;
            v = str2num(v);
            
            obj.StimObjList{end+1} = obj.CurrentSGObj;
            obj.StimReps(end+1) = n;
            obj.StimNames{end+1} = sn;
            obj.StimISI{end+1} = v;
            
            c = class(obj.CurrentSGObj);
            c = c(find(c=='.',1,'last')+1:end);
            
            str = sprintf('%02dx %s - %s',n,c,sn);
            
            h.StimObjList.Items{end+1} = str;
        end
        
        function rem_stim_from_list(obj,src,event)
            h = obj.handles;
            
            ind = ismember(h.StimObjList.Items,h.StimObjList.Value);
            h.StimObjList.Items(ind) = [];
            obj.StimObjList(ind) = [];
            obj.StimReps(ind) = [];
            obj.StimNames(ind) = [];
            obj.StimISI(ind) = [];
        end
        
        function update_playmode(obj,src,event)
            
        end
        
        function update_isi(obj,src,event)
            h = obj.handles;
            v = h.ISI.Value;
            v = str2num(v);
            v = sort(v(:)');
            try
                src.Value = mat2str(v);
            catch me
                uialert(obj.parent,me.message,'InvalidEntry','modal',true)
                h.ISI.Value = vent.Previous;
            end
        end
        
%         function set.ISI(obj,v)
%             v = v(:)';
%             v = sort(v);
%             assert(~isempty(v) & numel(v)<=2, ...
%                 'gui:StimGenInterface:update_isi:InvalidEntry', ...
%                 'Values for ISI must be either 1x1 or 1x2 range of numbers');
%             obj.ISI = v;
%         end
        
        
        function play_current_stim_audio(obj,src,event)
            h = obj.handles.PlayStimAudio;
            
            c = h.BackgroundColor;
            h.BackgroundColor = [.2 1 .2];
            drawnow
            play(obj.CurrentSGObj);
            h.BackgroundColor = c;
        end
        
        
        function update_signal_plot(obj,src,event)
            obj.CurrentSGObj.update_signal;
            h = obj.handles.SignalPlotLine;
            h.XData = obj.CurrentSGObj.Time;
            h.YData = obj.CurrentSGObj.Signal;
        end
        
        
        
        function sobj = get.CurrentSGObj(obj)
            st = obj.handles.TabGroup.SelectedTab;
            ind = ismember(obj.sgTypes,st.Title);
            sobj = obj.sgObjs{ind};
        end
        
        function update_samplerate(obj,src,event)
            for i = 1:length(obj.sgObjs)
                obj.sgObjs{i}.Fs = event.Value;
            end
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
            g.RowHeight   = {150,'1x',25};
            
            
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
            tg.Layout.Row    = 2;
            tg.Tag = 'StimGenTabs';
            tg.TabLocation = 'left';
            tg.SelectionChangedFcn = @obj.stimtype_changed;
            obj.handles.TabGroup = tg;
            
            flag = 1;
            for i = 1:length(obj.sgTypes)
                try
                    sgt = obj.sgTypes{i};
                    sgo = obj.sgObjs{i};
                    fnc = @sgo.create_gui;
                    t = uitab(tg,'Title',sgt,'CreateFcn',fnc);
                    t.Scrollable = 'on';
                    addlistener(sgo,'Signal','PostSet',@obj.update_signal_plot);
                    if flag, obj.update_signal_plot; flag = 0; end
                catch me
                    t.Title = sprintf('%s ERROR',sgt);
                    disp(me)
                end
            end
            
%             % sample rate
%             h = uieditfield(g,'numeric','Tag','SampleRate');
%             h.Layout.Row = 3;
%             h.Layout.Column = 1;
%             h.Limits = [1 1e6];
%             h.ValueDisplayFormat = '%.3f Hz';
%             h.Value = 48828.125;
%             h.ValueChangedFcn = @obj.update_samplerate;
            
            % play stim
            h = uibutton(g,'Tag','Play');
            h.Layout.Row = 3;
            h.Layout.Column = 2;
            h.Text = 'Play Stim';
            h.ButtonPushedFcn = @obj.play_current_stim_audio;
            obj.handles.PlayStimAudio = h;
            
            
            
            % side-bar grid
            sbg = uigridlayout(g);
            sbg.Layout.Column = 3;
            sbg.Layout.Row = [1 3];
            sbg.ColumnWidth = {'1x', '1x'};
            sbg.RowHeight = repmat({30},1,9);
            
            R = 1;
            
            % stimulus counter
            h = uilabel(sbg);
            h.Layout.Column = [1 2];
            h.Layout.Row = R;
            h.Text = '---';
            h.FontSize = 18;
            h.FontWeight = 'bold';
            obj.handles.StimulusCounter = h;
            
            R = R + 1;
            
            % stim name field
            h = uilabel(sbg);
            h.Layout.Column = 1;
            h.Layout.Row = R;
            h.Text = 'Stim Name:';
            h.HorizontalAlignment = 'right';
            h.FontSize = 16;
            obj.handles.StimulusCounter = h;
            
            h = uieditfield(sbg,'Tag','StimName');
            h.Layout.Column = 2;
            h.Layout.Row = R;
            h.Value = '';
            obj.handles.StimName = h;
            
            R = R + 1;            
            
            % inter-stimulus interval
            h = uilabel(sbg,'Text','ISI');
            h.Layout.Column = 1;
            h.Layout.Row = R;
            h.HorizontalAlignment = 'right';
            obj.handles.ISILabel = h;
            
            h = uieditfield(sbg,'Tag','ISI');
            h.Layout.Column = 2;
            h.Layout.Row = R;
            h.Value = '1.00';
            h.ValueChangedFcn = @obj.update_isi;
            obj.handles.ISI = h;
            
            R = R + 1;
            
            % rep field
            h = uieditfield(sbg,'numeric','Tag','Reps');
            h.Layout.Column = 1;
            h.Layout.Row = R;
            h.Limits = [1 1e6];
            h.RoundFractionalValues = 'on';
            h.ValueDisplayFormat = '%d reps';
            h.Value = 20;
            obj.handles.Reps = h;
                        

            % add stim button
            h = uibutton(sbg,'Tag','AddStimToList');
            h.Layout.Column = 2;
            h.Layout.Row = R;
            h.Text = 'Add';
            h.FontSize = 16;
            h.FontWeight = 'bold';
            h.ButtonPushedFcn = @obj.add_stim_to_list;
            obj.handles.AddStimToList = h;
            
            R = R + 1;
            
            % stimulus list
            h = uilistbox(sbg,'Tag','StimObjList');
            h.Layout.Column = [1 2];
            h.Layout.Row = [R R+2];
            h.Items = {};
            obj.handles.StimObjList = h;
            
            R = R + 3;            
            
            % playmode dropdown
            h = uidropdown(sbg,'Tag','PlayMode');
            h.Layout.Column = [1 2];
            h.Layout.Row = R;
            h.Items = ["Normal" "Shuffle" "Blockwise"];
            h.ValueChangedFcn = @obj.update_playmode;
            obj.handles.ShuffleList = h;
            
            
            R = R + 1;
            
            % run/stop/pause buttons
            h = uibutton(sbg);
            h.Layout.Column = 1;
            h.Layout.Row = R;
            h.Text = 'Run';
            h.FontSize = 18;
            h.FontWeight = 'bold';
            h.ButtonPushedFcn = @obj.playback_control;
            h.Enable = 'on';
            obj.handles.RunStopButton = h;
            
            h = uibutton(sbg);
            h.Layout.Column = 2;
            h.Layout.Row = R;
            h.Text = 'Pause';
            h.FontSize = 18;
            h.FontWeight = 'bold';
            h.ButtonPushedFcn = @obj.playback_control;
            h.Enable = 'off';
            obj.handles.PauseButton = h;
            
            
        end
    end
end