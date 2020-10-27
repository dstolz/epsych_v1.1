%%


% define Scalar parameter type
pISI  = epsych.par.Scalar( ...
    'Inter-Stim Interval',0.25, ...
    'Limits',[.05 1], ... 
    'Format','%.1f ms', ...
    'ScaleFactor',1/1000);

pFreq = epsych.par.Scalar( ...
    'Frequency',500*2.^(0:5), ...
    'Format','%.1f kHz', ...
    'ScaleFactor',1000);

pDur  = epsych.par.Scalar( ...
    'Duration',.05, ...
    'Limits',[.01 .1], ...
    'Format','%.1f ms', ...
    'ScaleFactor',1/1000);


% Create user interface controls

% ancestor must be uifigure
f = uifigure;

g = uigridlayout(f);
g.ColumnWidth = {200,250,100};
g.RowHeight   = {25,100,100};




h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 1;
h.Text = pDur.Name;
h.HorizontalAlignment = 'right';

h = uieditfield(g,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = 1;
pDur.uiControl = h; % assign uieditfield handle to pDur parameter


h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 2;
h.Text = pDur.Name;
h.HorizontalAlignment = 'right';

h = uiknob(g,'continuous');
h.Layout.Column = 2;
h.Layout.Row    = 2;
% overwrites handle for pDur.uiControl, however both controls remain linked
% to the Scalar parameter
pDur.uiControl = h; 


h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 3;
h.Text = pFreq.Name;
h.HorizontalAlignment = 'right';

h = uiknob(g,'discrete');
h.Layout.Column = 2;
h.Layout.Row    = 3;
pFreq.uiControl = h; % assign uiknob handle to pFreq parameter



