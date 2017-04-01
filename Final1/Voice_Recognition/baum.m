function hmm=baum(hmm, samples)
% baum-welch training, one loop
%
% inputs :
%  hmm -- hmm model struct
%  samples -- speech sample structure
%
% output :
%  hmm -- hmm structure after training

%%%%%%%%%%%%%%%%%%%

mix = hmm.mix;   %gaussian mixture
N=length(mix);   % number of HMM states
K = length(samples); % number of speech samples
SIZE = size(samples(1).data,2); % order of speech parameter

% Calculate alpha, beta for multi observation
disp('calculate speech parameters...');

for k=1:K
    fprintf('%d',k)
    param(k) = getparam(hmm,samples(k).data);
end

fprintf('\n')

% Reestimate transition probability matrix A : trans
disp('reestimate transition probability matrix A...')
for i = 1:(N-1)
    denom=0;
    for k=1:K
        tmp = param(k).ksai(:,i,:);
        denom=denom+sum(tmp(:) );
    end
    
    for j=i:i+1
        nom=0;
        for k=1:K
            tmp =param(k).ksai(:,i,j);
            nom=nom + sum(tmp(:) );
        end
        %%% Maximized transition probability a_ij
        hmm.trans(i,j)=nom/denom;
    end
end

%reestimate gaussian mixture
disp('reestimate gaussian mixture...')
for l=1:N
    for j=1:hmm.M(l)
        fprintf('%d,%d',l,j)
        
        % Calculate mean and variance for each pdf
        nommean = zeros(1,SIZE);
        nomvar = zeros(1,SIZE);
        denom = 0;
        for k=1:K
            T = size( samples(k).data,1 );
          for t=1:T
                   x = samples(k).data(t,:);
              
                   nommean = nommean + param(k).gamma(t,l,j)*x;
                   nomvar = nomvar+param(k).gamma(t,l,j)*(x-mix(l).mean(j,:) ).^2;
                   denom = denom + param(k).gamma(t,l,j);
          end
        end
          
          %%% Maximizing the 
          hmm.mix(l).mean(j,:) = nommean/denom;
          hmm.mix(l).var(j,:) = nomvar/denom;

          % Calculate the weights of each pdf
          nom=0;
          denom =0;
          
          for k=1:K
               tmp=param(k).gamma(:,l,j);
               nom=nom+sum( tmp(:) );
               tmp=param(k).gamma(:,l,:);
               denom = denom + sum(tmp(:) );
          end
          
          hmm.mix(l).weight(j) =nom/denom;
          
    end
        
  fprintf('\n')
end