function reorderMetrics(obj)
% reorderMetrics(obj)
% Let the operator rearrange the displayed metrics, then apply the result.
%
% A small modal window listing the metrics top-of-panel first, with Move Up /
% Move Down. The list reads in the order the rows are drawn, so the top of
% the list is the top of the panel.
%
% Cancelling changes nothing. OK routes through setMetricOrder, the same
% entry a script uses, so the arrangement is remembered like any other
% operator choice.
%
% NO NESTED FUNCTIONS, and the window is deleted explicitly on every path.
% A nested callback handle keeps its parent workspace alive for as long as
% the figure holds it, and that workspace would hold the onCleanup meant to
% delete the figure -- a reference cycle in which neither is ever released,
% so cancelling would leak an invisible modal window and the next
% Reorder Metrics... would block in uiwait forever.
%
% See also: gui.components.SessionPerformance.setMetricOrder

names = obj.Metrics;
if numel(names) < 2
    vprintf(1,'gui.components.SessionPerformance: nothing to reorder')
    return
end

% Captions rather than metric names: the dialog rearranges what is on screen.
C = psychophysics.SessionMetrics.catalogue();
items = cell(1,numel(names));
for i = 1:numel(names)
    def = C(strcmp([C.Name], names(i)));
    items{i} = char(def.Label);
end

% A pinned host would sit over this modal dialog, so unpin it for the
% duration -- by hand rather than through gui.PopOut.setAlwaysOnTop,
% which would save "not on top" as the operator's choice.
hostFig = ancestor(obj.Parent,'figure');
restore = localUnpin(hostFig); % an onCleanup, so an error on the way still re-pins

fig = uifigure('Name','Reorder Metrics','Visible','off', ...
    'WindowStyle','modal','Resize','off');
fig.Position(3:4) = [300 320];
movegui(fig,'center');

newItems = {};
try
    g = uigridlayout(fig,[2 3]);
    g.RowHeight = {'1x',30};
    g.ColumnWidth = {'1x',80,80};

    lb = uilistbox(g,'Items',items,'ItemsData',1:numel(items), ...
        'Value',1,'Multiselect','off');
    lb.Layout.Row = 1; lb.Layout.Column = [1 3];

    up = uibutton(g,'Text','Move Up');
    up.Layout.Row = 2; up.Layout.Column = 1;
    dn = uibutton(g,'Text','Move Down');
    dn.Layout.Row = 2; dn.Layout.Column = 2;
    okB = uibutton(g,'Text','OK');
    okB.Layout.Row = 2; okB.Layout.Column = 3;

    setappdata(fig,'ReorderAccepted',false);
    up.ButtonPushedFcn  = @(~,~) localMove(lb,-1);
    dn.ButtonPushedFcn  = @(~,~) localMove(lb,+1);
    okB.ButtonPushedFcn = @(~,~) localAccept(fig);
    fig.CloseRequestFcn = @(~,~) uiresume(fig);

    fig.Visible = 'on'; % the signal that the dialog is ready
    uiwait(fig);

    % ItemsData carries the original index, so the captions never have to be
    % matched back to metric names -- two metrics may share a label.
    if isvalid(fig) && getappdata(fig,'ReorderAccepted')
        newItems = lb.ItemsData;
    end
catch ME
    vprintf(0,1,ME)
end

if isvalid(fig), delete(fig); end
delete(restore); % re-pin the host now the dialog is gone

if isempty(newItems) || isequal(newItems(:)', 1:numel(items)), return; end
obj.setMetricOrder(names(newItems));
end


function localAccept(fig)
setappdata(fig,'ReorderAccepted',true);
uiresume(fig);
end


function localMove(lb,step)
% Shift the selected item one place, keeping it selected.
items = lb.Items;
data  = lb.ItemsData;
i = find(data == lb.Value,1);
if isempty(i), return; end
j = i + step;
if j < 1 || j > numel(items), return; end
items([i j]) = items([j i]);
data([i j])  = data([j i]);
lb.Items = items;
lb.ItemsData = data;
lb.Value = data(j);
end


function c = localUnpin(fig)
% Drop a host figure out of 'alwaysontop' for as long as the returned
% onCleanup lives. A release that will not honour WindowStyle is left alone.
c = onCleanup(@() []);
try
    if isempty(fig) || ~isvalid(fig) || ~strcmp(fig.WindowStyle,'alwaysontop')
        return
    end
    fig.WindowStyle = 'normal';
    c = onCleanup(@() localRepin(fig));
catch ME
    vprintf(2,'gui.components.SessionPerformance: cannot unpin the host window: %s', ME.message)
end
end


function localRepin(fig)
try
    if ~isempty(fig) && isvalid(fig)
        fig.WindowStyle = 'alwaysontop';
    end
catch
end
end
