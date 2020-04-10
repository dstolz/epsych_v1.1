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
    g.ColumnWidth = {'1x','1x'};

    % TODO: Make button shortcuts