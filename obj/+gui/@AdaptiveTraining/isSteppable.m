function tf = isSteppable(value)
% tf = gui.AdaptiveTraining.isSteppable(value)
% True when a parameter value is one a step rule can be applied to.
%
% hw.Parameter carries its design-time levels in Values and leaves Value
% empty until something writes it, so an untouched parameter is the ordinary
% state before the first trial dispatch -- training mode can be switched on
% from a checkbox, or arrive with a phase load, long before then. That is not
% an error and not a reason for the window to refuse to open; it just means
% there is nothing to step away from yet.
%
% Static so that a caller holding the value can test it without a second read:
% on a hardware backend hw.Parameter.Value is a device round trip.
%
% See also gui.AdaptiveTraining, gui.AdaptiveTraining.stepValue

tf = isnumeric(value) && isscalar(value) && ~isnan(value);
end
