function updatePlot(obj)
%UPDATEPLOT Redraw the value-history plot from ValueHistory.
%
% Every graphics object is created once in createUI and updated in place
% here: a staircase runs for hundreds of trials, and one line or marker per
% step would leave the axes carrying hundreds of objects, all re-rendered on
% every drawnow.
%
% The trace is a STAIR rather than a line because that is what the data is --
% the parameter holds each value until the next outcome moves it, and a
% straight interpolation between two steps draws a ramp the rig never played.

ax = obj.ValueHistoryAxes;
if isempty(ax) || ~isvalid(ax)
    return
end

v = obj.ValueHistory;
n = numel(v);

obj.ValueHistoryAxes.YLabel.String = yLabelText(obj);

if n == 0
    obj.ValueHistoryLine.XData = NaN;
    obj.ValueHistoryLine.YData = NaN;
    obj.ValueHistoryDots.XData = NaN;
    obj.ValueHistoryDots.YData = NaN;
    obj.CurrentMarker.XData = NaN;
    obj.CurrentMarker.YData = NaN;
    obj.CurrentText.String = '';
    % The bounds and the axis still have to be brought up to date: an empty
    % history is where resetHistory leaves the plot, and the limits from the
    % run that was just discarded would otherwise stay on the axes.
    applyBounds(obj)
    applyEmptyLimits(obj)
    return
end

x = 1:n;

% A single-point stair draws nothing, so hold the value across one trial
% to give the first sample a visible tread.
if n == 1
    obj.ValueHistoryLine.XData = [1 2];
    obj.ValueHistoryLine.YData = [v v];
else
    obj.ValueHistoryLine.XData = x;
    obj.ValueHistoryLine.YData = v;
end

obj.ValueHistoryDots.XData = x;
obj.ValueHistoryDots.YData = v;
obj.ValueHistoryDots.CData = directionColors(obj, n);

obj.CurrentMarker.XData = x(end);
obj.CurrentMarker.YData = v(end);

obj.CurrentText.String = [obj.formatValue(v(end)) strtrim(obj.unitSuffix())];
obj.CurrentText.Color = obj.COLOR_TRACE;

applyBounds(obj)
applyLimits(obj, x, v)
placeReadout(obj, x, v)
end


function placeReadout(obj, x, v)
% Park the value readout clear of the marker it belongs to.
%
% Placed after the limits are set, because the offset that clears the marker
% is a fraction of the axis span and the span is not known before then.
ax = obj.ValueHistoryAxes;
span = diff(ax.XLim);
gap = 0.025*span;

if numel(x) > 2
    % Trailing the newest point, so it stays inside the axes.
    obj.CurrentText.Position = [x(end) - gap, v(end), 0];
    obj.CurrentText.HorizontalAlignment = 'right';
else
    obj.CurrentText.Position = [x(end) + gap, v(end), 0];
    obj.CurrentText.HorizontalAlignment = 'left';
end
obj.CurrentText.VerticalAlignment = 'middle';
end


function t = logTicks(lims)
% Five round, evenly spaced-in-log ticks across the visible range.
t = logspace(log10(lims(1)), log10(lims(2)), 5);
% Two significant figures reads as a value an operator recognises (1200,
% not 1189.7) while staying distinct across the range.
t = unique(round(t, 2, 'significant'));
t = t(t >= lims(1) & t <= lims(2));
if isempty(t)
    t = lims;
end
end


function s = yLabelText(obj)
% The parameter's own name and unit, so the axis says what it is showing.
u = strtrim(obj.unitSuffix());
if isempty(u)
    s = char(obj.Parameter.Name);
else
    s = sprintf('%s (%s)', obj.Parameter.Name, u);
end
end


function c = directionColors(obj, n)
% Marker colour per step: up, down, or the value the session started from.
d = obj.StepDirections;
if numel(d) ~= n
    d = zeros(1,n); % history assigned directly by a caller
end
c = repmat(obj.COLOR_START, n, 1);
c(d > 0, :) = repmat(obj.COLOR_UP,   sum(d > 0), 1);
c(d < 0, :) = repmat(obj.COLOR_DOWN, sum(d < 0), 1);
end


function applyBounds(obj)
% Show the clamp bounds only when they are real numbers.
setBound(obj.MinLine, obj.MinValue)
setBound(obj.MaxLine, obj.MaxValue)
end


function setBound(h, value)
if isempty(h) || ~isvalid(h)
    return
end
if isfinite(value)
    h.Value = value;
    h.Visible = 'on';
else
    h.Visible = 'off';
end
end


function applyEmptyLimits(obj)
% With no history, frame whatever bounds exist so the axes still says
% something about the range the ladder will run in.
ax = obj.ValueHistoryAxes;
ax.XLim = [0.5 2.5];
ax.YScale = 'linear';
ax.YTickMode = 'auto';
ax.YTickLabelMode = 'auto';

lo = obj.MinValue;
hi = obj.MaxValue;
if isfinite(lo) && isfinite(hi) && hi > lo
    pad = 0.10*(hi - lo);
    ax.YLim = [lo - pad, hi + pad];
else
    ax.YLimMode = 'auto';
end
end


function applyLimits(obj, x, v)
% Explicit limits rather than axis tight: the bounds and the readout have to
% fit inside the axes, and a flat trace has no range to be tight around.
ax = obj.ValueHistoryAxes;

% A little room past the newest point for its readout.
n = max(max(x), 2);
ax.XLim = [0.5 n + 0.5 + 0.02*n];

lo = min(v);
hi = max(v);
if ~isfinite(lo) || ~isfinite(hi)
    return
end

if hi == lo
    pad = max(abs(hi)*0.1, 1);
else
    pad = 0.10*(hi - lo);
end

% The axis is scaled to the TRACE, not to the clamp range. A ladder working
% between 800 and 1600 inside bounds of 400 and 4000 would otherwise be drawn
% in a quarter of the axes with the rest of it empty, and the fine structure
% -- which reversal the animal is on -- is the entire point of the plot. A
% bound is pulled into view only when the staircase gets close enough to it
% to matter, which is also the only time it is worth the vertical space.
reach = 0.35*max(hi - lo, abs(hi)*0.1);
if isfinite(obj.MinValue) && obj.MinValue > lo - pad - reach
    lo = min(lo, obj.MinValue);
end
if isfinite(obj.MaxValue) && obj.MaxValue < hi + pad + reach
    hi = max(hi, obj.MaxValue);
end

% A proportional ladder is what a log axis is for, and it is the one case
% where the spacing the operator configured is the spacing they see.
useLog = obj.ScaleType == "logarithmic" && all(v > 0) && lo > 0;

if useLog
    ax.YScale = 'log';
    ax.YLim = [lo*0.9, hi*1.1];
    % A training range rarely spans a decade, and the automatic log ticks
    % then label one power of ten and leave the rest of the axis unmarked.
    ax.YTick = logTicks(ax.YLim);
    ax.YTickLabel = compose('%g', ax.YTick);
else
    ax.YScale = 'linear';
    ax.YLim = [lo - pad, hi + pad];
    ax.YTickMode = 'auto';
    ax.YTickLabelMode = 'auto';
end
end
