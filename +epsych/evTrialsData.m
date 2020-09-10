classdef (ConstructOnLoad) evTrialsData < event.EventData
   properties
      Data
      Subject
      BoxID
   end
   
   methods
      function data = evTrialsData(trials)
         data.Data    = trials;
         data.Subject = trials.Subject;
         data.BoxID   = trials.BoxID;
      end
   end
end