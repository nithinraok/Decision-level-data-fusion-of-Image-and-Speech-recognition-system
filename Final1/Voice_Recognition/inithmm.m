function hmm = inithmm(samples, M)
% initialize hmm parameters
% 
% INPUTS :
%  samples -- speech sample structure
%  M -- number of pdfs for each state, eg., [3 3 3 3] (4 State with 3 pdf
%  for each State )
% 
% OUTPUT:
%  hmm     -- hmm structure after training

% Number of training speech sample set
K =length(samples);

% Number of HMM states
N=length(M);

hmm.N=N;
hmm.M=M;

%intial probability
hmm.init =(1/N)*ones(N,1);
hmm.init(1) =1/N;

% transition probability of State n to n
hmm.trans=zeros(N,N);
for i=1:(N-1)
    hmm.trans(i,i)=0.5;
    hmm.trans(i,i+1)=0.5;
end

hmm.trans(N,N)=1;

% initial cluster of pdfs
% equally segmentation 

for k=1:K
    T=size(samples(k).data,1);
    samples(k).segment=floor( [1:T/N:T, T+1]);
end

% cluster vectors belong to each states using K-means
for i=1:N % FOR ALL STATES
    % Assemble vectors of the same cluster and state into one vector
    vector = [];
    for k=1:K
        seg1=samples(k).segment(i);
        seg2=samples(k).segment(i+1)-1; 
        %%% Same position, different data set !!
        vector = [vector; samples(k).data(seg1:seg2,:)];
    end
    mix(i)=getmix(vector,M(i) ); %% Vector with multiple training set with same segment
end
hmm.mix=mix; % 3 Mixture models for multiple states
end

function mix=getmix(vector,M);
% K-means clustering, and return the mean and variance and weights of pdfs
% 
% INPUTS :
%  vector -- input vectors
%  M -- number of pdfs 
% 
% OUTPUT:
%  mix     -- gaussian mixture structure

[mean1 esq nn]=kmeans(vector,M);

% Calculate variance , in diagonal
for j=1:M
    ind = find(j==nn);
    tmp = vector(ind,:);
    var(j,:) = std(tmp);
    avg(j,:) = mean(tmp);
end

% Get number of vectors for each pdf, and convert into weights
weight = zeros(M,1);
for j=1:M
weight(j) = length(find(j==nn) );    
end

weight = weight/sum(weight);

% return gaussian mixture
mix.M = M;
mix.mean = avg;% M*SIZE
mix.var = var.^2; % M*SIZE
mix.weight = weight; % M*1

end
 %function end