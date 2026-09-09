classdef StaircaseTrainingTestHost < handle
%STAIRCASETRAININGTESTHOST Minimal stand-in for a behavior GUI, for smoke tests.
%
% gui.eval_staircase_training_mode reaches back into its caller for three
% members only. A paradigm GUI supplies them; so does this, without dragging
% a protocol, a figure and a timer into a test of the callback.
%
% See also smoke_test_staircase_training, gui.eval_staircase_training_mode

    properties
        RUNTIME
        StaircaseTrainingGUIs
        StaircaseTrainingListeners
    end

    methods
        function obj = StaircaseTrainingTestHost(runtime)
            obj.RUNTIME = runtime;
        end
    end
end
