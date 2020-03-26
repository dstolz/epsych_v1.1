function create(obj,parent) % interface.CustomizationSetup

    if isa(parent,'matlab.ui.Figure')
        % Create parent
        parent = uipanel(parent);
        parent.Title = 'Customization Setup';
        parent.FontWeight = 'bold';
        parent.FontSize = 16;
        parent.Position = [5 4 560 225];
    end
    
    g = uigridlayout(parent);
    g.RowHeight   = {30,10,30,30,30,30};
    g.ColumnWidth = {10,'0.3x','0.7x',10};

    i = 1;
    lbl(i) = uilabel(g);
    lbl(i).Layout.Row = i;
    lbl(i).Layout.Column = 2;
    lbl(i).Text = 'Behavior GUI';

    lbld = uilabel(g);
    lbld.Layout.Row = 2;
    lbld.Layout.Column = [2 3];
    lbld.HorizontalAlignment = 'center';
    lbld.Text = repmat('~',1,100);

    i = i+1;
    lbl(i) = uilabel(g);
    lbl(i).Layout.Row = i+1;
    lbl(i).Layout.Column = 2;
    lbl(i).Text = 'Timer: StartFcn';

    i = i+1;
    lbl(i) = uilabel(g);
    lbl(i).Layout.Row = i+1;
    lbl(i).Layout.Column = 2;
    lbl(i).Text = 'Timer: TimerFcn';

    i = i+1;
    lbl(i) = uilabel(g);
    lbl(i).Layout.Row = i+1;
    lbl(i).Layout.Column = 2;
    lbl(i).Text = 'Timer: StopFcn';

    i = i+1;
    lbl(i) = uilabel(g);
    lbl(i).Layout.Row = i+1;
    lbl(i).Layout.Column = 2;
    lbl(i).Text = 'Timer: ErrorFcn';

    set(lbl,'FontSize',14,'HorizontalAlignment','right');