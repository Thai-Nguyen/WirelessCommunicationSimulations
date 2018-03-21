%% BER Analysis
% Script to compare the bit error rate (BER) of several modulation
% schemes. 
% The following modulation schemes are analyzed:
%   - BPSK
%   - 4-QAM

clear

%% Parameters
verbose = false; %set to true to aid in debugging

modulation_scheme = {'BPSK', '4QAM'};

SNRdB = 0:10;
sum_errors = zeros(length(modulation_scheme), length(SNRdB));

Nf = 1e3; %number of frames
Na = 1e3; %message length (bits)
T = 0.01; %symbol duration (s)
eta = 64; %number of samples per symbol

fc = 400; %carrier frequency (Hz)

ht = 1/sqrt(T) * ones(1,eta); %pulse shape (rectangular, NRZ)
hr = fliplr(ht);
Ns = Na*eta;
Ts = T/eta; %sample period

time = 0:Ts:Na*T-Ts;

%% Start simulation
for k = 1:length(modulation_scheme)
    fprintf('Running modulation scheme: %s\n', modulation_scheme{k});
    switch modulation_scheme{k} %decide on symbols to use
        case 'BPSK'
            sm = [1 -1];
        case '4QAM'
            sm = [1+1i -1+1i -1-1i 1-1i];
    end
    Eb = sum(sm*sm') / length(sm); %energy per bit
    
    for i = 1:length(SNRdB)
        num_errors = 0;
        N0 = Eb * 10.^(-SNRdB(i)/10); %noise PSD

        parfor j = 1:Nf
            %Transmitter
            a = randi([0 1], 1, Na);                         %Data source
            vn = map_symbol(a, modulation_scheme{k});        %Symbol mapper
            vt = conv(upsample(vn, eta), ht);                %Transmit filter
            vt = vt(1:Ns);                                   %Remove zero-padding
            vc = real(vt .* (sqrt(2) * exp(2i*pi*fc*time))); %Modulator

            %Channel
            rc = vc + sqrt(1/Ts*N0/2)*randn(1, length(vc));  %awgn

            %Receiver
            ro = rc .* (sqrt(2) * exp(-2i*pi*fc*time));      %Demodulator
            rt = conv(ro, hr);                               %Matched filter
            rt = rt(1:Ns);                                   %Remove zero-padding
            rn = downsample(rt, eta, eta-1);
            ah = detect_symbol(rn, modulation_scheme{k});    %Decision device

            num_errors = num_errors + sum(bitxor(a, ah));
        end
        
        fprintf('%d of %d complete\n', i, length(SNRdB));
        if verbose
            fprintf('SNR: %g dB\n', SNRdB(i));
            fprintf('Number of errors: %d\n', num_errors);
            fprintf('Bit error rate: %e\n', num_errors/(Na*Nf));
        end
        sum_errors(k, i) = num_errors;
    end
end

%% Post-processing
% Calculate theoretical BER
theory_BER_BPSK = @(x) qfunc(sqrt(2*10.^(x/10)));
theory_BER_4QAM = @(x) qfunc(sqrt(10.^(x/10)));
% Plot BER vs SNR
semilogy(SNRdB, sum_errors(1,:)/(Na*Nf), 'rx');
hold on;
semilogy(SNRdB, sum_errors(2,:)/(Na*Nf), 'bd');
fplot(theory_BER_BPSK, [SNRdB(1) SNRdB(end)], 'r--');
fplot(theory_BER_4QAM, [SNRdB(1) SNRdB(end)], 'b--');
hold off;
xlabel('E_b/N_0 (dB)');
ylabel('BER');
grid on;
legend('BPSK (Simulation)', '4-QAM (Simulation)', ...
       'BPSK (Theoretical)', '4-QAM (Theoretical)');