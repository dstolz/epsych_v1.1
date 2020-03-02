classdef (ConstructOnLoad) ParameterData < event.EventData
   properties
        Data
        BoxID
   end
   
   methods
      function data = ParameterData(data)
         
         data.Data = trials.data;
         data.BoxID   = trials.BoxID;
      end
   end
end