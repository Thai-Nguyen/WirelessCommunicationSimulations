function [ah] = detect_symbol(rn, modulation_scheme)
switch modulation_scheme
case 'BPSK'
    ah = (rn < 0);
case '4QAM'
%     sm = [1+1i -1+1i -1-1i 1-1i]; 
    ah = zeros(1, length(rn));
    for i = 1:2:length(rn)-1
        if real(rn(i)) >= 0 && imag(rn(i)) >= 0
            ah(i:i+1) = [0 0];
        elseif real(rn(i)) < 0 && imag(rn(i)) >= 0
            ah(i:i+1) = [0 1];
        elseif real(rn(i)) < 0 && imag(rn(i)) < 0
            ah(i:i+1) = [1 1];
        elseif real(rn(i)) >= 0 && imag(rn(i)) < 0
            ah(i:i+1) = [1 0];
        end
    end
case '16QAM'
    fprintf('Implement later');
otherwise
    fprintf('Error: Modulation scheme "%s" was not implemented\n', modulation_scheme);
end
end