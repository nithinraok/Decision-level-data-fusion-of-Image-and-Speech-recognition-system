function [hmm,pout]=train(samples, M,loop_num)
% training of hmm 
% 
% INPUTS :
%  samples -- speech sample structure
%  M -- number of pdfs for each state, eg., [3 3 3 3]
% 
% OUTPUT:
%  hmm     -- hmm structure after training

K = length(samples);

hmm= inithmm(samples, M);

for loop=1:loop_num
    fprintf('\ntraining loop%d\n\n', loop)
    hmm=baum(hmm,samples);
    %calculate total output probability
    pout(loop)=0;
    for k=1:K
        pout(loop)=pout(loop)+viterbi(hmm,samples(k).data);
    end
    fprintf('total output probability (log)=%d\n', pout(loop)  )
    %compare two hmms
    if loop >1
        if abs ( (pout(loop) - pout(loop-1) )/pout(loop) ) < 5e-5
            fprintf('convergence!\n');
            return
        end
    end
end
end %function end