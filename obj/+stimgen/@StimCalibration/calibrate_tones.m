function calibrate_tones(obj,freqs)

if nargin < 2 || isempty(freqs)
    freqs = 100.*2.^(0:1/16:12);
    freqs = freqs(freqs<obj.Fs*0.5);
end
so = stimgen.Tone;
so.Fs = obj.Fs;
so.Duration = 0.1;
obj.StimTypeObj = so;
obj.CalibrationMode = "specfreq";
m = nan(size(freqs));
for i = 1:length(freqs)
    vprintf(1,'[%d/%d] Calibrating tone frequency = %.3f kHz', ...
        i,length(freqs),freqs(i)/1000)
    so.Frequency = freqs(i);
    so.WindowDuration = 4./freqs(i);
    so.update_signal;
    m(i) = obj.calibrate(so.Signal);
end
c = 20*log10(m./obj.MicSensitivity) + obj.ReferenceLevel;
v = 10.^((obj.NormativeValue-c)./20);
obj.CalibrationData.tone = [freqs(:) m(:) c(:) v(:)];
