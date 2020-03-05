classdef (ConstructOnLoad) ProgramState < event.EventData
   properties
        State
   end
   
   methods
      function data = ParameterData(State)
         data.State = State;
      end
   end
end