classdef evSubjectDialog < event.EventData
    properties
        Subject
        hObj
        hObj_event
    end
    
    methods
        function data = evSubjectDialog(Subject,hObj,hObj_event)
            data.Subject = Subject;
            data.hObj = hObj;
            data.hObj_event = hObj_event;
        end
    end
end