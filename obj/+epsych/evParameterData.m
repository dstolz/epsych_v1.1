classdef (ConstructOnLoad) evParameterData < event.EventData
   properties
        Data
        BoxID
   end
   
   methods
      function data = evParameterData(BoxID,Data)
         data.Data  = Data;
         data.BoxID = BoxID;
      end
   end
end