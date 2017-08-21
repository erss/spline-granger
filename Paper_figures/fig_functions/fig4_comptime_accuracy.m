%%%% lag v comp time & accuracy
clear all;
%% Define loop parameters
load('b_standard_order35_rdi.mat')
model_coeff_35  = b;
ntrials = 100;
model_order_vals = [5:5:50];%[4 10 15 20 25 30 35 40 45 50 70 100];
    T = [2 4 8];
    time_results_spline = zeros(ntrials,length(model_order_vals),length(T));
    time_results_standard = zeros(ntrials,length(model_order_vals),length(T));
    
    accuracy_stand = zeros(ntrials,length(model_order_vals),length(T));
    accuracy_spline = zeros(ntrials,length(model_order_vals),length(T));
for time = 1:3



              fprintf(['WINDOW SIZE: ' num2str(T(time)) ' \n']);
    %% Declare results

    %% Set up sim
    % use nine node 20 lag in config : nine_node_order20_rdi;
    config_spline;
    model_true.noise_type = 'white';
    model_true.T = T(time);   % time in seconds of window
    taxis = (1/model_true.sampling_frequency):(1/model_true.sampling_frequency):model_true.T;
    model_true.taxis = taxis;
    model_true.true_coefficients = model_coeff_35;
    model_true.model_coefficients = model_true.true_coefficients;   
    %true adjacency matrix
    adj_true = model_true.true_coefficients;
    adj_true(adj_true~=0)=1;
    adj_true=sum(adj_true,3);
    adj_true(adj_true~=0)=1;
    
    %% Loop through every trial
    for ii = 1:ntrials
        
        %%% Simulate data
        model_true.data = simulate_data(model_true);
        
        
        for kk = 1:length(model_order_vals)
            
            model_order = model_order_vals(kk); % order used in model estimation
            model_true.estimated_model_order = model_order;
            if model_order == 4
                model_true.cntrl_pts = make_knots(4,3);
            elseif model_order == 10
                model_true.cntrl_pts  = make_knots(10,4);
            else
                model_true.cntrl_pts  = make_knots(model_order,floor(model_order/3));
            end
            
            tic
            [ adj_standard] = build_ar( model_true);
            standardtime  = toc;
            
            tic
            [ adj_mat] = build_ar_splines( model_true );
            splinetime  = toc;
            
            [accstand]= network_accuracy(adj_true,adj_standard);
            [accspline] = network_accuracy(adj_true,adj_mat);
            
            
            time_results_spline(ii,kk,time) = splinetime;
            time_results_standard(ii,kk,time) = standardtime;
            
            accuracy_stand(ii,kk,time) = accstand;
            accuracy_spline(ii,kk,time) = accspline;
        end
        fprintf([num2str(ii) ' \n']);
    end
    
    
    %% plot everything
%     figure;
%     subplot 211
%     [mn, sem] = confidencebds(time_results_standard(:,:,time));
%     A=shadedErrorBar(model_order_vals,mn, 2*sem, '-*b' , 1);
%     hold on;
%     [mn, sem] = confidencebds(time_results_spline(:,:,time));
%     B=shadedErrorBar(model_order_vals,mn, 2*sem, '-*r' , 1);
%     h=legend([A.mainLine,B.mainLine],'Standard','Spline');
%     set(h,'FontSize',13)
%     
%     title('Computation Time vs Lags','FontSize',15)
%     xlabel('Lag','FontSize',13)
%     ylabel('Computation Time (s)','FontSize',13)
%     
%     subplot 212
%     [mn, sem] = confidencebds(accuracy_stand(:,:,time));
%     A=shadedErrorBar(model_order_vals,mn, 2*sem, '-*b' , 1);
%     hold on;
%     [mn, sem] = confidencebds(accuracy_spline(:,:,time));
%     B=shadedErrorBar(model_order_vals,mn, 2*sem , '-*r' , 1);
%     title('Accuracy vs Lags','FontSize',15)
%     xlabel('Lag','FontSize',13)
%     ylim([0 1])
%     ylabel('Accuracy','FontSize',13)
%     h=legend([A.mainLine,B.mainLine],'Standard','Spline');
%     set(h,'FontSize',13)
%     
%     suptitle(num2str(T(time)));
end

%% Plot on top 
figure;
 s1 = {'--og','--*g','--sg'};
  s2 = {'--or','--*r','--sr'};
  
subplot 211
t=1;
    [mn, sem] = confidencebds(time_results_standard(:,:,t));
    A=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(time_results_spline(:,:,t));
    B=shadedErrorBar(model_order_vals,mn, 2*sem, s2(t) , 1);
t=2;
    [mn, sem] = confidencebds(time_results_standard(:,:,t));
    A2=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(time_results_spline(:,:,t));
    B2=shadedErrorBar(model_order_vals,mn, 2*sem, s2(t) , 1);
t=3;
    [mn, sem] = confidencebds(time_results_standard(:,:,t));
    A3=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(time_results_spline(:,:,t));
    B3=shadedErrorBar(model_order_vals,mn, 2*sem, s2(t) , 1);
    a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'fontsize',16)
    
    
    
    
    h=legend([A.mainLine,B.mainLine,A2.mainLine,B2.mainLine,A3.mainLine,B3.mainLine],'Two Seconds- Standard','Two Seconds- Spline','Four Seconds- Standard','Four Seconds- Spline','Eight Seconds- Standard','Eight Seconds- Spline');
    set(h,'FontSize',13)
    title('Computation Time ','FontSize',20)
    xlabel('Estimated Model Order','FontSize',18)
    ylabel('Computation Time (s)','FontSize',18)
    xlim([model_order_vals(1) model_order_vals(end)])
subplot 212

t = 1;
    [mn, sem] = confidencebds(accuracy_stand(:,:,t));
    A=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(accuracy_spline(:,:,t));
    B=shadedErrorBar(model_order_vals,mn, 2*sem , s2(t) , 1);
t = 2;
    [mn, sem] = confidencebds(accuracy_stand(:,:,t));
    A2=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(accuracy_spline(:,:,t));
    B2=shadedErrorBar(model_order_vals,mn, 2*sem , s2(t) , 1);
t = 3;
    [mn, sem] = confidencebds(accuracy_stand(:,:,t));
    A3=shadedErrorBar(model_order_vals,mn, 2*sem, s1(t) , 1);
    hold on;
    [mn, sem] = confidencebds(accuracy_spline(:,:,t));
    B3=shadedErrorBar(model_order_vals,mn, 2*sem , s2(t) , 1);
    title('Accuracy','FontSize',20)
    xlabel('Estimated Model Order','FontSize',18)
    ylim([0 1])
    ylabel('Accuracy','FontSize',18)
    h=legend([A.mainLine,B.mainLine,A2.mainLine,B2.mainLine,A3.mainLine,B3.mainLine],'Two Seconds- Standard','Two Seconds- Spline','Four Seconds- Standard','Four Seconds- Spline','Eight Seconds- Standard','Eight Seconds- Spline');
    set(h,'FontSize',13)
        xlim([model_order_vals(1) model_order_vals(end)])

    a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'fontsize',16)
%%

%%% Save
save('fig4_comptimes_accuracy_data')
h = get(0,'children');
for i=1:length(h)
    saveas(h(i), ['fig4_ctime'  num2str(i) 'lowfreq'], 'fig');
    
    
    
end
close all;
