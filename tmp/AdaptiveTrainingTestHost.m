classdef AdaptiveTrainingTestHost < handle
%ADAPTIVETRAININGTESTHOST Minimal stand-in for a behavior GUI, for smoke tests.
%
% gui.eval_adaptive_training_mode reaches back into its caller for three
% members only. A paradigm GUI supplies them; so does this, without dragging
% a protocol, a figure and a timer into a test of the callback.
%
% See also smoke_test_adaptive_training, gui.eval_adaptive_training_mode

    properties
        RUNTIME
        AdaptiveTrainingGUIs
        AdaptiveTrainingListeners
    end

    methods
        function obj = AdaptiveTrainingTestHost(runtime)
            obj.RUNTIME = runtime;
        end
    end
end
