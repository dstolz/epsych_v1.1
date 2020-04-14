function create(obj,parent) % epsych.ui.Shortcuts

    if isempty(parent)
        parent = uifigure('Name','Epsych Shortcuts');
    else
        obj.parent = parent;
    end

    if isa(parent,'matlab.ui.Figure')
        % Create parent
        obj.parent = uipanel(parent);
        obj.parent.Title = 'EPsych Shortcuts';
        obj.parent.FontWeight = 'bold';
        obj.parent.FontSize = 16;
        obj.parent.Position([3 4]) = [560 225];
    end
    
    g = uigridlayout(obj.parent);
    g.RowHeight   = {30,30,30,30};
    g.ColumnWidth = {'1x','1x','1x'};


    % Make button shortcuts - use Tag to code launch using eval
    h = uibutton(g,'Tag','epsych.ui.BitmaskGen');
    h.Text = 'Bitmask Generator';
    h.ButtonPushedFcn = @obj.launch;

    h = uibutton(g,'Tag','ep_ExperimentDesign');
    h.Text = 'Experiment Design';
    h.ButtonPushedFcn = @obj.launch;