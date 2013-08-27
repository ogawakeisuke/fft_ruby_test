require "ruby-audio"
require "narray"
require "fftw3"
require './regression_line'


fname = "pinknoise.aif"
window_size = 1024
fft = Array.new(window_size / 2).collect { Array.new }


buf = RubyAudio::Buffer.float(window_size)

RubyAudio::Sound.open(fname) do |snd|
  while snd.read(buf) != 0
    na = NArray.to_na(buf.to_a)

    fft_slice = FFTW3.fft(na).to_a[0, window_size / 2]
    fft_slice.each_with_index do |complex, i| 
      fft[i] << complex
    end
  end
end