%% First created on 2023.08.21, Guan Shixun.

%% ----------------------------------- >parameters
%简单DFT的实现
N = 100;
x = zeros(1,N);
Wn = exp( (-1) * sqrt(-1) * 2 * pi / N);
x1 = randn(1,N);

X1 = zeros(1,N);
for k=1:N
    for n=1:N
        X1(k) = X1(k) + x1(n)*Wn^(n*k);
    end
end
X1_fft = fft(x1);
Deviation = X1_fft - X1;
Total_Deviation = sum(Deviation.^2);
