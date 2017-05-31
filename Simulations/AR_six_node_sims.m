%%%%%%%% Six node network simulations -----------------------------------
clear all;
%%% Define model inputs ------------------------------------------------
global s
s = 0.1;

global nsurrogates;
nsurrogates = 5000;

T = 5;      % total length of recording (seconds)
dt = 0.001; % seconds
model_order = 40; % order used in model estimation
f0 = 1/dt;  % sampling frequency (Hz)
N = T*f0+model_order;   % number of samples needed
df = 1/T;   % frequency resolution
fNQ = f0/2; % Nyquist frequency

taxis = dt:dt:T; % time axis
noise = 0.25;
nelectrodes = 6;
%%% Model coefficients
data = zeros(6,N);
a1 = 0.07*[0.1*hann(20)', -0.5*ones(20,1)']';
a2 = 0.03*[-0.5*ones(20,1)', hann(20)']';    
%a3 = -0.3*ones(size(a1));
a3 = -.3*sin(1:40)./(1:40); 
%a3 = -.3*sin(.5:.5:20)./(.5:.5:20);
a4 = 0.02*[hann(30)', -1*ones(1,10)]';
%a4 = 0.02*[hann(30)', -0.2*ones(1,10)]';
a5 = 0.1*[-0.8*ones(1,30), -0.8*hann(10)']';
a6 = 0.25*[-0.6*ones(20,1)', -0.2*hann(20)']'; 

a = zeros(6,6,model_order);
a(1,1,:) = a1;
a(1,2,:) = a2;
a(2,2,:) = a1;
a(2,4,:) = a4;
a(3,3,:) = a3;
a(3,4,:) = a2;
a(4,4,:) = a4;
a(5,2,:) = a5;
a(5,5,:) = a4;
a(6,6,:) = a6;
a(6,3,:) = a4;
adj_true = [1 1 0 0 0 0; 0 1 0 1 0 0; 0 0 1 1 0 0; 0 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1];  

nlags = length(a1);

%%% Simulate data ------------------------------------------

for k = nlags:length(data)-1;
    data(:,k+1) = myPrediction(data(:,1:k),a);

    data(:,k+1) = data(:,k+1) + noise.*randn(size(data,1),1);

end
data = data(:,nlags+1:end);
%mvar_aic;

subplot(2,3,[1 3])
for i = 1:6
   plot(data(i,:));
 hold on; 
end

ylabel('Signal')
xlabel('Time (seconds)')

title('Simulated Signal','FontSize',15);
%%


%%% Fit standard AR to data ----------------------------------------------
tic
[ adj_standard] = build_ar( data, model_order);
standardtime = toc;

%%% Fit spline to data ---------------------------------------------------

cntrl_pts = make_knots(model_order,10);
tic
[ adj_mat] = build_ar_splines( data, model_order, cntrl_pts );
splinetime = toc;

[ bhat, yhat ] = estimate_coefficient_fits( data, adj_mat, model_order, cntrl_pts);


%%% Plot results ----------------------------------------------------------

subplot(2,3,4)
plotNetwork(adj_true)
title('True Network')

subplot(2,3,5)
plotNetwork(adj_standard)
title(strcat({'Standard, '},num2str(standardtime),{' s'}))


subplot(2,3,6)
plotNetwork(adj_mat)
title('Spline Network')
title(strcat({'Spline, '},num2str(splinetime),{' s'}))

%%% Goodness of fit -------------------------------------------------------
b=a; 
mvar_aic;

Sampling_Frequency = f0;
Noise_Variance = noise.^2;
T_seconds = T;
Model_Order = nlags;
Estimated_Order = model_order;
Tension_Parameter = s;
Tp = table(Sampling_Frequency,Noise_Variance,T_seconds,Model_Order,...
    Estimated_Order,Tension_Parameter,moAIC,moBIC);

figure;
uitable('Data',Tp{:,:}','RowName',Tp.Properties.VariableNames,...
    'Units', 'Normalized', 'Position',[0,0,1,1]);


%%% Plot all results --------------------------------------------
% Save all simulation and table plots ---------------------------
% h = get(0,'children');
% j=1;
% for i=length(h):-1:1
%     saveas(h(j), ['6N_summaryplot'   num2str(i)], 'jpg');
%     j=j+1;
% end
% close all
% 
% % Spectral GoF --------------------------------------------------
% goodness_of_fit_spectrum;
% h = get(0,'children');
% j=1;
% for i=length(h):-1:1
%     saveas(h(j), ['6N_e'   num2str(i) '_spectrum'], 'jpg');
%     j=j+1;
% end
% close all
% 
% % Boostrap GoF --------------------------------------------------
% goodness_of_fit_bootstrap;
% h = get(0,'children');
% j=1;
% for i=length(h):-1:1
%     saveas(h(j), ['6N_e'   num2str(i) '_bootstrap'], 'jpg');
%     j=j+1;
% end
% close all

 goodness_of_fit_bootstrap;
 goodness_of_fit_spectrum;