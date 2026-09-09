function createUI(obj)
%CREATEUI Build the training window under Parent, or inside a new owned figure.
%
% Layout, top to bottom: the parameter and its current value, the four step
% fields, a collapsed Advanced section, the next-step preview, the value
% history plot, and a status line.
%
% The Advanced section holds everything that is a property of the RULE rather
% than of this session's ladder -- the value space and the edit limits. The
% limits in particular were four columns of a table an operator read every
% time they wanted to change a step size, and they are set once per rig if
% ever, so they are behind the disclosure now.

if isempty(obj.Parent)
    fpos = getpref(obj.PREFERENCE_TAG, 'Position', ...
        [500 300 obj.DEFAULT_SIZE]);
    % Floor the remembered size: a window saved before the Advanced section
    % existed is too short to show the plot at all.
    minHeight = obj.DEFAULT_SIZE(2);
    if obj.ShowAdvanced
        minHeight = minHeight + obj.ADVANCED_HEIGHT;
    end
    fpos(3) = max(fpos(3), obj.DEFAULT_SIZE(1));
    fpos(4) = max(fpos(4), minHeight);

    % The figure is being created at a height that ALREADY accounts for the
    % Advanced section -- either because it was saved that way, or because the
    % floor above just added it. Record that, or applyAdvancedVisibility would
    % see a delta from zero and add the section's height a second time; the
    % window would then grow by 232 px every time it was opened, and save it.
    if obj.ShowAdvanced
        obj.AdvancedHeightApplied = obj.ADVANCED_HEIGHT;
    end
    fig = uifigure('Name', 'Adaptive Training', ...
        'Position', gui.fitPositionToMonitor(fpos));
    fig.WindowStyle = char(obj.WindowStyle);
    fig.CloseRequestFcn = @(~,~)delete(obj);
    obj.Parent = fig;
    obj.OwnsParentFigure = true;
else
    if ~isvalid(obj.Parent)
        vprintf(0,1,'AdaptiveTraining: Parent is not a valid container; the window cannot be built.');
    end
end

if ~obj.OwnsParentFigure
    obj.ParentDestroyedListener = listener(obj.Parent, 'ObjectBeingDestroyed', @(~,~)delete(obj));
end

obj.RootGrid = uigridlayout(obj.Parent, [7 1]);
obj.RootGrid.RowHeight = {24, 20, 'fit', 0, 'fit', '1x', 18};
obj.RootGrid.ColumnWidth = {'1x'};
obj.RootGrid.Padding = [8 6 8 6];
obj.RootGrid.RowSpacing = 4;

buildHeader(obj)
buildSettings(obj)
buildAdvanced(obj)
buildPreview(obj)
buildPlot(obj)

obj.StatusLabel = uilabel(obj.RootGrid, 'Text', "", 'FontColor', obj.COLOR_MUTED, 'FontSize', 11);
obj.StatusLabel.Layout.Row = 7;

buildContextMenu(obj)
end


function buildHeader(obj)
% Parameter name, current value, and the Advanced disclosure.
g = uigridlayout(obj.RootGrid, [1 2]);
g.Layout.Row = 1;
g.ColumnWidth = {'1x', 100};
g.Padding = [0 0 0 0];
g.ColumnSpacing = 4;

obj.ParamNameLabel = uilabel(g, 'Text', "", 'FontWeight', 'bold', 'FontSize', 13);
obj.ParamNameLabel.Layout.Column = 1;

obj.AdvancedButton = uibutton(g, 'state', 'Text', '▸ Advanced', ...
    'Tooltip', 'Value-space rules and per-field edit limits', ...
    'ValueChangedFcn', @(src,~)obj.setShowAdvanced(src.Value));
obj.AdvancedButton.Layout.Column = 2;

g2 = uigridlayout(obj.RootGrid, [1 2]);
g2.Layout.Row = 2;
g2.ColumnWidth = {'1x', 'fit'};
g2.Padding = [0 0 0 0];
g2.ColumnSpacing = 4;

obj.ParamValueLabel = uilabel(g2, 'Text', "", 'FontAngle', 'italic');
obj.ParamValueLabel.Layout.Column = 1;

obj.ResponseLabel = uilabel(g2, 'Text', "", 'FontSize', 11, ...
    'FontColor', obj.COLOR_MUTED, 'HorizontalAlignment', 'right');
obj.ResponseLabel.Layout.Column = 2;
end


function buildSettings(obj)
% The four step-rule fields, one row each: label, entry, unit.
obj.SettingsPanel = uipanel(obj.RootGrid, 'BorderType', 'none');
obj.SettingsPanel.Layout.Row = 3;

fields = {
    'StepUp',   '▲ Step up',   'Magnitude added when the outcome calls for an easier trial'
    'StepDown', '▼ Step down', 'Magnitude removed when the outcome calls for a harder trial'
    'MinValue', 'Minimum',     'Lower clamp applied after every step'
    'MaxValue', 'Maximum',     'Upper clamp applied after every step'
    };

