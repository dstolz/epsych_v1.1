function refreshUI(obj)
%REFRESHUI Redraw every widget from the committed rule.
%
% One path, called after any commit from any source (a field, a table, a
% property assignment from a script), so the preview, the scale controls and
% the plot can never disagree with the properties they describe.

if ~obj.UIReady
    return % properties are still being assigned by the constructor
end

% --- header ------------------------------------------------------------
obj.ParamNameLabel.Text = string(obj.Parameter.Name);
obj.refreshCurrentValue();
obj.ResponseLabel.Text = sprintf('▲ on %s   ▼ on %s', ...
    obj.StepUpResponse, obj.StepDownResponse);

% --- value fields ------------------------------------------------------
% The tooltip carries the field's edit limits, which now live behind
% Advanced; it is rebuilt from the description each pass rather than
% appended to, or the range would accumulate on every refresh.
descriptions = { ...
    'StepUp',   'Magnitude added when the outcome calls for an easier trial'; ...
    'StepDown', 'Magnitude removed when the outcome calls for a harder trial'; ...
    'MinValue', 'Lower clamp applied after every step'; ...
    'MaxValue', 'Upper clamp applied after every step'};

for i = 1:size(descriptions,1)
    f = descriptions{i,1};
    L = obj.(f + "Limits");
    obj.ValueFields.(f).Value = obj.(f);
    obj.ValueFields.(f).Tooltip = sprintf('%s\nAccepted range: %g to %g', ...
        descriptions{i,2}, L(1), L(2));
    obj.UnitLabels.(f).Text = strtrim(obj.unitSuffix());
end

% --- advanced ----------------------------------------------------------
obj.ScaleDropDown.Value = char(obj.ScaleType);
obj.ExponentField.Value = obj.ScaleExponent;
obj.ReferenceField.Value = obj.referenceValue();

isPower = obj.ScaleType == "power";
isPiecewise = obj.ScaleType == "piecewise";
needsReference = any(obj.ScaleType == ["logarithmic","power"]);

setVisible(obj.ExponentLabel, isPower)
setVisible(obj.ExponentField, isPower)
setVisible(obj.ReferenceLabel, needsReference)
setVisible(obj.ReferenceField, needsReference)

obj.ScaleHelpLabel.Text = scaleHelpText(obj);
obj.LimitsTable.Data = obj.limitsTableData();
obj.BreakpointTable.Data = obj.Breakpoints;

% The selected tab follows the rule: picking Piecewise is a request to edit the
% breakpoints, and leaving it is a request to stop looking at them.
if isPiecewise && obj.AdvancedTabs.SelectedTab ~= obj.BreakpointTab
    obj.AdvancedTabs.SelectedTab = obj.BreakpointTab;
elseif ~isPiecewise && obj.AdvancedTabs.SelectedTab == obj.BreakpointTab
    obj.AdvancedTabs.SelectedTab = obj.LimitsTab;
end

obj.applyAdvancedVisibility();

% --- preview and plot --------------------------------------------------
obj.refreshPreview();
obj.updatePlot();
end


function setVisible(h, tf)
if ~isempty(h) && isvalid(h)
    h.Visible = matlab.lang.OnOffSwitchState(tf);
end
end


function t = scaleHelpText(obj)
% One sentence naming what the active space does, in this parameter's units.
u = obj.unitSuffix(); % already carries its leading space
switch obj.ScaleType
    case "linear"
        t = 'Equal steps everywhere in the range.';
    case "logarithmic"
        t = sprintf('Every step is %s of the value: %s at %s%s.', ...
            obj.percentStepText(), obj.formatValue(obj.StepUp), ...
            obj.formatValue(obj.referenceValue()), u);
    case "power"
        if obj.ScaleExponent < 1
            sense = 'shrink';
        elseif obj.ScaleExponent > 1
            sense = 'grow';
        else
            sense = 'stay equal';
        end
        t = sprintf('Steps %s as the value rises; %s at %s%s.', sense, ...
            obj.formatValue(obj.StepUp), obj.formatValue(obj.referenceValue()), u);
    case "piecewise"
        n = size(obj.Breakpoints,1);
        if n == 0
            t = 'No breakpoints yet: the step sizes above apply everywhere.';
        else
            t = sprintf('%d breakpoint(s); below %s%s the step sizes above apply.', ...
                n, obj.formatValue(obj.Breakpoints(1,1)), u);
        end
end
end


