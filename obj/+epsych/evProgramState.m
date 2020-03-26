classdef (ConstructOnLoad) evProgramState < event.EventData
   properties
        State           (1,1) epsych.State
        previousState   (1,1) epsych.State
        Timestamp       (1,1) double
        Error           (:,1) MException
   end
   
   methods
      function data = evProgramState(State,prevState,Timestamp,MException)
         narginchk(1,3)
         data.State = State;
         
         if nargin >= 2 && ~isempty(prevState)
            data.previousState = prevState;
         end
         
         if nargin < 3 || isempty(Timestamp), Timestamp = now; end
         data.Timestamp = Timestamp;

         if nargin == 4, data.Error = MException; end
      end
   end
end