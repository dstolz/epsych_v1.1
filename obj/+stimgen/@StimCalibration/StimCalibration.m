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
        
        CalibrationTimestamp (1,1) string = "unknown"
        
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
    
    properties (SetAccess = private)
        Fs
    end
    
    properties (SetAccess = protected, Hidden)
        handles
    end
    
    properties (SetAccess = immutable)
        ActiveX
    end
    
    methods
        gui(obj);
        calibrate_clicks(obj,clickdur);
        calibrate_tones(obj,freqs);
        
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
        
        
        
        function plot_signal(obj,ax)
            figure(999);
            
            subplot(211)
            plot(obj.Time,obj.ResponseSignal);
            grid on
            xlabel('time (sec)');
            ylabel('V');
            
        end
        
        function plot_spectrum(obj,ax)
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
        
        function set_prop(obj,src,event)
            obj.(src.Tag) = event.Value;
        end
        
        
        
        function set.MicSensitivity(obj,r)
            if ~isempty(obj.handles)
                obj.handles.MicSensitivity.Value = r;
            end
            obj.MicSensitivity = r;
        end
        
        
        function set.ReferenceLevel(obj,r)
            if ~isempty(obj.handles)
                obj.handles.ReferenceLevel.Value = r;
            end
            obj.ReferenceLevel = r;
        end
        
        function set.ReferenceFrequency(obj,r)
            if ~isempty(obj.handles)
                obj.handles.ReferenceFrequency.Value = r;
            end
            obj.ReferenceFrequency = r;
        end
        
        
        function set.NormativeValue(obj,r)
            if ~isempty(obj.handles)
                obj.handles.NormativeValue.Value = r;
            end
            obj.NormativeValue = r;
        end
        
        
        
        function calibration_state(obj,src,event)
            h = obj.handles;
            hen = findobj(h.parent,'-property','Enable');
                        
            
            switch obj.STATE
                case "IDLE"
                    set(hen,'Enable','on');
                    h.RefMeasure.Text = 'Measure Reference';
                    h.RunCalibration.Text = 'Calibrate';
                    h.RunCalibration.BackgroundColor = h.parent.BackgroundColor;

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
                    
                    % convert to voltage/Pascal
                    dv = 10^((obj.ReferenceLevel-94)./20);
                    obj.MicSensitivity = r./dv;
                    vprintf(1,'Mic sensitivity = %.4f V @ %.1f dB SPL = %.4f V/Pa', ...
                        r,obj.ReferenceLevel,obj.MicSensitivity)
                    
                    set(hen,'Enable','on');
                    h.RefMeasure.Text = 'Measure Reference';
                    
                    obj.STATE = "IDLE";
                    
                    
                case "CALIBRATE"
                    set(hen,'Enable','off');
                    h.RunCalibration.Enable = 'on';
                    h.RunCalibration.Text = 'Stop';
                    drawnow
                    
                    try
                        
                        calibrate_clicks(obj,clickdur);
                        
                        calibrate_tones(obj,freqs);
                        
                        create_arbmag(obj);
                        
                        obj.CalibrationTimestamp = datestr(now);
                        
                        h.MenuSaveCalibration.Enable = 'on';
                        
                    catch me
                        vprintf(0,2,'An error occurded during calibration')
                        set(hen,'Enable','on');
                        h.RunCalibration.Text = {'CALIBRATION','ERROR'};
                        h.RunCalibration.BackgroundColor = 'r';
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
        
        
        function load_calibration(obj,ffn)
            
            if nargin < 2 || isempty(ffn)
                pn = getpref('StimCalibration','path',cd);
                [fn,pn] = uigetfile({'*.sgc','StimCalibration (*.sgc)'},pn);
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
                
                setpref('StimCalibration','path',pn);
            end

            f = ancestor(obj.handles.parent,'figure');
            
            figure(f);
            
            s = load(ffn,'-mat');
            
            obj.CalibrationData     = s.obj.CalibrationData;
            obj.NormativeValue      = s.obj.NormativeValue;
            obj.ReferenceLevel      = s.obj.ReferenceLevel;
            obj.ReferenceFrequency  = s.obj.ReferenceFrequency;
            obj.CalibrationTimestamp = s.obj.CalibrationTimestamp;
            
            calts = obj.CalibrationTimestamp;
            if isequal(calts,"")
                calts = "unknown";
            end
            vprintf(0,'Loaded calibration file from %s',calts)
        end
        
        function save_calibration(obj,ffn)
            if nargin < 2 || isempty(ffn)
                pn = getpref('StimCalibration','path',cd);
                [fn,pn] = uiputfile({'*.sgc','StimCalibration (*.sgc)'},pn);
                if isequal(fn,0), return; end
                
                ffn = fullfile(pn,fn);
                
                
                [~,~,ext] = fileparts(ffn);
                if ~isequal(ext,'.sgc')
                    ffn = [ffn '.sgc'];
                end
                
                save(ffn,'obj');
                
                setpref('StimCalibration','path',pn);
                
                f = ancestor(obj.handles.parent,'figure');
                
                figure(f);
                
                vprintf(0,'Saved Calibration to: "%s"',ffn)
            end
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
    
    