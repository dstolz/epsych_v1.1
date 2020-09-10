classdef evHardwareUpdated < event.EventData
    properties
        Hardware
        HardwareSetup
    end
    
    methods
        function data = evHardwareUpdated(HardwareSetup,Hardware)
            data.HardwareSetup = HardwareSetup;
            data.Hardware = Hardware;
        end
    end
end