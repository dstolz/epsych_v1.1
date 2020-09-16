%%


f = uifigure;
g = uigridlayout(f);
g.ColumnWidth = {200,250,100};
g.RowHeight   = {25,100,100};

pISI  = epsych.par.Scalar( ...
    'Inter-Stim Interval',0.25, ...
    'Limits',[.05 1], ...
    'DispFormat','%.1f ms', ...
    'ScaleFactor',1/1000);

pFreq = epsych.par.Scalar( ...
    'Frequency',500*2.^(0:5), ...
    'DispFormat','%.1f kHz', ...
    'ScaleFactor',1000);

pDur  = epsych.par.Scalar( ...
    'Duration',.05, ...
    'Limits',[.01 .1], ...
    'DispFormat','%.1f ms', ...
    'ScaleFactor',1/1000);


%

h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 1;
h.Text = pDur.Name;
h.HorizontalAlignment = 'right';

h = uieditfield(g,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = 1;
pDur.uiControl = h;
pDurTxt = pDur.uiControl;

h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 2;
h.Text = pFreq.Name;
h.HorizontalAlignment = 'right';

% h = uidropdown(g);
h = uiknob(g,'discrete');
h.Layout.Column = 2;
h.Layout.Row    = 2;
pFreq.uiControl = h;


h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 3;
h.Text = pDur.Name;
h.HorizontalAlignment = 'right';

h = uiknob(g,'continuous');
h.Layout.Column = 2;
h.Layout.Row    = 3;
pDur.uiControl = h;

%