g = uigridlayout(obj.SettingsPanel, [size(fields,1) 3]);
g.RowHeight = repmat({24}, 1, size(fields,1));
g.ColumnWidth = {95, '1x', 42};
g.Padding = [0 2 0 2];
g.RowSpacing = 3;
g.ColumnSpacing = 6;

for i = 1:size(fields,1)
    name = fields{i,1};

    lbl = uilabel(g, 'Text', fields{i,2});
    lbl.Layout.Row = i;
    lbl.Layout.Column = 1;

    % Limits are left open on the widget so that every rejection goes
    % through applyValueEdit and says why in the status line; a uieditfield
    % that clamps on its own reverts silently.
    f = uieditfield(g, 'numeric', 'Tooltip', fields{i,3});
    f.Layout.Row = i;
    f.Layout.Column = 2;
    f.ValueChangedFcn = @(src,~)obj.valueFieldChanged(name, src);
    obj.ValueFields.(name) = f;

    u = uilabel(g, 'Text', '', 'FontColor', obj.COLOR_MUTED, 'FontSize', 11);
    u.Layout.Row = i;
    u.Layout.Column = 3;
    obj.UnitLabels.(name) = u;
end
end


function buildAdvanced(obj)
% The value-space rule and the edit limits, collapsed by default.
obj.AdvancedPanel = uipanel(obj.RootGrid, 'Title', 'Advanced', ...
    'FontWeight', 'bold', 'Visible', 'off');
obj.AdvancedPanel.Layout.Row = 4;

obj.AdvancedGrid = uigridlayout(obj.AdvancedPanel, [3 1]);
obj.AdvancedGrid.RowHeight = {24, 18, '1x'};
obj.AdvancedGrid.ColumnWidth = {'1x'};
obj.AdvancedGrid.Padding = [6 4 6 4];
obj.AdvancedGrid.RowSpacing = 4;

% --- value space -------------------------------------------------------
sg = uigridlayout(obj.AdvancedGrid, [1 5]);
sg.Layout.Row = 1;
sg.ColumnWidth = {'1x', 'fit', 58, 'fit', 66};
sg.Padding = [0 0 0 0];
sg.ColumnSpacing = 5;

obj.ScaleDropDown = uidropdown(sg, ...
    'Items', {'Linear', 'Proportional (log)', 'Power law', 'Piecewise'}, ...
    'ItemsData', {'linear', 'logarithmic', 'power', 'piecewise'}, ...
    'Tooltip', 'How the step magnitude scales as the value moves away from the reference', ...
    'ValueChangedFcn', @(src,~)obj.setScaleType(src.Value));
obj.ScaleDropDown.Layout.Column = 1;

obj.ExponentLabel = uilabel(sg, 'Text', 'p', 'HorizontalAlignment', 'right');
obj.ExponentLabel.Layout.Column = 2;

obj.ExponentField = uieditfield(sg, 'numeric', 'Limits', [eps inf], ...
    'Tooltip', 'Power-law exponent: < 1 compresses steps as the value rises, > 1 expands them', ...
    'ValueChangedFcn', @(src,~)obj.setScaleExponent(src.Value));
obj.ExponentField.Layout.Column = 3;

obj.ReferenceLabel = uilabel(sg, 'Text', 'at', 'HorizontalAlignment', 'right');
obj.ReferenceLabel.Layout.Column = 4;

obj.ReferenceField = uieditfield(sg, 'numeric', ...
    'Tooltip', 'Value the step magnitudes are calibrated at: a step there equals the magnitude typed above', ...
    'ValueChangedFcn', @(src,~)obj.setScaleReference(src.Value));
obj.ReferenceField.Layout.Column = 5;

obj.ScaleHelpLabel = uilabel(obj.AdvancedGrid, 'Text', "", ...
    'FontSize', 11, 'FontColor', obj.COLOR_MUTED);
obj.ScaleHelpLabel.Layout.Row = 2;

% Two tabs rather than two stacked tables: the limits are four rows nobody
% edits twice a year and the breakpoints only mean anything under one of the
% four rules, so stacking them cost the plot 130px it needs more.
tg = uitabgroup(obj.AdvancedGrid);
tg.Layout.Row = 3;
obj.AdvancedTabs = tg;

% --- edit limits -------------------------------------------------------
tLimits = uitab(tg, 'Title', 'Edit limits');
obj.LimitsTab = tLimits;
lg = uigridlayout(tLimits, [1 1]);
lg.Padding = [4 4 4 4];

obj.LimitsTable = uitable(lg);
obj.LimitsTable.ColumnName = {'Field', char(8805), char(8804)};
obj.LimitsTable.ColumnEditable = [false true true];
obj.LimitsTable.ColumnWidth = {'auto', '1x', '1x'};
obj.LimitsTable.RowName = [];
obj.LimitsTable.Tooltip = 'Edit limits accepted by the fields above';
obj.LimitsTable.CellEditCallback = @(~,evt)obj.limitsTableEdited(evt);

% --- piecewise breakpoints --------------------------------------------
tBreak = uitab(tg, 'Title', 'Breakpoints');
obj.BreakpointTab = tBreak;

