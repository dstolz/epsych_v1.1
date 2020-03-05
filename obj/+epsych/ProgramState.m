classdef (ConstructOnLoad) ProgramState < event.EventData
   properties
        State
   end
   
   methods
      function data = ProgramState(State)
         data.State = State;
      end
   end
end