classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected,SetObservable,AbortSet)
        StimTypeObj         (1,1)
        
        ExcitationSignal    (1,:) single
        ResponseSignal      (1,:) single
        
        ReferenceLevel      (1,1) double {mustBeFinite,mustBePositive} = 94; % dBSPL
        ReferenceFrequency  (1,1) double {mustBeFinite,mustBePositive} = 1000; % Hz
        ReferenceSignal     (1,:) single
        
        MicSensitivity      (1,1) double {mustBeFinite,mustBePositive} = 1; % V/Pa
        
        CalibrationMode     (1,1) string {mustBeMember(CalibrationMode,["rms","peak"])} = "rms";
        
        CalibrationTimestamp (1,1) string
        
        ResponseTHD
        
        ResponseFilter
    end
    
    properties (SetAccess = private, SetObservable, AbortSet)
        STATE (1,1) string {mustBeMember(STATE,["IDLE","REFERENCE","CALIBRATE"])} = "IDLE";
    end
    
    properties (Dependent)
        ActiveX
        Fs
    end
    
    properties (SetAccess = protected, Hidden)
        handles
    end
    
    
    methods
        function obj = StimCalibration(parent)
            if nargin >= 1
                obj.handles.parent = parent;
            else
                obj.handles.parent = [];
            end
            
            obj.create_gui;
            
            addlistener(obj,'STATE','PostSet',@obj.gui_state);
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_signal);
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_spectrum);
            
            obj.ResponseFilter = designfilt('highpassfir', ...
                'StopbandFrequency',50, ...     % Frequency constraints
                'PassbandFrequency',100, ...
                'StopbandAttenuation',20, ...    % Magnitude constraints
                'PassbandRipple',.1, ...
                'DesignMethod','equiripple', ...  % Design method
                'SampleRate',obj.Fs);              % Sample rate
        end
        
        
        
        function plot_signal(obj,type,ax)
            
        end
        
        function plot_spectrum(obj,type,ax)
            
        end
        
        
        
        function fs = get.Fs(obj)
            fs = obj.AX.GetSFreq;
        end
        
        function ax = get.ActiveX(obj)
            global AX
            
            if isempty(AX)
                error('stimgen:StimCalibration:ActiveX:DoesNotExist', ...
                    'The global variable, ''AX'', should point to a RPco.X ActiveX object')
            end
            ax = AX;
        end
        
        
        
        
        
        function create_gui(obj)
            if isempty(obj.handles.parent)
                h = uifigure;
                pos = getpref('StimCalibration','pos',[400 250 300 420]);
                h.Position = pos;
                obj.handles.parent = h;
            end
            
            parent = obj.handles.parent;
            
            
            movegui(parent,'onscreen')
            
            % Sidebar grid
            sg = uigridlayout(parent);
            sg.ColumnWidth = {'1x' '1x'};
            sg.RowHeight   = [repmat({30},1,7) {100}];
            sg.Scrollable = 'on';
            obj.handles.SideGrid = sg;
            
            R = 1;
            
            % calibration mode (CalibrationMode): rms or peak
            h = uilabel(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Calibration Mode:";
            h.HorizontalAlignment = 'right';
            
            h = uidropdown(sg);
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.Items = ["RMS" "Peak"];
            h.ItemsData = ["rms", "peak"];
            obj.handles.CalibrationMode = h;

            R = R + 1;

            % reference sound level (numeric)
            h = uilabel(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Ref. Sound Level:";
            h.HorizontalAlignment = 'right';
            
            h = uieditfield(sg,'numeric');
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.ValueDisplayFormat = '%.1f dB SPL';
            h.Value = obj.ReferenceLevel;
            h.Limits = [1 160];
            obj.handles.RefSoundLevel = h;
            
            R = R + 1;

                        
%             % reference frequency (numeric)
%             h = uilabel(sg);
%             h.Layout.Column = 1;
%             h.Layout.Row    = R;
%             h.Text = "Ref. Frequency:";
%             h.HorizontalAlignment = 'right';
%             
%             h = uieditfield(sg,'numeric');
%             h.Layout.Column = 2;
%             h.Layout.Row    = R;
%             h.ValueDisplayFormat = '%.1f Hz';
%             h.Value = 1000;
%             h.Limits = [100 100000];
%             obj.handles.RefFrequency = h;
%             
%             R = R + 1;
            
            % measure mic sensitivty (button)
            h = uibutton(sg);
            h.Layout.Column = [1 2];
            h.Layout.Row    = R;
            h.Text = 'Measure Reference';
            h.ButtonPushedFcn = @obj.measure_ref;
            obj.handles.RefMeasure = h;
            
            R = R + 1;
            
            % reference mic sensitivty (numeric) MicSensitivity
            %   - either explicitly specified by user or result of
            %   measurement
            h = uilabel(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Mic. Sensitivity:";
            h.HorizontalAlignment = 'right';
            
            h = uieditfield(sg,'numeric');
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.ValueDisplayFormat = '%.1f V/Pa';
            h.Limits = [.1 10];
            obj.handles.MicSensitivity = h;
            
            R = R + 1;
%             
%             % StimType
%             h = uibutton(sg);
%             h.Layout.Column = 1;
%             h.Layout.Row    = R;
%             h.Text = 'Parameterize';
%             h.ButtonPushedFcn = @obj.parameterize_stimtype;
%             obj.handles.Parameterize = h;
%             
%             stlist = stimgen.StimType.list;
%             
%             h = uidropdown(sg);
%             h.Layout.Column = 2;
%             h.Layout.Row    = R;
%             h.Items = stlist;         
%             
            
            R = R + 1;
            
            
            % run calibration
            h = uibutton(sg);
            h.Layout.Column = [1 2];
            h.Layout.Row = [R R+1]; R = R + 1;
            h.Text = {'Run'; 'Calibration'};
            h.FontSize = 18;
            h.FontWeight = 'bold';
            
            h.ButtonPushedFcn = @obj.run_calibration;
            obj.handles.RunCalibration = h;
            
            
            
            % Toolbar
            %  save calibration file
            %  load calibration file
            
            
            obj.STATE = "IDLE";
            
            
        end
        
%     end
%     
%     methods (Access = protected)
        
        function gui_state(obj,src,event)
            h = obj.handles;
            hen = findobj(h.parent,'-property','Enable');
                        
            
            switch obj.STATE
                case "IDLE"
                    set(hen,'Enable','on');
                    h.RefMeasure.Text = 'Measure Reference';
                    h.RunCalibration.Text = 'Calibrate';

                case "REFERENCE"
                    set(hen,'Enable','off');
                    h.RefMeasure.Enable = 'on';
                    h.RefMeasure.Text = 'Stop';
                    drawnow
                    
                    obj.MicSensitivity = nan;
                    try
                        obj.CalibrationMode = "rms";
                        vprintf(1,'Measuring microphone response')
                        r = obj.calibrate(true);
                        obj.MicSensitivity = r;
                        h.RefMeasure.Text = 'Measure Reference';
                    catch me
                        set(hen,'Enable','on');
                        vprintf(0,2,'An error occurded during referencing')
                        h.RefMeasure.Text = 'REFERENCING ERROR';
                        rethrow(me);
                    end
                    
                    h.MicSensitivity.Value = r;
                    
                    set(hen,'Enable','on');
                    h.RefMeasure.Text = 'Measure Reference';
                    
                    
                case "CALIBRATE"
                    set(hen,'Enable','off');
                    h.RunCalibration.Enable = 'on';
                    h.RunCalibration.Text = 'Stop';
                    drawnow
                    
                    try
                        clickdur = 2.^(0:11)./obj.Fs;
                        obj.StimTypeObj = stimgen.ClickTrain;
                        obj.StimTypeObj.Fs = obj.Fs;
                        obj.StimTypeObj.WindowFcn = "";
                        for i = 1:length(clickdur)
                            obj.StimTypeObj.ClickDuration = clickdur(i);
                            vprintf(1,'Calibrating click of duration = %.2 μs',clickdur(i)*1e6);
                            m(i) = obj.calibrate;
                        end
                        
                        
                        
                    catch me
                        vprintf(0,2,'An error occurded during calibration')
                        set(hen,'Enable','on');
                        h.RunCalibration.Text = {'CALIBRATION','ERROR'};
                        rethrow(me);
                    end
                    set(hen,'Enable','on');
                    h.RunCalibration.Text = 'Calibrate';
                    
                    
            end
            
            drawnow
        end
        
        
        function measure_ref(obj,src,event)
            if obj.STATE == "REFERENCE"
                obj.STATE = "IDLE";
            else
                obj.STATE = "REFERENCE";
            end
        end
        
        
        function run_calibration(obj,src,event)
            if obj.STATE == "CALIBRATE"
                obj.STATE = "IDLE";
            else
                obj.STATE = "CALIBRATE";
            end
        end
        
        
        function r = calibrate(obj,acqonly)
            if nargin < 2 || isempty(acqonly), acqonly = false; end
                        
            
            if acqonly
                obj.ExcitationSignal = zeros(1,obj.Fs.*1); % one second acquistion
            else
                % TODO: create calibration signal for each stimtype
                obj.StimTypeObj.Fs = obj.Fs;
                obj.StimTypeObj.update_signal;
                
                obj.ExcitationSignal = obj.StimTypeObj.Signal;
            end
                        
            nsamps = length(obj.ExcitationSignal);
            
            % update buffer
            obj.AX.SetTagVal('BufferSize',nsamps);
            obj.AX.SetTagVal('BufferData',obj.ExcitationSignal);
            
            
            % trigger playback/recording
            obj.AX.SetTagVal('!Trigger',1);
            pause(0.001);
            obj.AX.SetTagVal('!Trigger',0);
            
            % wait until the buffer is filled
            t = tic;
            timeout = nsamps / obj.Fs;
            bidx = obj.AX.GetTagVal('BufferIndex');
            while bidx < nsamps || toc(t) < timeout
                pause(0.05);
                bidx = obj.AX.GetTagVal('BufferIndex');
            end
            
            % download the acquired signal
            y = obj.AX.ReadTagV('BufferIn',0,nsamps-1);
            
            
            y = filter(obj.ResponseFilter,y);
            
            % calculate metric to return
            switch obj.CalibrationMode
                case "rms"
                    r = sqrt(mean(y.^2));
                case "peak"
                    r = max(abs(y));
            end
            
            obj.ResponseTHD = thd(y, obj.Fs);
            
            obj.ResponseSignal = y;
        end
    end
    
    methods (Static)
        
        function x = dBSPL2lin(y)
            x = 10^(y/20);
        end
        
        function y = lin2dBSPL(x,xref)            
            y = 20 .* log10(x/xref);
        end
        
    end
end
    
    