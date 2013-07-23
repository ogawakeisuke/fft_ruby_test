require "ruby-audio"
require "narray"
require "fftw3"
require 'cairo'


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
    # うん？やっぱ違うかも
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
  if value < 20
    "."
  elsif value > 20 && value < 150
    "*"
  else
    "#" 
  end
end

def ret_color_rows(compleces)
  ret_array = []
  compleces.each do |complex|
    ret_array << color_pick_print(amp(complex).scale_between)
  end
  ret_array
end

def ret_scale_rows(compleces)
  ret_array = []
  compleces.each do |complex|
    ret_array << amp(complex).scale_between
  end
  ret_array
end


#
# Numericのオーバーライドでスケールメソッド
#
class Numeric
  def scale_between(from_min = 0.0, from_max = 1.0, to_min = 0, to_max = 255)
   ( ((to_max - to_min) * (self - from_min)) / (from_max - from_min) + to_min ).round  # + 1
  end
end


#
# 描画空間
#
format = Cairo::FORMAT_ARGB32
width = 3000
height = 600
radius = 3 # 半径

surface = Cairo::ImageSurface.new(format, width, height)
context = Cairo::Context.new(surface)

# 背景
context.set_source_rgb(1, 1, 1) # 白
context.rectangle(0, 0, width, height)
context.fill

# 赤丸



fft.each_with_index do |compleces, i|
  ret_scale_rows(compleces).each_with_index do |val, j|
    context.set_source_rgb(val, 0, 0)
    context.arc(j, i, radius, 0, 1 * Math::PI)
    context.fill
  end
  p ret_scale_rows(compleces)[299]
  #break #ためしにひとつでbreak
end

surface.write_to_png("hinomaru.png")



