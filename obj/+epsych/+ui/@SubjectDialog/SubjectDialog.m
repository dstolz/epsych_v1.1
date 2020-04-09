classdef SubjectDialog < handle
    % h = epsych.ui.SubjectDialog([Subject],[parent]);
    %
    % Use the following to block execution:
    %   waitfor(h.parent);
    %   disp(h.UserResponse)   % can equal 'OK' or 'Cancel'
    %
    % Subject data is in h.Subject

    properties
        Subject    (1,1) epsych.Subject
    end

    properties (Access = protected)
        NameEditField           (1,1) matlab.ui.control.EditField
        IDEditField             (1,1) matlab.ui.control.EditField
        DOBDatePicker           (1,1) matlab.ui.control.DatePicker
        SexDropDown             (1,1) matlab.ui.control.DropDown
        BaselineWeightEditField (1,1) matlab.ui.control.NumericEditField
        ProtocolFileEditField   (1,1) matlab.ui.control.EditField
        LocateProtocolButton    (1,1) matlab.ui.control.Button
        NoteTextArea            (1,1) matlab.ui.control.TextArea
        OKButton                (1,1) matlab.ui.control.Button
        CancelButton            (1,1) matlab.ui.control.Button
    end

    properties (SetAccess = private)
        UserResponse    (1,:) char = 'Cancel'; % default if closed manually
        parent
    end

    methods
        create(obj,parent)

        function obj = SubjectDialog(Subject,parent)
            if nargin == 0, obj.Subject = epsych.Subject; end
            if nargin > 0 && ~isempty(Subject), obj.Subject = Subject; end
            if nargin < 2, parent = []; end

            obj.create(parent);

            
            epsych.ui.FigOnTop.figure_state(obj.parent,true);
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

        function response_button(obj,hObj,event)
            obj.UserResponse = hObj.Tag;
            close(obj.parent);
        end

    end % methods (Access = public)

    methods (Access = private)
        function locate_file(obj,hObj,event)
            pn = getpref('epsych',[hObj.Tag 'Path'],epsych.Info.user_directory);

            [fn,pn] = uigetfile(hObj.UserData{:},pn);

            if isequal(fn,0), return; end

            setpref('epsych',[hObj.Tag 'Path'],pn);
            
            obj.Subject.(hObj.Tag) = fullfile(pn,fn);
        end
    end % methods (Access = private)
end