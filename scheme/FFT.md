## **DFT**

### 定义

$$
X(k)=\sum_{n=0}^{N-1}x(n)W_{N}^{nk} ~~~~~~~~~~0\le k \le N-1\\
x(n)=\frac1N \sum_{k=0}^{N-1}X(k)W_{N}^{-nk}  ~~~~~~~~~~0\le n \le N-1
$$

定义旋转因子$W_{N}=e^{-j \frac{2\pi}{N}}$，改善DFT计算效率的大多数方法用到了其**对称性和周期性**。

**共轭对称性**，解释了为什么FFT的频谱是镜像对称的。
$$
\begin{align}
X(N-k)	&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(N-k)} \\
		&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(-k)}W_{N}^{Nn}\\
		&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(-k)}\\
		&=\bigg(\sum_{n=0}^{N-1}x(n)W_{N}^{nk}\bigg)^{*}\\
		&=X(k)^*~~~~~~~~~~~0\le k \le N-1
\end{align}
$$
**周期性**
$$
\begin{align}
X(N+k)	&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(N+k)} \\
		&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(k)}W_{N}^{Nn}\\
		&=\sum_{n=0}^{N-1}x(n)W_{N}^{n(k)}\\
		&=X(k)~~~~~~~~~~~0\le k \le N-1
\end{align}
$$


### 计算量分析

复数计算：需要N^2^次复数乘法和N(N-1)次复数加法 

实数计算：需要4N^2^次复数乘法和4N(4N-2)次复数加法 

[离散时间信号处理-奥本海姆](chapter9)

性质：离散变换的周期性、镜像对称特性

> ------
>
> 各种语言实现FFT算法https://rosettacode.org/wiki/Fast_Fourier_transform
>

------

## FFT

matlab中的fft：直接看文档，讲的非常详细。注意fft产生的镜像和fftshift等；

### 1. Cooley-Turkey

**Cooley-Turkey算法推导**
$$
\begin{align}
X(k)	&=\sum_{n=0}^{N-1}x(n)W_{N}^{nk}   \\
		&=\sum_{r=0}^{\frac{N}{2}-1}x(2r)W_{N}^{2rk}+\sum_{r=0}^{\frac{N}{2}-1}x(2r+1)W_{N}^{2rk+k}\\
		&=\sum_{r=0}^{\frac{N}{2}-1}x(2r)W_{\frac N2}^{rk}+W_{N}^{k}\sum_{r=0}^{\frac{N}{2}-1}x(2r+1)W_{\frac N2}^{rk}\\

		&=A(k)+W_{N}^{k}B(k)~~~~~~~~~~0\le k \le \frac N2-1
\end{align}
$$

其中A(k)，B(k)分别代表原序列中的even 和  odd项，并且以$\frac{N}{2}$为周期。
$$
\begin{align}

A(k) &= \sum_{r=0}^{\frac{N}{2}-1}x(2r)W_{\frac N2}^{rk}=A((k)_{\frac N2})\\
B(k) &= W_{ N}^{k}\sum_{r=0}^{\frac{N}{2}-1}x(2r+1)W_{\frac N2}^{rk}=B((k)_{\frac N2})

\end{align}
$$

所以有
$$
\begin{align}
X(k)	
&=\sum_{n=0}^{N-1}x(n)W_{N}^{nk}   \\
&=A(k)+W_{N}^{k}B(k)~~~~~~~~~~0\le k \le \frac N2-1 \\

X(k+\frac N2)	
&=\sum_{n=0}^{N-1}x(n)W_{N}^{nk}   \\
&=A(k +\frac N2)+W_{N}^{k+\frac N2}B(k+\frac N2)\\
&=A(k)-W_{N}^{k}B(k)
~~~~~~~~~~0\le k \le \frac N2-1
\end{align}
$$
可以得知, 原有的**N点DFT**可以拆分为$k_1 \in [0, \frac{N}{2}-1]$和$k_2 \in [\frac{N}{2}, N-1]$上下两个半边 ,  通过计算**两段点数为 N/2 点的FFT**  $A(k),B(k), k\in[0, \frac{N}{2}-1]$ , 即可获取N点DFT. 

- N点分为 N/2点
- N/2 点分为 N/4 点
- N/4 点分为 N/8 点
- ... 持续分割,直到分割至单点为止.

==总结==: FFT采用一种递归的思想, 





### 2. bit-reverse

1. 原理分析

   末位0，表示偶数，末位1，表示奇数；经过逐级的分解，最后就形成了相应的倒序表示。

   > 参考1[离散时间信号处理-奥本海姆](chapter9)
   >
   > 参考2 https://www.bilibili.com/video/BV1Y7411W73U/

2. 代码实现

   > 参考1:  https://graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
   >
   > 参考2:  https://www.bilibili.com/video/BV1Y7411W73U/

   ```C
       for (m=1; m<NUM_SAMPLES_M_1; m++) {
           // swap odd and even bits
           mr = ((m >> 1) & 0x5555) | ((m & 0x5555) << 1);
           // swap consecutive pairs
           mr = ((mr >> 2) & 0x3333) | ((mr & 0x3333) << 2);
           // swap nibbles ... 
           mr = ((mr >> 4) & 0x0F0F) | ((mr & 0x0F0F) << 4);
           // swap bytes
           mr = ((mr >> 8) & 0x00FF) | ((mr & 0x00FF) << 8);
           // shift down mr
           mr >>= SHIFT_AMOUNT ;
           // don't swap that which has already been swapped
           if (mr<=m) continue ;
           // swap the bit-reveresed indices
           tr = fr[m] ;
           fr[m] = fr[mr] ;
           fr[mr] = tr ;
           ti = fi[m] ;
           fi[m] = fi[mr] ;
           fi[mr] = ti ;
       }
   ```

### 3. 原址计算

暂略



流图的实际意义，画一画

计算量分析，推一推

例子：`x = [1 2 -3 -1]  --->X = [-1, 4-3j, -3, 4+3j]，动手推导整体的更新过程`

> fft算法是一种使用分而治之思想的算法。



代码实现：for循环，层数、同址运算等



总的来说：先求子序列的傅里叶变换，再对其进行求和

需要注意的细节：子序列长度为N/2，是一个循环序列；旋转因子的周期性 ；补零的影响；  

以8点fft为例，最终求得FFT结果为[X_e+W X_o, X_e - W X_o]





### 4. 计算量分析

1. Cooley turkey 算法可以拆分为  $log_{2}N$级, 每一级都需要做N次复数乘法, 所以计算量级别为$Nlog_{2}N$
2. 最终输出的频率计算结果需要进行倒序操作, 所需时间不超过$nlog_2N$
3. 总的计算复杂度为 $O(log_2N)$



##ef

https://vanhunteradams.com/FFT/FFT.html#Exponential-form-of-the-series






