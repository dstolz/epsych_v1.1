classdef (ConstructOnLoad) TDTActiveX < epsych.hw.Hardware

    properties (Constant) % define constant abstract properties from superclass
        Name         = 'TDTActiveX';
        Type         = 'COM.RPco_x';
        Description  = 'Standalone TDT ActiveX controls';
        MaxNumInstances = 1;
    end

    % define public abstract properties from superclass
    properties (Dependent)
        Status
    end

    properties (Access = protected)
        ErrorME
    end
    
    properties (Access = private,Transient,Hidden)
        InterfaceParent     % matlab.ui.container
    
        ConnectionTypeDropDownLabel matlab.ui.control.Label
        ConnectionTypeDropDown      matlab.ui.control.DropDown
        TDTModulesTable             matlab.ui.control.Table
        AddModuleButton             matlab.ui.control.Button
        RemoveModuleButton          matlab.ui.control.Button

        CurrentIdx % selected row
    end
    
    properties (SetObservable,AbortSet)
        ConnectionType  (1,:) char {mustBeMember(ConnectionType,{'GB','USB'})} = 'GB';
        Module          (1,:) % structure
    end


    properties (Dependent)
        FsIdx
    end

    properties (SetAccess = private,Transient)
        handle % handle to ActiveX
    end
    
    properties (Access = private,Transient)
        emptyFig % holds TDT ActiveX object which requires a figure
    end

    methods
        e = prepare(obj);
        e = runtime(obj);

        e = write(obj,parameter,value);
        v = read(obj,parameter);
        e = trigger(obj,parameter);

        function obj = TDTActiveX
            % call superclass constructor
            obj = obj@epsych.hw.Hardware;           
        end

        function delete(obj)
            obj.cleanup;
        end

        function e = start(obj)
            e = false;
            for i = 1:length(obj.handle)
                if obj.handle(i).Run
                    fprintf('running\n')
                else
                    errordlg(sprintf(['Unable to run %s module!\n\n', ...
                        'Ensure all modules are powered on and connections are secured'], ...
                        module),'Run Error','modal');
                    obj.cleanup;
                    e = true;
                    return
                end
            end
        end
        
        function e = stop(obj)
            for i = 1:length(obj.handle)
                e(i) = obj.handle(i).Halt;
            end
            obj.cleanup;
        end
        
        function cleanup(obj)
            delete(obj.handle);
            h = findobj('Name','RPfig');
            close(h);
        end

        function status = get.Status(obj)
            if isa(obj.handle,obj.Type)
                for i = 1:length(obj.handle)
                    rpstatus = obj.handle(i).GetStatus;
                    if rpstatus == 7
                        status = epsych.hw.enStatus.Running;

                    elseif rpstatus == 3
                        status = epsych.hw.enStatus.Ready;
                        return

                    else
                        status = epsych.hw.enStatus.InPrep;
                        return
                    end
                end
            else
                status = epsych.hw.enStatus.Error;
            end
        end % get.enStatus


        function i = get.FsIdx(obj)
            mfs = 390625; % master sampling rate for most TDT hardware
            fs = mfs ./ 2.^(0:6);
            i = obj.ModuleFs == fs;
        end


        % UI -----------------------------------------------------
        function connectiontype_changed(obj,hObj,event)
            obj.ConnectionType = hObj.Value;
        end

        function add_module(obj,hObj,event)
            % add module to the table
            D = obj.TDTModulesTable.Data;
            idx = min(setdiff(1:100,[D{ismember(D(:,1),D(end,1)),2}]));
            n = D(end,:);
            n{2} = idx;
            n{3} = 'native';
            n{4} = '';
            obj.TDTModulesTable.Data(end+1,:) = n;
            obj.module_updated;
        end

        function remove_module(obj,hObj,event)
            idx = obj.CurrentIdx;

            if size(obj.TDTModulesTable.Data,1) == 1, return; end

            obj.TDTModulesTable.Data(idx,:) = [];
            
            obj.Module(idx) = [];
            obj.module_updated;
        end

        function module_edit(obj,hObj,event)
            obj.CurrentIdx = event.Indices(1);
            row = event.Indices(1,1);
            col = event.Indices(1,2);

            D = hObj.Data;
            
            
            switch col
                case 1 % Module
                case 2 % Index
                    v = event.NewData;
                    try
                        mustBePositive(v);
                        mustBeInteger(v);
                    catch
                        hObj.Data{row,col} = event.PreviousData;
                        return
                    end
                    ar = setdiff(1:size(D,1),row);
                    if ~isempty(ar)
                        ind = ismember(D(:,1),D(row,1));
                        if sum(ind) > 1
                            hObj.Data{row,col} = event.PreviousData;
                            fprintf(2,'Must have unique index for each module of a type')
                        end
                    end
                case 3 % Fs
                case 4 % Alias
                    ua = unique(D(:,col));
                    if length(ua) < size(D,1)
                        fprintf(2,'Invalid Entry: "%s"',event.NewData)
                        hObj.Data{row,col} = '';
                    end
                case 5 % RPvds File
                    hObj.Data{row,5} = '';
                    obj.select_rpvds_file(hObj,event);
            end
            obj.module_updated;
        end

        function module_select(obj,hObj,event)
            obj.CurrentIdx = event.Indices(1); % use only first selected row
            
            if event.Indices(1,2) < 5, return; end
            
            obj.select_rpvds_file(hObj,event);

            obj.module_updated;
        end

    end % methods
    
    methods (Access = private)

        function module_updated(obj)
            global RUNTIME
            
            D = obj.TDTModulesTable.Data;
            UD = obj.TDTModulesTable.UserData;
            for i = 1:size(D,1)
                M(i).Type  = epsych.hw.enTDTModules(D{i,1});
                M(i).Index = D{i,2};
                Fs = D{i,3};
                if isequal(Fs,'native'), Fs = -1; end
                M(i).Fs    = Fs;
                M(i).Alias = D{i,4};
                if isempty(UD) || size(UD,1)<i
                    M(i).RPvds = '';
                else
                    M(i).RPvds = UD{i,5};
                end
                M(i).handle = []; % activex control handle (created in prepare)
            end
            
            obj.Module = M;
%             
%             % TODO: NEED SOME HARDWARE INDEX ID
%             RUNTIME.Hardware = copy(obj);
        end

        function select_rpvds_file(obj,hObj,event)
            figState = epsych.Tool.figure_state(hObj,false);

            row = event.Indices(1);
            if row <= length(obj.Module) && ~isempty(obj.Module(row).RPvds)
                pn = fileparts(obj.Module(row).RPvds);
            else
                pn = getpref('epsych_Hardware','RPvdsPath',epsych.Info.user_directory);
            end
            [fn,pn] = uigetfile('*.rcx','RPvds File',pn);

            epsych.Tool.figure_state(hObj,figState);

            figure(ancestor(hObj,'figure'));
            
            if isequal(fn,0), return; end
                        
            hObj.Data{row,5} = fn;
            hObj.UserData{row,5} = fullfile(pn,fn);
            
            setpref('epsych_Hardware','RPvdsPath',pn);

            figure(ancestor(hObj,'figure'));

            obj.module_updated;

        end 
    end % methods (Access = private)
    
end