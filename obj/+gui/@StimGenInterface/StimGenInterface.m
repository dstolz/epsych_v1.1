classdef StimGenInterface < handle & gui.Helper
    
    properties
        StimPlayObjs (:,1) stimgen.StimPlay
    end
    
    properties (SetAccess = private)
        parent
        handles
        sgTypes
        sgObjs
        CurrentSignal
        
        StimRepsRemaining (:,1) double {mustBeInteger} = 0;
        
        FileLoaded (1,1) string
        
        Timer
        
        timeObj = tic;
        
    end
    
    properties (Access = private)
        els
    end
    
    properties (Dependent)
        CurrentSGObj
    end
    
    methods
        
        function obj = StimGenInterface(parent,ffn)
            global AX
            
            obj.TDTActiveX = AX;
            
            if nargin > 0, obj.parent = parent; end
            
            
            % get a list of available stimgen objects
            obj.sgTypes = stimgen.StimType.list;
            
            obj.sgObjs = cellfun(@(a) stimgen.(a),obj.sgTypes,'uni',0);
            
            obj.create;
            
            if nargin > 1 && ~isempty(ffn)
                obj.load_config(ffn);
            end
            
            if nargout == 0, clear obj; end
        end
        
        
        function delete(obj)
            
        end
        
        function trigger_stim_playback(obj)
            AX = obj.TDTActiveX;
            
            s(1) = AX.SetTagVal('!Trigger',1);
            obj.timeObj = tic;
            pause(0.001);
            s(2) = AX.SetTagVal('!Trigger',0);
            
            if ~all(s)
                warning('StimGenInterface:update_buffer:RPvdsFail','Failed to trigger Stim buffer')
            end
        end
        
        function update_buffer(obj)
            AX = obj.TDTActiveX;
            
            Buffer = obj.CurrentSignal;
            
            % write constructed Stim to RPvds circuit buffer
            nSamps = length(Buffer);
            AX.SetTagVal('BufferSize',nSamps);
            s = AX.WriteTagV('Stim',0,Buffer);
            if ~s
                warning('StimGenInterface:update_buffer:RPvdsFail','Failed to write Stim buffer')
            end
        end
        
        function timer_startfcn(obj,src,event)
            
            idx = obj.nextSPOIdx;
            obj.CurrentSignal = obj.StimPlayObjs(idx);
            
            obj.update_buffer;
            
            obj.trigger_stim_playback;
        end
        
        
        function timer_runtimefcn(obj,src,event)
            stimOn = obj.getParamVals(obj.TDTActiveX,'StimOn');
            
            if ~stimOn % wait until current buffer is finished playing to write the next
                % SHOULD WE USE A DOUBLE BUFFER??? PROBABLY
                
            end
            
            if toc(obj.timeObj) - isi < 2*src.Period
                if 
                return
            end
            
            while toc(obj.timeObj) - isi < 0, end
            
            idx = obj.nextSPOIdx;
            obj.CurrentSignal = obj.StimPlayObjs(idx);
            
            obj.update_buffer;
            
            obj.trigger_stim_playback;
        end
        
        function timer_stopfcn(obj,src,event)
        end
        
        function playback_control(obj,src,event)
            
            c = src.Text;
            
            switch lower(c)
                
                case 'run'
                    
                    t = timerfindall('Tag','StimGenInterfaceTimer');
                    if ~isempty(t)
                        stop(t);
                        delete(t);
                    end
                    t = timer('Tag','StimGenInterfaceTimer', ...
                        'Period',0.1, ...
                        'ExecutionMode', 'fixedRate',...
                        'BusyMode', 'drop', ...
                        'StartFcn',@obj.timer_startfcn, ...
                        'TimerFcn',@obj.timer_runtimefcn, ...
                        'StopFcn', @obj.timer_stopfcn);
                    
                    start(t);
                    
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
            
            obj.StimPlayObjs(end+1).StimObj = copy(obj.CurrentSGObj);
            obj.StimPlayObjs(end).Reps = n;
            obj.StimPlayObjs(end).Name = sn;
            obj.StimPlayObjs(end).ISI  = v;
                        
            
            h.StimObjList.Items     = [obj.StimPlayObjs.DisplayName];
            h.StimObjList.ItemsData = 1:length(h.StimObjList.Items);
        end
        
        function rem_stim_from_list(obj,src,event)
            h = obj.handles;
            
            ind = h.StimObjList.ItemsData == h.StimObjList.Value;
            
            obj.StimPlayObjs(ind) = [];
            
            h.StimObjList.Items     = [obj.StimPlayObjs.DisplayName];
            h.StimObjList.ItemsData = 1:length(obj.StimPlayObjs);
        end
        
        function stim_list_item_selected(obj,src,event)
            h = obj.handles;
            
            spo = obj.StimPlayObjs(event.Value);
                        
            ind = ismember(obj.sgTypes,spo.Type);
            
            co = copy(spo.StimObj);
            
            obj.sgObjs{ind} = co;
                        
            h.TabGroup.SelectedTab = h.Tabs.(spo.Type);
            
            tg = h.TabGroup;
            
            st = tg.SelectedTab;
            
            delete(st.Children);
            
            co.create_gui(st);
                        
            addlistener(co,'Signal','PostSet',@obj.update_signal_plot);

            obj.update_signal_plot;
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
        
        function load_config(obj,ffn)
            
            if nargin < 2 || isempty(ffn)
                pn = getpref('StimGenInterface','path',cd);
                [fn,pn] = uigetfile({'*.sgi','StimGenInterface Config (*.sgi)'},pn);
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
                
                setpref('StimGenInterface','path',pn);
            end

            f = ancestor(obj.parent,'figure');
            
            figure(f);
            
            warning('off','MATLAB:class:LoadInvalidDefaultElement');
            load(ffn,'SGI','-mat');
            warning('on','MATLAB:class:LoadInvalidDefaultElement');

            obj.StimPlayObjs = SGI;
            
            h = obj.handles;
            
            h.StimObjList.Items = [obj.StimPlayObjs.DisplayName];
            h.StimObjList.ItemsData = 1:length(h.StimObjList.Items);
            
            event.Value = 1;
            obj.stim_list_item_selected(h.StimObjList,event);
        end
        
        
        function save_config(obj,ffn)
            
            if nargin < 2 || isempty(ffn)
                pn = getpref('StimGenInterface','path',cd);
                [fn,pn] = uiputfile({'*.sgi','StimGenInterface Config (*.sgi)'},pn);
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
                
                setpref('StimGenInterface','path',pn);
            end
            
            SGI = obj.StimPlayObjs;
            
            [~,~,ext] = fileparts(ffn);
            if ~isequal(ext,'.sgi')
                ffn = [ffn '.sgi'];
            end
            
            save(ffn,'SGI','-mat');
            
            f = ancestor(obj.parent,'figure');
            
            figure(f);
            
            uialert(f, ...
                sprintf('Saved curent configuration to: "%s"',ffn), ...
                'StimGenInterface','Icon','success','Modal',true);
            
            obj.FileLoaded = string(ffn);
        end
        
    end % methods (Access = public)
    
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
            %movegui(f,'onscreen'); % do this after all gui components have loaded
            
            
            
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
                    obj.handles.Tabs.(sgt) = t;
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
            h.ValueChangedFcn = @obj.stim_list_item_selected;
            obj.handles.StimObjList = h;
            
            R = R + 3;            
            
            % remove stim button
            h = uibutton(sbg,'Tag','RemStimFromList');
            h.Layout.Column = 2;
            h.Layout.Row = R;
            h.Text = 'Remove';
            h.FontSize = 16;
            h.FontWeight = 'bold';
            h.ButtonPushedFcn = @obj.rem_stim_from_list;
            obj.handles.RemStimFromList = h;
            
            R = R + 1;
            
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
            
            
            
            % toolbar
            hf = uimenu(obj.parent,'Text','&File','Accelerator','F');
            
            h = uimenu(hf,'Tag','menu_Load','Text','&Load','Accelerator','L', ...
                'MenuSelectedFcn',@(~,~) obj.load_config);
            h = uimenu(hf,'Tag','menu_Save','Text','&Save','Accelerator','S', ...
                'MenuSelectedFcn',@(~,~) obj.save_config);



            
            movegui(f,'onscreen');
        end
        
    end
end