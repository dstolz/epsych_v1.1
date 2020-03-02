classdef (ConstructOnLoad) ParameterData < event.EventData
   properties
        Data
        BoxID
   end
   
   methods
      function data = ParameterData(BoxID,Data)
         data.Data  = Data;
         data.BoxID = BoxID;
      end
   end
end