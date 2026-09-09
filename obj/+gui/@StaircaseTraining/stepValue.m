function [value, info] = stepValue(currentValue, direction, options)
% [value, info] = gui.StaircaseTraining.stepValue(currentValue, direction)
% [value, info] = gui.StaircaseTraining.stepValue(currentValue, direction, options)
% Take one staircase step in the configured value space.
%
% The GUI's own stepping goes through here, and so can a headless caller: it
% is a pure function of the rule and the current value, which is what makes
% the spacing rules testable without a figure.
%
% The step magnitude always means PARAMETER UNITS AT THE REFERENCE VALUE. Each
% space is calibrated so that its local slope at the reference matches a linear
% step of the same magnitude; away from the reference the spacing warps. That
% is the whole reason the calibration is written this way -- switching space
% must not silently rescale a ladder the operator already has working, only
% change how it spreads out.
%
%   "linear"      v +/- Step.
%   "logarithmic" v * exp(+/-Step/Ref). Proportional (geometric) stepping:
%                 every step is the same FRACTION of the value, that fraction
%                 being Step/Ref. Requires positive values and reference.
%   "power"       ((v^p) +/- Step*p*Ref^(p-1))^(1/p) with p = ScaleExponent,
%                 using signed powers so negative values are handled. p < 1
%                 compresses the steps as the value rises, p > 1 expands them.
%   "piecewise"   Linear, but with the magnitudes taken from the Breakpoints
%                 table: the last row whose From value is <= the current value.
%                 Below the first breakpoint the StepUp/StepDown options apply.
%
% Inputs
%   currentValue - Value to step away from.
%   direction - "up" or "down".
%
% Name-Value options
%   StepUp, StepDown - Positive step magnitudes in parameter units.
%   ScaleType - "linear" | "logarithmic" | "power" | "piecewise".
%   ScaleExponent - Power-law exponent, > 0. Only read for "power".
%   ScaleReference - Value the magnitudes are calibrated at. Non-finite or
%       zero resolves to currentValue, which makes the step local.
%   Breakpoints - Nx3 [FromValue StepUp StepDown]. Only read for "piecewise".
%   MinValue, MaxValue - Clamp bounds applied after the step.
%
% Returns
%   value - The stepped, clamped value. Equals currentValue when the rule
%       cannot be applied (info.Ok false); this function never throws, since
%       its caller is a trial-completion listener.
%   info - struct describing what happened:
%       .Ok        false when the rule could not be applied
%       .Message   why not, for the status line
%       .Direction +1 up, -1 down
%       .Step      the magnitude used (the segment's, under "piecewise")
%       .Unclamped the value before clamping
%       .Clamped   true when a bound absorbed part of the step
%       .Delta     value - currentValue
%
% See also gui.StaircaseTraining

arguments
    currentValue (1,1) double
    direction (1,1) string {mustBeMember(direction,["up","down"])}
    options.StepUp (1,1) double = 1
    options.StepDown (1,1) double = 1
    options.ScaleType (1,1) string {mustBeMember(options.ScaleType,["linear","logarithmic","power","piecewise"])} = "linear"
    options.ScaleExponent (1,1) double = 0.5
    options.ScaleReference (1,1) double = NaN
    options.Breakpoints (:,3) double = zeros(0,3)
    options.MinValue (1,1) double = -inf
    options.MaxValue (1,1) double = inf
end

d = 1;
if direction == "down"
    d = -1;
end

info = struct('Ok', true, 'Message', "", 'Direction', d, 'Step', NaN, ...
    'Unclamped', currentValue, 'Clamped', false, 'Delta', 0);

step = segmentStep(currentValue, d, options);
info.Step = step;

if ~(isfinite(step) && step > 0)
    info.Ok = false;
    info.Message = "Step size must be finite and > 0.";
    value = currentValue;
    return
end

ref = options.ScaleReference;
if ~isfinite(ref) || ref == 0
    ref = currentValue; % local step; documented fallback
end

switch options.ScaleType
    case {"linear","piecewise"}
        raw = currentValue + d*step;

    case "logarithmic"
        if ~(currentValue > 0)
            info.Ok = false;
            info.Message = "Proportional stepping needs a positive value; " + ...
                "the parameter is at " + string(num2str(currentValue)) + ".";
            value = currentValue;
            return
        end
        if ~(ref > 0 && isfinite(ref))
            info.Ok = false;
            info.Message = "Proportional stepping needs a positive reference value.";
            value = currentValue;
            return
        end
        raw = currentValue * exp(d*step/ref);

    case "power"
        p = options.ScaleExponent;
        if ~(isfinite(p) && p > 0)
            info.Ok = false;
            info.Message = "Power-law exponent must be finite and > 0.";
            value = currentValue;
            return
        end
        if ~isfinite(ref) || ref == 0
            info.Ok = false;
            info.Message = "Power-law stepping needs a finite, non-zero reference value.";
            value = currentValue;
            return
        end
        % Calibrated on the slope at the reference: d(v^p)/dv = p*|ref|^(p-1).
        du = step * p * abs(ref)^(p-1);
        raw = signedPower(signedPower(currentValue, p) + d*du, 1/p);
end

if ~isfinite(raw)
    info.Ok = false;
    info.Message = "Step produced a non-finite value.";
    value = currentValue;
    return
end

info.Unclamped = raw;
value = min(max(raw, options.MinValue), options.MaxValue);
info.Clamped = value ~= raw;
info.Delta = value - currentValue;

end


function step = segmentStep(currentValue, d, options)
% Resolve the step magnitude that applies at currentValue.
%
% Only "piecewise" consults the breakpoint table; every other space uses the
% single pair of magnitudes, so the Step Up / Step Down fields keep one
% meaning across all four rules.
if d > 0
    step = options.StepUp;
else
    step = options.StepDown;
end

if options.ScaleType ~= "piecewise" || isempty(options.Breakpoints)
    return
end

B = gui.StaircaseTraining.sortBreakpoints(options.Breakpoints);
idx = find(currentValue >= B(:,1), 1, 'last');
if isempty(idx)
    return % below the first breakpoint: the base magnitudes apply
end

if d > 0
    step = B(idx,2);
else
    step = B(idx,3);
end
end


function y = signedPower(x, p)
% Sign-preserving power, monotone across zero so a warped space can hold
% negative values (an attenuation in dB, a level below a reference).
if x == 0
    y = 0;
else
    y = sign(x) * abs(x)^p;
end
end