obj.BreakpointGrid = uigridlayout(tBreak, [1 2]);
obj.BreakpointGrid.ColumnWidth = {'1x', 30};
obj.BreakpointGrid.RowHeight = {'1x'};
obj.BreakpointGrid.Padding = [4 4 4 4];
obj.BreakpointGrid.ColumnSpacing = 4;

obj.BreakpointTable = uitable(obj.BreakpointGrid);
obj.BreakpointTable.Layout.Column = 1;
obj.BreakpointTable.ColumnName = {'From', '▲ Step', '▼ Step'};
obj.BreakpointTable.ColumnEditable = [true true true];
obj.BreakpointTable.ColumnWidth = {'1x', '1x', '1x'};
obj.BreakpointTable.RowName = [];
obj.BreakpointTable.SelectionType = 'row';
obj.BreakpointTable.Tooltip = 'Step magnitudes used at or above each From value';
obj.BreakpointTable.CellEditCallback = @(~,evt)obj.breakpointsEdited(evt);

bg = uigridlayout(obj.BreakpointGrid, [2 1]);
bg.Layout.Column = 2;
bg.RowHeight = {26, 26};
bg.ColumnWidth = {'1x'};
bg.Padding = [0 0 0 0];
bg.RowSpacing = 3;

b = uibutton(bg, 'Text', '+', 'Tooltip', 'Add a breakpoint', ...
    'ButtonPushedFcn', @(~,~)obj.addBreakpoint());
b.Layout.Row = 1;
b = uibutton(bg, 'Text', '−', 'Tooltip', 'Remove the selected breakpoint', ...
    'ButtonPushedFcn', @(~,~)obj.removeBreakpoint());
b.Layout.Row = 2;
end


function buildPreview(obj)
% What the next step would actually do, in native units.
%
% This is the one line that makes a warped space legible: the operator types
% a magnitude and a curvature and reads back the two values the rig would
% land on, instead of doing exponentials in their head.
obj.PreviewLabel = uilabel(obj.RootGrid, 'Text', "", 'FontSize', 11, ...
    'WordWrap', 'on', 'VerticalAlignment', 'center');
obj.PreviewLabel.Layout.Row = 5;
end


function buildPlot(obj)
% The value-history plot: a stair trace, per-step markers coloured by
% direction, and the clamp bounds as reference lines.
ax = uiaxes(obj.RootGrid);
ax.Layout.Row = 6;
obj.ValueHistoryAxes = ax;

hold(ax, 'on')
ax.Box = 'off';
ax.YGrid = 'on';
ax.GridAlpha = 0.12;
ax.FontSize = 10;
ax.XLabel.String = 'Trial';
ax.XLabel.FontSize = 10;
ax.YLabel.FontSize = 10;
ax.TickDir = 'out';
ax.XLim = [0.5 2.5];

% Bounds first, so the trace draws over them.
obj.MinLine = yline(ax, 0, '--', 'min', 'Color', obj.COLOR_BOUND, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top', ...
    'FontSize', 9, 'Visible', 'off');
obj.MaxLine = yline(ax, 0, '--', 'max', 'Color', obj.COLOR_BOUND, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom', ...
    'FontSize', 9, 'Visible', 'off');

% One stair, one scatter, one emphasis marker, one label -- updated in
% place. Drawing a graphics object per step would leave hundreds of them on
% the axes by the end of a training session, all re-rendered on every
% drawnow.
obj.ValueHistoryLine = stairs(ax, NaN, NaN, 'LineWidth', 1.25, 'Color', obj.COLOR_TRACE);
obj.ValueHistoryDots = scatter(ax, NaN, NaN, 26, obj.COLOR_START, 'filled', ...
    'MarkerEdgeColor', 'none');
obj.CurrentMarker = line(ax, NaN, NaN, 'LineStyle', 'none', 'Marker', 'o', ...
    'MarkerSize', 8, 'LineWidth', 1.5, 'Color', [0 0 0], 'MarkerFaceColor', 'none');
obj.CurrentText = text(ax, NaN, NaN, '', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Clipping', 'on');
hold(ax, 'off')
end


function buildContextMenu(obj)
% Right-click actions, mirroring the Advanced disclosure so the section is
% reachable from the plot as well as the header.
fig = ancestor(obj.Parent, 'figure');
if isempty(fig)
    return
end

cm = uicontextmenu(fig);
uimenu(cm, 'Text', 'Advanced settings', ...
    'MenuSelectedFcn', @(~,~)obj.setShowAdvanced(~obj.ShowAdvanced));
uimenu(cm, 'Text', 'Reset history', 'Separator', 'on', ...
    'MenuSelectedFcn', @(~,~)obj.resetHistory());
uimenu(cm, 'Text', 'Copy history to clipboard', ...
    'MenuSelectedFcn', @(~,~)clipboard('copy', sprintf('%.10g\n', obj.ValueHistory)));

obj.ValueHistoryAxes.ContextMenu = cm;
obj.SettingsPanel.ContextMenu = cm;
end
