%% first created on 2023.08.23, by Guan Shixun.
% implement fft iteratively.
% reference https://www.bilibili.com/video/BV1mA411D7Cw/
% modefied 2023.08.24, add a matrix to save calculation results of each
% iteration.
clear;
clc;
%----------------------------------------> parameters
%x = [1 2 -3 -1];
%x       = 0:N-1;

Fs      = 1000;             % Sampling frequency                    
T       = 1/Fs;             % Sampling period
N       = 16384;             % Sampling length
t       = (0:N-1)*T;          % Sampling time
df      = Fs/N;
f       = (0:N-1)*df;
index   = 0:N-1;

%----------------------------------------> generate source
noise_pow = 0.2;
S = 3*sin(2*pi*50*t) + sin(2*pi*120*t);
x = S + noise_pow*randn(size(t));
subplot(3,1,1)
plot(1000*t(1:100),x(1:100)) %这个和采样率有关
title("Signal Corrupted with Zero-Mean Random Noise")
xlabel("t (milliseconds)")
ylabel("X(t)")


%----------------------------------------> bit-reverse
normal_index = index;
reversed_index = bitrevorder(normal_index);
x_bit_reversed = x(reversed_index+1);
%注意 matlab数组下标从1开始
%----------------------------------------> butterfly calculation
levels              = log2(N);
X_FFT               = zeros(1,N);
X_FFT_middle_result = zeros(levels+1, N);
X_FFT_middle_result(1,:) = x;
for level = 1:levels
    %逐级计算
    len = 2^level;
    mid = len / 2;
    Wn = exp(-1j * 2 * pi / len);
    for pos = 1:len:N  % N/len个小段
        for k = 0:mid-1  % 每小段可以分奇偶
            A = x_bit_reversed(pos+k);
            B = x_bit_reversed(pos+k+mid)*Wn^(k);
            x_bit_reversed(pos+k)     = A + B;
            x_bit_reversed(pos+k+mid) = A - B;
        end
    end
    X_FFT_middle_result(level+1,:) = x_bit_reversed;
end

X_FFT = x_bit_reversed;
subplot(3,1,2)
plot(f,abs(X_FFT)) 
title("Spectrum of my fft, DIT")
xlabel("f/Hz")
ylabel("X(f)")


%----------------------------------------> testings
answer      = fft(x);
deviation   = X_FFT - answer;
variance    = var(deviation);
if variance > 1
    fprintf('误差太大了，不对')
end




