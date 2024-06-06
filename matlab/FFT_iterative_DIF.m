%% first created on 2023.08.24, by Guan Shixun.
% implement fft-DIF iteratively.
clear;
clc;
%----------------------------------------> parameters
%x = [1 2 -3 -1];
%x       = 0:N-1;
Fs      = 1000;             % Sampling frequency                    
T       = 1/Fs;             % Sampling period
N       = 1024;             % Sampling length
t       = (0:N-1)*T;          % Sampling time
df      = Fs/N;
f       = (0:N-1)*df;
index   = 0:N-1;
%----------------------------------------> generate source
noise_pow = 0.2;
S = 3*sin(2*pi*50*t) + sin(2*pi*120*t);
x = S + noise_pow*randn(size(t));
subplot(3,1,1)
plot(1000*t(1:100),x(1:100))
title("Signal Corrupted with Zero-Mean Random Noise")
xlabel("t (milliseconds)")
ylabel("X(t)")


%----------------------------------------> FFT-DIF
%x                   = 0:N-1;
levels              = log2(N);
X_FFT               = zeros(1,N);
X_FFT_middle_result = zeros(levels+1, N);
X_FFT_middle_result(1,:) = x;
for level = 0:levels-1
    len = 2^(levels-level);
    mid = len / 2;
    Wn  = exp(-1j * 2 * pi / len);
    for pos = 1:len:N
        for k = 0:mid-1
            A = x(pos+k) + x(pos+k+mid);
            B = (x(pos+k) - x(pos+k+mid))*Wn^(k);
            x(pos+k) = A;
            x(pos+k+mid)  = B;
        end
    end
    X_FFT_middle_result(level+2,:) = x;
end

%----------------------------------------> bit-reverse
normal_index = index;
reversed_index = bitrevorder(normal_index);

%----------------------------------------> final result
X_FFT(reversed_index+1) = x;

subplot(3,1,2)
plot(f,abs(X_FFT)) 
title("Spectrum of my fft, DIF")
xlabel("f/Hz")
ylabel("X(f)")

