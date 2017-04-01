function prob=mixture(mix,x)
%Calculate output probability
%
% INPUTS:
%  mix -- gaussian mixture
%  x -- input vector, SIZE*1
%
% OUTPUT:
%  prob -- output probability

prob=0;

% disp('Mix.M')
% mix.M
% mix.var
for j=1:mix.M
    m=mix.mean(j,:);
    %v=diag (mix.var(j,:));		
    %here
    %0.0001*eye(16)
    v = diag(mix.var(j,:)); %+ (0.0001 * eye(16));	%here
    %till here
    w=mix.weight(j);
%  prob=prob + w*sum(pdf('Normal',x,m,v) );
% disp('pdf input data')
% x
% m
% v

tmp=w*( (mvnpdf(x,m,v) ) );

if  tmp < -1e-50
      tmp =-1e-50;
end
 
prob=prob + tmp;
%  x
% m
% v
%  prob

 
end
% prod(pdf('Normal',x,m,v) )
% Prevent from overflow in viterbi.m whel calling log(prob)
if prob ==0, prob=realmin; end