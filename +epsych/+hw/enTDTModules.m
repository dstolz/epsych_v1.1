classdef enTDTModules < uint8

    enumeration
        PA5     (33)
        RP2     (35)
        RL2     (36)
        RA16    (37)
        RV8     (38)
        RX5     (45)
        RX6     (46)
        RX7     (47)
        RX8     (48)
        RZ2     (50)
        RZ5     (53)
        RZ6     (54)
        RM1     (1) % not defined in manual
        RM2     (2) % not defined in manual
    end

    
    methods (Static)
        function m = list
            mx = ?epsych.hw.enTDTModules;
            m = {mx.EnumerationMemberList.Name};
        end

        function c = list_codes
            c = cellfun(@(a) uint8(epsych.hw.enTDTModules.(a)),epsych.hw.enTDTModules.list);
        end

        function fs = sampling_rates
            mfs = 390625; % master sampling rate for most TDT hardware
            fs = mfs ./ 2.^(0:6);
        end

        function s = sampling_rates_str(sz)
            if nargin == 0, sz = ''; end
            fs = epsych.hw.enTDTModules.sampling_rates;
            switch sz
                case 'Hz'
                    s = arrayfun(@(a) sprintf('%.1f Hz',a),fs,'uni',0);
                case 'kHz'
                    s = arrayfun(@(a) sprintf('%.1f kHz',a),fs/1000,'uni',0);
                otherwise
                    s = arrayfun(@(a) sprintf('%f',a),fs,'uni',0);
            end
        end
    end % methods (Static)
end