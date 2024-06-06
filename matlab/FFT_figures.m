%直观理解FFT相关的各种参数
N       = 16;
n       = 0:N-1;

%% 旋转因子
Wn = exp(-1j * 2 * pi /N).^n;
scatter(real(Wn),imag(Wn));
