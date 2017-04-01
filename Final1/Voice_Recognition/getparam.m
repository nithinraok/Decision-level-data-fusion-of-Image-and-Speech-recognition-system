function param = getparam(hmm, O)
% for given observation O, calculate alpha, beta, c ksai and gamma
%
% INPUTS :
%  O -- T*D observation sequence 
% 
% OUTPUT :
%  param -- parameters calculated are assembled into a structure
eps=1e-200;
% O
T=size(O,1); %length of observation, in frames

init=hmm.init; %initial probability
trans = hmm.trans; % transition probability
mix =hmm.mix; % gaussian mixture
N = hmm.N; % Number of HMM states

%for given observation O, calculate foward probability alpha
alpha = zeros(T,N);

%alpha for t=1
x=O(1,:);

% size(mix)
% size( init(1) )
% size( mixture(mix(1),x) )
% N %Number of state
for i=1:N

    alpha(1,i) = init(i)*mixture(mix(i),x);

end

% scale alpha for t=1
c=zeros(T,1);
c(1) = 1 / sum(alpha (1,:) ) ;
alpha(1,:) = c(1) *alpha(1,:);

d=zeros(T,1);
% d(T) = 1 / sum(beta (1,:) ) ;
% beta(1,:) = d(T) *beta(1,:);


%alpha and scaling for t=2:T
for t=2:T
    for i=1:N
        temp=0;
        for j=1:N
            temp=temp + alpha(t-1,j) * trans(j,i);
        end
        alpha(t,i)= temp * mixture(mix(i),O(t,:) );
        
    end
    c(t)=1/sum(alpha(t,:) );
    alpha(t,:) =c(t)*alpha(t,:)+ eps;
end

%For given observation O, calculate backward probability beta
beta =zeros(T,N);

% beta and scaling for t=T
for l=1:N
%     beta(T,1)=c(T);
    beta(T,l)=1;
end

% beta and scaling for t=T-1:1
for t=(T-1):-1:1
    x=O(t+1,:);
    for i=1:N
        for j=1:N
            beta(t,i)=beta(t,i)+beta(t+1,j)*mixture(mix(j),x)*trans(i,j);
        end
    end
    d(t)=1/sum(beta(t,:) );
    beta(t,:)=d(t)*beta(t,:)+eps;

end

% ksai
ksai = zeros(T-1,N,N);
for t=1:(T-1)
    denom = sum(alpha(t,:).*beta(t,:) );
    for i=1:(N-1)
        for j=i:(i+1)
            nom = alpha(t,i)*trans(i,j)*mixture(mix(j),O(t+1,:) )*beta(t+1,j);
            ksai(t,i,j)=c(t)*nom/denom;
        end
    end
end

% gamma
gamma =zeros(T,N,max(hmm.M) );
for t=1:T
    pab=zeros(N,1);
    for l=1:N
        pab(l) = alpha(t,l)*beta(t,l);
%        str=sprintf(' alpha %d and beta %d \n',  alpha(t,l), beta(t,l) )

    end
    X=O(t,:);
    for l=1:N
        prob = zeros(mix(l).M,1);
        for j=1:mix(l).M
            m=mix(l).mean(j,:);
            v=mix(l).var(j,:);
            prob(j) = mix(l).weight(j)*( mvnpdf(x,m,v) ) +eps; %pdf('Normal',x,m,v) );
%            prob(j)
        end
        tmp=pab(l)/sum(pab);
%        str=sprintf(' pab %d and sumpab %d ',    pab(l), sum(pab) )
%         disp(str)
%          pab(l)
%          sum(pab)
        for j=1:mix(l).M
            gamma(t,l,j)=tmp*prob(j)/sum(prob) + eps;
%    sprintf(' tmp %d , prob %d , gamma %d \n',  tmp,prob(j), gamma(t,l,j) )
   
        end
    end
end
            
param.c=c;
param.alpha=alpha;
param.beta=beta;
param.ksai = ksai;
param.gamma=gamma;
%......