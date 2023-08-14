classdef Interface < handle & matlab.mixin.Heterogeneous & matlab.mixin.SetGet
    % Abstract class for creating hardware interfaces for use by EPsych



    properties (Abstract)
        HW % Actual hardware interface object
    end


    properties (Abstract,Constant)
        Type (1,1) string
    end


    properties (Abstract,Dependent)
        hw_status (1,1) string {mustBeMember(hw_status,["undefined","idle","ready","running","error"])}
        hw_statusMessage (1,1) string
    end


    methods (Abstract)
        % setup hardware interface. this function must define obj.HW
        setup_interface()

        % close interface
        close_interface()

        % trigger a hardware event
        result = trigger(name)

        % set new value to one or more hardware parameters
        % returns TRUE if successful, FALSE otherwise
        result = set_parameter(name,value)

        % read current value for one or more hardware parameters
        value  = get_parameter(name)
    end


    methods

    end


end