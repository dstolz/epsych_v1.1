classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected,SetObservable,AbortSet)
        StimTypeObj         (1,1)
        
        ExcitationSignal    (1,:) single
        ResponseSignal      (1,:) single
        
        ReferenceLevel      (1,1) double {mustBeFinite,mustBePositive} = 94; % dBSPL
        ReferenceFrequency  (1,1) double {mustBeFinite,mustBePositive} = 1000; % Hz
        ReferenceSignal     (1,:) single
        
        MicSensitivity      (1,1) double {mustBeFinite,mustBePositive} = 1; % V/Pa
        
        CalibrationMode     (1,1) string {mustBeMember(CalibrationMode,["rms","peak","specfreq"])} = "rms";
        
        CalibrationTimestamp (1,1) string
        
        ResponseTHD
        
        CalibratedLUT
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
                        vprintf(1,'Measuring microphone response')
                        r = obj.calibrate;
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
                        so = stimgen.ClickTrain;
                        so.Fs = obj.Fs;
                        so.WindowFcn = "";
                        obj.CalibrationMode = "peak";
                        m = nan(size(clickdur));
                        for i = 1:length(clickdur)
                            vprintf(1,'Calibrating click of duration = %.2 μs - %d/%d',clickdur(i)*1e6i,length(clickdur));
                            so.ClickDuration = clickdur(i);
                            so.update_signal;                            
                            m(i) = obj.calibrate(so.Signal);
                        end
                        obj.CalibratedLUT.click = [clickdur(:) m(:)];
                        
                        freqs = 100.*2.^(0:1/16:9);
                        so = stimgen.Tone;
                        so.Fs = obj.Fs;
                        so.Duration = 0.2;
                        obj.CalibrationMode = "specfreq";
                        m = nan(size(freqs));
                        for i = 1:length(freqs)
                            vprintf(1,'Calibrating tone frequency = %.2f Hz - %d/%d',freqs(i),i,length(freqs))
                            so.Frequency = freqs(i);
                            so.WindowDuration = 2./freqs(i);
                            so.update_signal;                            
                            m(i) = obj.calibrate(so.Signal);
                        end
                        obj.CalibratedLUT.tone = [freqs(:) m(:)];
                        
                        % TODO: Compute arbitrary magnitude filter for
                        % non-LUT stimuli
                        % see designfilt('arbmagfir', ...)

                        
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
        
        
        function r = calibrate(obj,signal)
            acqonly = nargin < 2 || isempty(signal);
                        
            
            if acqonly
                obj.ExcitationSignal = zeros(1,obj.Fs.*1); % one second acquistion
            else
                obj.ExcitationSignal = signal;
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
            
                        
            % calculate metric to return
            switch obj.CalibrationMode
                case "rms"
                    r = sqrt(mean(y.^2));
                case "peak"
                    r = max(abs(y));
                case "specfreq"
                    r = obj.spectral_rms(y,obj.StimTypeObj.Frequency,obj.Fs);
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
        
    end
end
    
    