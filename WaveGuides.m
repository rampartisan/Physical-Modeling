%% Plucked String Waveguide .
[x,SFs] = audioread('Taylor314ce.wav');
% Sample Rate
Fs = 44100;
% String Freq
Fc = 108;
% Total delay line length
N = floor(Fs/Fc);
% Pluck Pos
Pp = 0.8;
NPp = floor(N * Pp);
% PickUp Pos
Pu = 0.2;
NPu = floor(N * Pu);
% init left and right delays with triangle input, centre at pluck pos
% [yl,yr,in] = deal(conv([[0:NPp]/NPp,(N-[(NPp+1):N])/(N-NPp)],x,'same'));
[yl,yr,in] = deal(([[0:NPp]/NPp,(N-[(NPp+1):N])/(N-NPp)]));

% init output
y = yl(NPu) + yr(NPu);

% set ups for while loop / amp estimation params
v = true;
i = 1;
windowSize = 1024;
thresh = 0.01;

% LPF Coeff (0 - 0.5)
LC = 0.493;
% APF coeff (0 - 0.5)
g = 0.1;

while v
    % lpf + apf
    lpr = LC*yl(end-floor(N/2)) + LC*yl(end-floor(N/2)+1);
    lpl = LC*yr(end-floor(N/2)) + LC*yr(end-floor(N/2)-1);
    
    % Apf
     apr = -(g*yl(end-floor(N/2))) + yl(end-floor(N/2)+1) ...
         + g*yl(end-floor(N/2)+1);
     apl = -(g*yr(end-floor(N/2))) + yr(end-floor(N/2)-1) ...
         + g*yr(end-floor(N/2)-1);
   
    % sum of filters
    yr(end) = (-lpr + -apr) * 0.5;
    yl(end) = (-lpl + -apl) * 0.5;
    
    % shift wave left or right
    yr = circshift(yr,[0 1]);
    yl = circshift(yl,[0 -1]);
    
    % read wave at pickup position
    y = [y (yl(NPu) + yr(NPu))];
    
if i > windowSize
   amp = mean(abs(y(i-windowSize:i)))
   if amp < thresh;
    v = false;   
   end
end

i = i+1;

end


figure;
subplot(2,1,1);
plot(in);
title('Input - Triangle convolved with body IR');
xlabel('Time');
ylabel('Amp');
subplot(2,1,2);
plot(y);
title('Output');
xlabel('Time');
ylabel('Amp');


soundsc(y,Fs); 

