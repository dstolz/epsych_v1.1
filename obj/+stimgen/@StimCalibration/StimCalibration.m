classdef StimCalibration < handle & matlab.mixin.SetGet
    
    properties (SetAccess = protected)
        ExcitationSignal    (1,:) single
        ResponseSignal      (1,:) single
        
        ReferenceLevel      (1,1) double = 94; % dBSPL
        ReferenceSignal     (1,:) single
        
        CalibrationMode     (1,1) string {mustBeMember(CalibrationMode,["rms","peak"])} = "rms";
        
        CalibrationTimestamp (1,1) string
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
            
            g = uigridlayout(obj.handles.parent);
            
            g.ColumnWidth = {'1x',200};
            g.RowHeight   = {'1x','1x'};
            
            
        end
        
    end
end
    
    