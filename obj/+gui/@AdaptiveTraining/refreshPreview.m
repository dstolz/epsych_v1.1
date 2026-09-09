function refreshPreview(obj)
%REFRESHPREVIEW Name the two values the next step would land on.
%
% This is the one line that makes a warped value space legible: the operator
% types a magnitude and a curvature and reads back the values the rig would
% actually go to, instead of doing exponentials in their head. It follows the
% CURRENT value, so it is refreshed after every step as well as after every
% edit -- a preview computed from where the track started would be a
% quietly wrong number sitting under the controls.
%
% The parameter is read ONCE here and the value passed down. On a hardware
% backend hw.Parameter.Value is a device round trip that rethrows whatever the
% backend throws, and this runs after every step and every widget commit; the
% two step computations below are then pure arithmetic over that one read.

if ~obj.UIReady || isempty(obj.PreviewLabel) || ~isvalid(obj.PreviewLabel)
    return
end

v = obj.Parameter.Value;

% Before the first trial dispatch the parameter has no Value to step away
% from -- training mode can be switched on from a checkbox or carried in by a
% phase load. That is a normal state, so the preview says what it is waiting
% for rather than the window failing to open.
if ~gui.AdaptiveTraining.isSteppable(v)
    obj.PreviewLabel.FontColor = obj.COLOR_MUTED;
    obj.PreviewLabel.Text = sprintf('Next   waiting for the first %s value', ...
        obj.Parameter.Name);
    return
end

u = obj.unitSuffix();

nv = namedargs2cell(obj.stepOptions(v));
[up, upInfo] = gui.AdaptiveTraining.stepValue(v, "up", nv{:});
[dn, dnInfo] = gui.AdaptiveTraining.stepValue(v, "down", nv{:});

if ~upInfo.Ok || ~dnInfo.Ok
    if ~upInfo.Ok
        obj.PreviewLabel.Text = upInfo.Message;
    else
        obj.PreviewLabel.Text = dnInfo.Message;
    end
    obj.PreviewLabel.FontColor = obj.COLOR_ERROR;
    return
end

obj.PreviewLabel.FontColor = obj.COLOR_MUTED;

t = sprintf('Next   ▲ %s%s (%+.3g)   ▼ %s%s (%+.3g)', ...
    obj.formatValue(up), u, upInfo.Delta, ...
    obj.formatValue(dn), u, dnInfo.Delta);

% A bound that is absorbing the step is worth saying out loud: the ladder has
% stopped moving in that direction and the plot alone does not make that
% obvious until several trials have piled up on the same value.
if upInfo.Clamped && dnInfo.Clamped
    t = [t '   [at both bounds]'];
elseif upInfo.Clamped
    t = [t '   [at maximum]'];
elseif dnInfo.Clamped
    t = [t '   [at minimum]'];
end

obj.PreviewLabel.Text = t;
end
