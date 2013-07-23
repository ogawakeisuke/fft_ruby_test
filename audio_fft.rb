require "ruby-audio"
require "narray"
require "fftw3"


fname = "dot.wav"
window_size = 1024
wave = Array.new

#
# 512個の空の配列が造られる
#
fft = Array.new(window_size / 2,[])


#
# 恐らく1024フレームのバッファを確保している、という扱いのオブジェクト
#
buf = RubyAudio::Buffer.float(window_size)

RubyAudio::Sound.open(fname) do |snd|
  # バッファ分、sndが尽きるまでどんどん読み込む
  while snd.read(buf) != 0
    
    # 恐らく、bufはread()されると値をread分の値を勝手に格納するんじゃ
    #　これはただのシグナルを配列にぶっ込む感じですね　このたやすさの時点ですごいけど
    wave.concat(buf.to_a)

    # ヌーメリック配列でおk
    na = NArray.to_na(buf.to_a)

    # fftしてまるめこんだのを用意するところ
    fft_slice = FFTW3.fft(na, -1).to_a[0, window_size / 2]

    # fftという配列にfftの結果をぶち込む
    # fft配列は512個、ここに時間ベースで値が入って行く！
    # つまりfft[]が周波数、そこのインデックスが時間ベース
    j = 0
    fft_slice.each do |x| 
      fft[j] << x 
      j += 1 
    end
  end
end

def window_size
  1024
end

def amp(complex)
  complex.abs / (window_size / 2)
end


def color_pick_print(value)
  if value < 100
    "."
  elsif value > 100 && value < 180
    ":"
  else
    "#" 
  end
end



#
# Numericのオーバーライドでスケールメソッド
#
class Numeric
  def scale_between(from_min = 0.0, from_max = 1.0, to_min = 0, to_max = 255)
    ((to_max - to_min) * (self - from_min)) / (from_max - from_min) + to_min
  end
end



fft.each do |compleces|
  compleces.each do |complex|
    p color_pick_print( amp(complex).scale_between )
  end
end


