classdef TDT_Synapse < hw.Interface


    properties
        HW % Synapse API
    end


    properties (SetObservable = true)
        % hardware setup config. Abort updating if hardware connection is
        % already established.

        Server  (1,1) string = "localhost";
    end

    properties (Dependent)
        hw_status
        hw_statusMessage
    end


    properties (SetAccess = private, GetAccess = private)
        hTDTfig
    end


    properties (Constant)
        Type = "TDT_Synapse"
    end


    methods % INHERITED FROM ABSTRACT CLASS hw.Interface
        % setup hardware interface. CONFIG is platform dependent
        function setup_interface(obj)
            obj.HW = SynapseAPI(obj.Server);
        end


        function close_interface(obj)
            obj.HW.setMode(1); % standby
            try
                delete(obj.HW)
            end
        end

        % trigger a hardware event
        function t = trigger(obj,name)


        end

        % set new value to one or more hardware parameters
        % returns TRUE if successful, FALSE otherwise
        function result = set_parameter(obj,param,value)




        end

        % read current value for one or more hardware parameters
        function value  = get_parameter(obj,name)

        end



        function status = get.hw_status(obj)
            s = double(obj.HW.getMode);

            status = "error"; % default
            statusMessage = "ok";

            x = bitget(s,1:3);

            if ~any(x)
                status = "idle";
            end

            if x(1)
                status = "connected";
            else
                statusMessage = "Error connecting to RP module";
            end

            if x(2)
                status = "loaded";
            else
                statusMessage = "Error loading circuit to RP module";
            end

            if x(3)
                status = "running";
            else
                statusMessage = "Error runing the circuit";
            end

            obj.hw_statusMessage = statusMessage;

        end
    end


    methods % CHECK IF hw_status IS "IDLE" AND PARAMETER VALUES
       
    end


end