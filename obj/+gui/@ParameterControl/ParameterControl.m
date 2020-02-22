classdef (Abstract) ParameterControl < handle & matlab.mixin.SetGet
    
    
    properties
        Value
        
        LabelString     (1,:) char
        LabelPosition   (1,:) {mustBeMember(LabelPosition,{'left','right','above','below'})} = 'left';

        Position        (1,4) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = [0 0 100 22];
        PositionX       (1,1) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = 0;
        PositionY       (1,1) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = 0;
        Width           (1,1) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = 100;
        Height          (1,1) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = 22;

        Parameter       (1,1) epsych.Parameter
        
    end

    properties (SetAccess = protected)
        hLabel
        hControl
       
        parent
    end
    
    methods (Abstract)
        create(obj);
    end
    
    methods
        function obj = ParameterControl(Parameter,parent,varargin)
            narginchk(1,4);
            
            obj.Parameter = Parameter;
            
            if nargin >= 2 && ~isempty(parent), obj.parent = parent; end

            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych.Parameter:Parameter:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end

            obj.create;
        end
        
        
        function set.PositionX(obj,x)
            obj.hControl.Position(1) = x;
            obj.update_position;
        end
        
        function set.PositionY(obj,y)
            obj.hControl.Position(2) = y;
            obj.update_position;
        end
        
        function set.Width(obj,w)
            obj.hControl.Position(3) = w;
            obj.update_position;
        end
        
        function set.Height(obj,h)
            obj.hControl.Position(1) = h;
            obj.update_position;
        end
        
        function set.Position(obj,position)
            obj.hControl.Position = position;
            obj.update_position;
        end
        

        function modify_parameter(obj,hObj,event)
            disp(event)
        end

    end
    
    methods (Access = protected)
        
        function update_position(obj)
            hp = obj.hControl.Position;
            lp = obj.hLabel.Position;
            
            switch obj.LabelPosition
                case 'left'
                    obj.hLabel.Position(1) = (1)-lp(3);
                    obj.hLabel.HorizontalAlignment = 'right';

                case 'right'
                    obj.hLabel.Position(1) = sum(hp([1 3]));
                    obj.hLabel.HorizontalAlignment = 'left';

                case 'above'
                    obj.hLabel.Position(2) = sum(hp([2 4]));
                    obj.hLabel.HorizontalAlignment = 'left';

                case 'below'
                    obj.hLabel.Position(2) = hp(2)-lp(4);
                    obj.hLabel.HorizontalAlignment = 'left';
            end
        end
        
        
    end

end