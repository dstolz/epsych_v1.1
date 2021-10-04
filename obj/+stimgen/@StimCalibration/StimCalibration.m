classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected,SetObservable,AbortSet)
        StimTypeObj         (1,1)
        
        ExcitationSignal    (1,:) double
        ResponseSignal      (1,:) double
        
        ReferenceLevel      (1,1) double {mustBeFinite,mustBePositive} = 94; % dBSPL
        ReferenceFrequency  (1,1) double {mustBeFinite,mustBePositive} = 1000; % Hz
        ReferenceSignal     (1,:) double
        
        MicSensitivity      (1,1) double = 1; % V/Pa
        
        CalibrationMode     (1,1) string {mustBeMember(CalibrationMode,["rms","peak","specfreq"])} = "rms";
        
        CalibrationTimestamp (1,1) string
        
        ResponseTHD
        
        CalibrationData
        
        NormativeValue      (1,1) {mustBePositive,mustBeFinite} = 80; % dB SPL
    end
    
    properties (SetAccess = private, SetObservable, AbortSet)
        STATE (1,1) string {mustBeMember(STATE,["IDLE","REFERENCE","CALIBRATE"])} = "IDLE";
    end
    
    properties (Dependent)
        Time
    end
    
    properties (SetAccess = protected, Hidden)
        handles
    end
    
    properties (SetAccess = immutable)
        ActiveX
        Fs
    end
    
    methods
        function obj = StimCalibration(parent)
            if nargin >= 1
                obj.handles.parent = parent;
            else
                obj.handles.parent = [];
            end
            
            
            global AX
            
            obj.ActiveX = AX;
            
            if ~isempty(AX)
                obj.Fs = obj.ActiveX.GetSFreq;
            end
        end
        
        
        
        function plot_signal(obj,type,ax)
            figure(999);
            
            subplot(211)
            plot(obj.Time,obj.ResponseSignal);
            grid on
            xlabel('time (sec)');
            ylabel('V');
            
        end
        
        function plot_spectrum(obj,type,ax)
            figure(999);
            
            subplot(212)
            n = length(obj.ResponseSignal);
            w = flattopwin(n);
            [pxx,f] = periodogram(obj.ResponseSignal,w,2^nextpow2(n),obj.Fs,'power');
            pxx = sqrt(pxx);
            f = f./1000;
            plot(f,obj.ReferenceLevel+20*log10(pxx/obj.MicSensitivity));
            grid on
            set(gca,'xscale','log')
            xlabel('frequency (kHz)');
            ylabel('level (dB SPL)');
            xlim([min(f) max(f)]);
        end
        
        function t = get.Time(obj)
            t = (0:length(obj.ResponseSignal)-1)./obj.Fs;
        end
        
        
        function set.ReferenceLevel(obj,r)
            obj.ReferenceLevel = r;
            obj.handles.RefSoundLevel.Value = r;
        end
        
        function r = get.ReferenceLevel(obj)
            if isfield(obj,'handles') && isfield(obj.handles,'RefSoundLevel')
                r = obj.handles.RefSoundLevel.Value;
            else
                r = obj.ReferenceLevel;
            end
        end
        
        
        function gui(obj)
            
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

                        
            % reference frequency (numeric)
            h = uilabel(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Ref. Frequency:";
            h.HorizontalAlignment = 'right';
            
            h = uieditfield(sg,'numeric');
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.ValueDisplayFormat = '%.1f Hz';
            h.Value = 1000;
            h.Limits = [100 100000];
            obj.handles.RefFrequency = h;
            
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
            h.ValueDisplayFormat = '%.3f V/Pa';
            h.Limits = [0 10];
            h.LowerLimitInclusive = 'off';
            obj.handles.MicSensitivity = h;
            
            R = R + 1;
            
            % measure mic sensitivty (button)
            h = uibutton(sg);
            h.Layout.Column = [1 2];
            h.Layout.Row    = R;
            h.Text = 'Measure Reference';
            h.ButtonPushedFcn = @obj.measure_ref;
            obj.handles.RefMeasure = h;
            
            R = R + 1;
            
            % Normative value
            h = uilabel(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Normative Sound Level:";
            h.HorizontalAlignment = 'right';
            
            h = uieditfield(sg,'numeric');
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.ValueDisplayFormat = '%d dB SPL';
            h.Value = obj.NormativeValue;
            h.Limits = [60 120];
            obj.handles.RefSoundLevel = h;
            
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
            
            
            
            addlistener(obj,'STATE','PostSet',@obj.calibration_state);
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_signal);
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_spectrum);
            
        end
        
        function calibration_state(obj,src,event)
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
                        obj.CalibrationMode = "specfreq";
                        so = stimgen.Tone;
                        so.Fs = obj.Fs;
                        so.Duration = 1;
                        so.Frequency = obj.ReferenceFrequency;
                        obj.StimTypeObj = so;
                        vprintf(1,'Measuring microphone response')
                        r = obj.calibrate;
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
                    
                    obj.STATE = "IDLE";
                    
                    
                case "CALIBRATE"
                    set(hen,'Enable','off');
                    h.RunCalibration.Enable = 'on';
                    h.RunCalibration.Text = 'Stop';
                    drawnow
                    
                    try
                        clickdur = 2.^(0:7)./obj.Fs;
                        so = stimgen.ClickTrain;
                        so.Fs = obj.Fs;
                        so.Duration = 0.05;
                        so.Rate = 1;
                        so.WindowFcn = "";
                        so.OnsetDelay = 0.025;
                        obj.StimTypeObj = so;
                        obj.CalibrationMode = "peak";
                        m = nan(size(clickdur));
                        for i = 1:length(clickdur)
                            vprintf(1,'Calibrating click of duration = %.2f μs (%d/%d)', ...
                                clickdur(i)*1e6,i,length(clickdur));
                            so.ClickDuration = clickdur(i);
                            so.update_signal;                            
                            m(i) = obj.calibrate(so.Signal);
                        end
                        obj.CalibrationData.click = [clickdur(:) m(:)];
                        
                        freqs = 100.*2.^(0:1/16:12);
                        freqs(freqs>obj.Fs*.45) = [];
                        so = stimgen.Tone;
                        so.Fs = obj.Fs;
                        so.Duration = 0.1;
                        obj.StimTypeObj = so;
                        obj.CalibrationMode = "specfreq";
                        m = nan(size(freqs));
                        for i = 1:length(freqs)
                            vprintf(1,'Calibrating tone frequency = %.2f Hz (%d/%d)',freqs(i),i,length(freqs))
                            so.Frequency = freqs(i);
                            so.WindowDuration = 4./freqs(i);
                            so.update_signal;                            
                            m(i) = obj.calibrate(so.Signal);
                        end
                        obj.CalibrationData.tone = [freqs(:) m(:)];
                        
                        % TODO: Compute arbitrary magnitude filter for
                        % non-LUT stimuli
                        % see designfilt('arbmagfir', ...)

                        obj.CalibrationTimestamp = datestr(now);
                        
                    catch me
                        vprintf(0,2,'An error occurded during calibration')
                        set(hen,'Enable','on');
                        h.RunCalibration.Text = {'CALIBRATION','ERROR'};
                        rethrow(me);
                    end
                    set(hen,'Enable','on');
                    h.RunCalibration.Text = 'Calibrate';
                    
                    obj.STATE = "IDLE";
            end
            
            drawnow
        end
        
        
        
        function s = saveobj(obj)
            s.CalibrationData  = obj.CalibrationData;
            s.NormativeValue = obj.NormativeValue;
            s.ReferenceLevel = obj.ReferenceLevel;
            s.ReferenceFrequency = obj.ReferenceFrequency;
            s.CalibrationTimestamp = obj.CalibrationTimestamp;
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
        
        
        function r = calibrate(obj,signal)
            acqonly = nargin < 2 || isempty(signal);
                        
            
            if acqonly
                obj.ExcitationSignal = zeros(1,round(obj.Fs.*1)); % one second acquistion
            else
                obj.ExcitationSignal = signal;
            end
                        
            nsamps = length(obj.ExcitationSignal)-1;
            
            % update buffer
            obj.ActiveX.SetTagVal('BufferSize',nsamps);
            s=obj.ActiveX.WriteTagV('BufferOut',0,double(signal));
            if ~s
                warning('StimCalibration:calibrate:RPvdsFail','Failed to write BufferOut to circuit')
            end
            
            
            % trigger playback/recording
            obj.ActiveX.SetTagVal('!Trigger',1);
            pause(0.001);
            obj.ActiveX.SetTagVal('!Trigger',0);
            
            % wait until the buffer is filled
            t = tic;
            timeout = nsamps / obj.Fs;
            bidx = obj.ActiveX.GetTagVal('BufferIndex');
            while toc(t) < timeout || bidx < nsamps && bidx > 0
                pause(0.05);
                bidx = obj.ActiveX.GetTagVal('BufferIndex');
            end
            
            % download the acquired signal
            y = obj.ActiveX.ReadTagV('BufferIn',0,nsamps-1);
            
                        
            % calculate metric to return
            switch obj.CalibrationMode
                case "rms"
                    r = sqrt(mean(y.^2));
                case "peak"
                    r = max(abs(y));
                case "specfreq"
                    r = obj.spectral_rms(y,obj.StimTypeObj.Frequency,obj.Fs);
            end
            
            if acqonly
                obj.MicSensitivity = r;
            end
            
            obj.ResponseSignal = y;
            
            obj.ResponseTHD = thd(y, obj.Fs);
        end
        
        
        
    end
    
    methods (Static)
        
        function p = spectral_rms(x,freq,fs)
            n = length(x);
            w = flattopwin(n);
            [pxx,f] = periodogram(x,w,2^nextpow2(n),fs,'power');
            [~,idx] = min((f-freq).^2); % find nearest frequency bin to freq
            p = sqrt(pxx(idx));
        end
        
        function x = dBSPL2lin(y)
            x = 10^(y/20);
        end
        
        function y = lin2dBSPL(x,xref)            
            y = 20 .* log10(x/xref);
        end
        
        
        function h = launch_gui
            h = stimgen.StimCalibration;
            h.gui;
        end
        
        
        function obj = loadobj(s)
            if isstruct(s)
                obj = stimgen.StimCalibration;
                obj.CalibrationData  = s.CalibrationData;
                obj.NormativeValue = s.NormativeValue;
                obj.ReferenceLevel = s.ReferenceLevel;
                obj.ReferenceFrequency = s.ReferenceFrequency;
                obj.CalibrationTimestamp = s.CalibrationTimestamp;
            else
                obj = s;
            end
        end
    end
end
    
    