%takes user utterance and saves as .wav file
%audio data to be used for training

user_entry = input('Enter number : ','s');
for i = 31:40
	show = sprintf('Set %d\n',i);
	disp(show);
	recObj = audiorecorder;
	prompt = sprintf('Say keyword\n');
	disp(prompt);
	recordblocking(recObj,5);
	y = getaudiodata(recObj);
	y(y==0) = [];
	filename = strcat('num',user_entry,'set',num2str(i));
	wavwrite(y,8000,16,filename);
end