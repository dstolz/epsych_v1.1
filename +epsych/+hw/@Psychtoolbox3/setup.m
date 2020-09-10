function setup(obj,parent) % Psychtoolbox3
if nargin == 1 || isempty(parent)
    parent = uifigure('Name','Psychtoolbox3');
end






g = uigridlayout(parent);

% test Psychtoolbox is available
if exist('PsychStartup')  
    % Call Psychtoolbox-3 specific startup function:
    PsychStartup
    
    g.ColumnWidth = {'1x'};
    g.RowHeight   = {'1x'};
    h = uilabel(g,'Tag','HWPsychToolboxLabel');
    h.FontSize = 16;
    h.FontWeight = 'bold';
    h.FontColor = 'g';
    h.Text = 'Psychtoolbox Initialized';
    
else
    g.ColumnWidth = {'1x'};
    g.RowHeight   = {'1x'};

    h = uilabel(g,'Tag','HWPsychToolboxLabel');
    h.FontSize = 16;
    h.FontWeight = 'bold';
    h.Text = sprintf('Psychtoolbox is not available on your system!\nhttp://psychtoolbox.org');
    h.FontColor = 'r';
    return
end

