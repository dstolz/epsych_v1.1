classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected,SetObservable,AbortSet)
        StimTypeObj         (1,1)
        
        ExcitationSignal    (1,:) single
        ResponseSignal      (1,:) single
        
        ReferenceLevel      (1,1) double {mustBeFinite,mustBePositive} = 94; % dBSPL
        ReferenceFrequency  (1,1) double {mustBeFinite,mustBePositive} = 1000; % Hz
        ReferenceSignal     (1,:) single
        
        ReferenceMicSensitivity (1,1) double {mustBeFinite,mustBePositive} = 1; % V/Pa
        
        CalibrationMode     (1,1) string {mustBeMember(CalibrationMode,["rms","peak"])} = "rms";
        
        CalibrationTimestamp (1,1) string
        
        ResponseTHD
    end
    
    properties (SetAccess = private)
        Fs
    end
    
    properties (Dependent)
        ActiveX
    end
    
    properties (SetAccess = protected, Hidden)
        handles
    end
    
    methods
        
    end
    
    methods
        function obj = StimCalibration(parent)
            if nargin >= 1
                obj.handles.parent = parent;
            else
                obj.handles.parent = [];
            end
            
            obj.create_gui;
            
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_signal);
            addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_spectrum);
        end
        
        
        
        function plot_signal(obj,type,ax)
            
        end
        
        function plot_spectrum(obj,type,ax)
            
        end
        
        
        
        
        function ax = get.ActiveX(obj)
            global AX
            ax = AX;
        end
        
        
        function run_calibration(obj,acqonly)
            if nargin < 2 || isempty(acqonly), acqonly = false; end
            
            obj.Fs = obj.AX.GetSFreq;
            
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
            
            obj.ResponseSignal = obj.AX.ReadTagV('BufferIn',0,nsamps-1);
            
            
        end
        
        
        function measure_ref(obj,src,event)
            
        end
        
        function stimtype_change(obj,src,event)
            % obj.StimTypeObj
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
            sg.RowHeight   = [repmat({30},1,7) {'1x'}];
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
            
            
            % measure mic sensitivty (button)
            h = uibutton(sg);
            h.Layout.Column = [1 2];
            h.Layout.Row    = R;
            h.Text = 'Measure Reference';
            h.ButtonPushedFcn = @obj.measure_ref;
            obj.handles.RefMeasure = h;
            
            R = R + 1;
            % reference mic sensitivty (numeric) ReferenceMicSensitivity
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
            obj.handles.RefFrequency = h;
            
            R = R + 1;
            
            
            
            % select stimulus type (from list of stimgen types) - dropdown
            h = uibutton(sg);
            h.Layout.Column = 1;
            h.Layout.Row    = R;
            h.Text = "Parameterize";
            h.HorizontalAlignment = 'right';
            
            types = stimgen.StimType.list;
            h = uidropdown(sg);
            h.Layout.Column = 2;
            h.Layout.Row    = R;
            h.Items = types;
            h.ValueChangedFcn = @obj.stimtype_change;
            obj.handles.StimType = h;
            
            R = R + 1;
            
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
            
            
            
            
            
            
        end
        
    end
    
    methods (Static)
        
        function x = dBSPL_2_lin(y)
            x = 10^(y/20);
        end
        
        function y = lin_2_dBSPL(x,xref)            
            y = 20 .* log10(x/xref);
        end
        
    end
end
    
    