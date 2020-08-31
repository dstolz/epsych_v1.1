function create(obj,parent)

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Position = [5 5 100 120];
end

g = uigridlayout(parent);

isvertical = strcmp(obj.Orientation,'vertical');
if isvertical
    g.RowHeight   = {55,'1x','1x'};
    g.ColumnWidth = {'1x'};
else
    g.RowHeight   = {'1x'};
    g.ColumnWidth = {55,'1x','1x'};
end

% Create StateLabel
obj.StateLabel = uilabel(g);
obj.StateLabel.HorizontalAlignment = 'right';
obj.StateLabel.Text = '';
obj.StateLabel.FontSize = 14;

% Create StateLamp
obj.StateLamp = uilamp(g);
obj.StateLamp.Color = [0.8 0.8 0.8];

% Create StateIcon
h = uiaxes(g);
h.XTick = [];
h.YTick = [];
h.XColor = 'none';
h.YColor = 'none';
h.Color  = 'none';
h.Colormap = flipud(gray);
disableDefaultInteractivity(h);
obj.StateIcon = h;

[m,alpha] = epsych.Tool.get_icon('config');
imagesc(obj.StateIcon,m,'AlphaData',alpha);
axis(obj.StateIcon,'image');


% Create RunButton
obj.RunButton = uibutton(g, 'push');
obj.RunButton.BackgroundColor = [0.5 1 0.5];
obj.RunButton.FontSize = 16;
obj.RunButton.FontWeight = 'bold';
obj.RunButton.Enable = 'off';
% obj.RunButton.Text = 'Run';
obj.RunButton.Text = '';
obj.RunButton.Icon = epsych.Tool.icon('play');
obj.RunButton.IconAlignment = 'center';
obj.RunButton.ButtonPushedFcn = {@obj.update_state,'Run|Halt'};

% Create PauseButton
obj.PauseButton = uibutton(g, 'push');
obj.PauseButton.BackgroundColor = [1 0.8667 0.5608];
obj.PauseButton.FontSize = 16;
obj.PauseButton.FontWeight = 'bold';
obj.PauseButton.Enable = 'off';
% obj.PauseButton.Text = 'Pause';
obj.PauseButton.Text = '';
obj.PauseButton.Icon = epsych.Tool.icon('interface');
obj.PauseButton.IconAlignment = 'center';
obj.PauseButton.ButtonPushedFcn = {@obj.update_state,'Pause'};


if isvertical
    % obj.StateLabel.Layout.Row   = 1;
    obj.StateIcon.Layout.Row    = 1;
    obj.RunButton.Layout.Row    = 2;
    obj.PauseButton.Layout.Row  = 3;
    
    % obj.StateLabel.Layout.Column   = 1;
    obj.StateIcon.Layout.Column    = 1;
    obj.RunButton.Layout.Column    = 1;
    obj.PauseButton.Layout.Column  = 1;
else
    obj.StateIcon.Layout.Row    = 1;
    % obj.StateLabel.Layout.Row   = 2;
    obj.RunButton.Layout.Row    = 1;
    obj.PauseButton.Layout.Row  = 1;
    
    obj.StateIcon.Layout.Column    = 1;
    % obj.StateLabel.Layout.Column   = 1;
    obj.RunButton.Layout.Column    = 2;
    obj.PauseButton.Layout.Column  = 3;
end
