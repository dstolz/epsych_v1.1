classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected)
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
    
    properties (Dependent)
        ActiveX
    end
    
    properties (SetAccess = protected, Hidden)
        handles
    end
    
    methods (Abstract)
        run_calibration(obj)
        
    end
    
    methods
        function obj = StimCalibration(parent)
            if nargin >= 1, obj.handles.parent = parent; end
            
            obj.create_gui;
        end
        
        function plot_signal(obj,type,ax)
            
        end
        
        function plot_amp_spectrum(obj,type,ax)
            
        end
        
        function plot_phase_spectrum(obj,type,ax)
            
        end
        
        
        
        function ax = get.ActiveX(obj)
            global AX
            ax = AX;
        end
        
        
        function create_gui(obj)
            if isempty(obj.parent)
                obj.handles.parent = uifigure;
            end
            
            parent = obj.handles.parent;
            
            g = uigridlayout(parent);
            
            g.ColumnWidth = {'1x',200};
            g.RowHeight   = {'1x','1x'};
            
            obj.handles.MainGrid = g;
            
            % Excitation signal axis
            ax = uiaxes(parent);
            ax.Layout.Column = 1;
            ax.Layout.Row    = 1;
            obj.handles.axExcitationSignal = ax;
            
            % Response signal axis
            ax = uiaxes(parent);
            ax.Layout.Column = 1;
            ax.Layout.Row    = 1;
            obj.handles.axResponseSignal = ax;
            
            
            % Sidebar grid
            sg = uigridlayout(g);
            sg.Layout.Column = 2;
            sg.Layout.Row = [1 2];
            
            obj.handles.SideGrid = sg;
            
            % select stimulus type (from list of stimgen types) - dropdown
            types = stimgen.StimType.list;
            
            
            % calibration mode (CalibrationMode): rms or peak

            % reference sound level (numeric)
            % reference frequency (numeric)
            
            % measure mic sensitivty (button)
            
            % reference mic sensitivty (numeric) ReferenceMicSensitivity
            %   - either explicitly specified by user or result of
            %   measurement
            
            %
            
            
            
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
    
    