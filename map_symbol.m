function [vn] = map_symbol(a, modulation_scheme)
% MAP_SYMBOL
% 

switch modulation_scheme
    case 'BPSK'
        sm = [1 -1];
        vn = sm(a+1);
    case '4QAM'
        sm = [1+1i -1+1i -1-1i 1-1i]; 
        vn = zeros(1, length(a));
        
        symbols = [0 0;
                   0 1;
                   1 1;
                   1 0];
           
       for i = 1:2:length(a)-1
           for j = 1:length(sm)
               if isequal(a(i:i+1), symbols(j,:))
                   vn(i:i+1) = sm(j);
               end
           end
       end
    case '16QAM'
        fprintf('To be implemented');
%         sm = 1;
%         vn = zeros(1, length(a));
%         
%         symbols = [0 0 0 0;
%                    0 0 0 1;
%                    0 0 1 1;
%                    0 0 1 0;
%                    0 1 1 0;
%                    0 1 0 0;
%                    1 1 0 0;
%                    ]
%         for i = 1:4:length(a)-3
%             for j = 1:length(sm)
%                 if isequal(a(i:i+3), symbols(j,:))
%                     vn(i:i+3) = sm(j);
%                 end
%             end
%         end
    otherwise
        error('Error: Modulation scheme "%s" was not implemented', modulation_scheme);
end