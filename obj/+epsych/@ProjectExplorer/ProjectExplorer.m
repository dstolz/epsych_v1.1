classdef ProjectExplorer < handle
    
    
    properties
        ProjectsDirectory (1,1) string
        
        Projects    (:,1) epsych.Project
    end
    
    
    
    properties (SetAccess = immutable)
        parent
    end
    
    methods
        function obj = ProjectExplorer(varargin)
            
            for i = 1:2:length(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
            
            if isempty(obj.parent)
                obj.parent = uifigure( ...
                    'Name','Bitmask Generator', ...
                    'NumberTitle', 'off', ...
                    'Position',[400 250 650 360]);
            end
            
            obj.create_gui;
            
        end
        
        
    end
    
    methods (Access = protected)
        function create_gui(obj)
            
            g = uigridlayout(obj.parent);
            g.ColumnWidth = {'1x','2x'};
            g.RowHeight   = {25,'1x'};
            
            t = uitree(g);
            t.Layout.Column = 1;
            t.Layout.Row    = 2;
            
            
        end
    end
    
    
    
end