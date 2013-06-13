#
# 簡単なfftとのこと　
#
def fft(a)
  n = a.size
  return a if n == 1
  w = Complex.polar(1, -2 * Math::PI / n)
  a1 = fft((0 .. n / 2 - 1).map {|i| a[i] + a[i + n / 2] }) #サイズに基づいた
  a2 = fft((0 .. n / 2 - 1).map {|i| (a[i] - a[i + n / 2]) * (w ** i) })
  a1.zip(a2).flatten
end


#
# 波のサンプル サンプル数?は64
# フーリエの計算としてここが2の乗数でなければダメらしい
#

def sample_wave(rate = 64)
  arr = (0...rate).map do |n|
    Math.sin(2 * 2 * Math::PI * n / rate) * 2
    # v + Math.cos(4 * 2 * Math::PI * n / rate) #　加算合成してる
  end
  return arr
end


#
# 条件となる波形
# 
def factor_wave(rate = 2048)
  
  # よく分からんサンプル条件係数。
  # 2048サンプルなら1.0
  # 4096サンプルなら2.0
  sample_factor = 1.0 
  arr = (0...rate).map do |n|
    value = n * 2.0 * sample_factor / (rate)
    p value
    v = Math.cos(Math.asin(value))
    v * 100
  end
  return arr
end



#
# #で波(配列)を描画する力ワザメソッド
#
def display_array(arr)
  arr.map do |v|
    s = [" "] * 20
    min, max = [(-v * 3 + 10).round, 10].sort
    s[min..max] = ["."] * (max - min)
    s
  end.transpose.each do |l|
    puts l.join
  end
end

#
# 意味のある情報は配列の前半だけ
# 0 番目の値も無視する
# 値は複素数になっているので大きさ (v.abs) をとる
# (N / 2) で割った値がその周波数の強さ
# ちなみに位相の情報は偏角 (v.angle) として入っているらしい (あんま見てない)
#
def put_fft_response(arr, rate)
  fft(arr)[0, rate/2].each_with_index do |v, n|
    p "%2d Hz: %3f"%[n,v.abs/(rate/2)]
  end
end

p factor_wave
# put_fft_response(sample_wave, 64)
# p fft(sample_wave)




