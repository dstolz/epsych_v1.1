classdef (ConstructOnLoad) TrialsData < event.EventData
   properties
      Data
      BoxID
   end
   
   methods
      function data = TrialsData(trials)
         data.Data  = trials;
         data.Subject = trials.Subject;
      end
   end
end