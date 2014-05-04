clear all; close all; clc;

% generate sampel continues data
size1 = 200; 
mean1 = [2,-1];
cov1 = [1,0.1; 0.1,1];
mean2 = [8,3];
cov2 = [1 .2; 0.2,1];
X = [mvnrnd(mean1, cov1, size1); mvnrnd(mean2, cov2, size1)];
Y = [ones(size1,1)  ; -1*ones(size1,1)]; 
order = randperm(400); 
X = X(order,:); 
Y = Y(order,:); 


% cluster : k-means 
k = 2; 
[centroid, pointsInCluster, assignment]= kmeans2(X, k); 
Xtmp = X(Y ==1, :);
plot(Xtmp(:, 1), Xtmp(:, 2), 'xr')
hold on;
Xtmp = X(Y ==-1, :);
plot(Xtmp(:, 1), Xtmp(:, 2), 'xb')
for i = 1:k 
    plot(centroid(i,1), centroid(i,2),'--rs','LineWidth',2,...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',10)
end 


% cluster: dp-means: 
lambda = 7; 
% figure; 
[centroid, pointsInCluster, assignment, clusterSize]= dpmeans(X, lambda); 
figure; 
% Xtmp = X(Y ==1, :);
% plot(Xtmp(:, 1), Xtmp(:, 2), 'xr')
hold on;
% Xtmp = X(Y ==-1, :);
% plot(Xtmp(:, 1), Xtmp(:, 2), 'xb')
for i = 1:clusterSize 
    plot(centroid(i,1), centroid(i,2),'--rs','LineWidth',2,...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',10)
    Xtmp = X(assignment ==i, :);
    plot(Xtmp(:, 1), Xtmp(:, 2), 'x',  'color', rand(1,3))
end


% cluster : dpm 
T = 50; % maximum number of clusters
[gamma, phi, m, beta, s, p] = variational_dpm(X, 20, T, 1);
[maxVal, clusters] = max(phi);
for t = 1:T
    xt = X(clusters == t, :);
    if size(xt) ~= 0
        disp( ['T = ' num2str(t) ' size(xt,1) = ' num2str(size(xt,1)) ' m(t,:) ' num2str(m(t,:)) ])
    end
end

% cluster : dpm-gibs sampling  : 
% Daniel: which algorithm is this? 
dirich = DirichMix; % construct an object of the class
dirich.InputData(X);
dirich.DoIteration(1000); % 100 iterations
dirich.PlotData

% constrained bp-means 

E = zeros(size(Y, 1), size(Y, 1)); 
Checked = zeros(size(Y, 1), size(Y, 1)); 
randSize = 0.01 * size(Y, 1) * size(Y, 1); 
iterAll = 1;
while(1)
    i1 = randi(size(Y, 1)); 
    i2 = randi(size(Y, 1)); 
    if Checked(i1, i2) == 0   
        Checked(i1, i2) = 1;
        if Y(i1) == Y(i2)
            E(i1, i2) = 1; 
        else 
            E(i1, i2) = -1; 
        end
        iterAll = iterAll + 1;
    end 
    if( iterAll > randSize) 
        break;
    end
end

lambda = 7; 
xi = 1; 
% figure; 
[centroid, pointsInCluster, assignment, clusterSize] = constrained_dpmeans_fast(X, lambda, E, xi); 
figure; 
% Xtmp = X(Y ==1, :);
% plot(Xtmp(:, 1), Xtmp(:, 2), 'xr')
hold on;
% Xtmp = X(Y ==-1, :);
% plot(Xtmp(:, 1), Xtmp(:, 2), 'xb')
for i = 1:clusterSize 
    plot(centroid(i,1), centroid(i,2),'--rs','LineWidth',2,...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',10)
    Xtmp = X(assignment ==i, :);
    plot(Xtmp(:, 1), Xtmp(:, 2), 'x',  'color', rand(1,3))
end

