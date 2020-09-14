classdef (ConstructOnLoad) evDataUpdated < event.EventData
    
    properties
        NewExpression
        PreviousExpression        
    end
    
    methods
        function data = evDataUpdated(NewExpression,PreviousExpression)
            data.NewExpression = NewExpression;
            data.PreviousExpression = PreviousExpression;
        end
    end
end