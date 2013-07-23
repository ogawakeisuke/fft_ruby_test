require "ruby-audio"
require "narray"
require "fftw3"


fname = "dot.wav"
window_size = 1024
wave = Array.new

#
# 512個の空の配列が造られる
#
fft = Array.new(window_size/2,[])


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
    fft_slice = FFTW3.fft(na, -1).to_a[0, window_size/2]


    # fftという配列にfftの結果をぶち込む
    j=0
    fft_slice.each { |x| fft[j] << x; j+=1 }
  end
end


p fft.size
