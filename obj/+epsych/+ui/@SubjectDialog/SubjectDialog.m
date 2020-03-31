classdef SubjectDialog < handle
    properties
        Subject    (1,1) epsych.Subject = epsych.Subject;


        NameEditField   (1,1) matlab.ui.control.EditField
        IDEditField     (1,1) matlab.ui.control.EditField
        DOBDatePicker   (1,1) matlab.ui.control.DatePicker
        SexDropDown     (1,1) matlab.ui.control.DropDown
        BaselineWeightEditField     (1,1) matlab.ui.control.NumericEditField
        NoteTextArea    (1,1) matlab.ui.control.TextArea
        
    end

    properties (SetAccess = private)
        parent
    end

    methods
        create(obj,parent)

        function obj = SubjectDialog(Subject,parent)
            if nargin >= 1 && ~isempty(Subject), obj.Subject = Subject; end
            if nargin < 2, parent = []; end

            obj.create(parent);

        end

        function create_field(obj,hObj,event)
            hObj.Value = obj.Subject.(hObj.Tag);
        end

        function update_field(obj,hObj,event)
            try
                obj.Subject.(hObj.Tag) = event.Value;

            catch me
                obj.Subject.(hObj.Tag) = event.PreviousValue;
                s = event.Value;
                if isnumeric(s), s = num2str(s); end
                uialert(obj.parent,'Invalid Entry', ...
                    'You entered an invalid value: %s',s);
            end
        end

        function save_subject(obj,hObj,event)
            
        end

        function load_subject(obj,hObj,event)

        end
    end
end