function y = DFT_original(source)
    % the sourece must be size n*1 
    N = length(source);
    Wn = exp(-1j* 2 * pi / N);   
    n = 0 : N-1;
    k = n';
    power_coefficient = k * n;
    W = Wn^(power_coefficient);
    y = W * source;
end