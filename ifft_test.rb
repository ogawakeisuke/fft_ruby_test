require "pp"
require "ruby-audio"
require "narray"
require "fftw3"
require './regression_line'


fname = "src/pinknoise.aif"
window_size = 1024
fft = Array.new(window_size / 2).collect { Array.new }



#
# https://github.com/jes5199/music-experiment/blob/master/util.rb
#
def fft_to_file( fft, filename, size, info )
  result_data = FFTW3.ifft( fft )
  data_to_file( result_data, filename, size, info, result_data.size )
end

def data_to_file( data, filename, size, info, scale )
  result_buffer = RubyAudio::Buffer.new("float", size, 1)
  i = 0
  data.each do |r|
    result_buffer[i] = (r.respond_to?(:real) ? r.real : r.to_f) / scale
    i += 1
  end
  p result_buffer.to_a
  buffer_to_file( result_buffer, filename, info )
end

def buffer_to_file( buffer, filename, info)
  output = RubyAudio::Sound.new(filename, "w", info)
  output.write(buffer)
  output.close
end




buf = RubyAudio::Buffer.float(window_size)

RubyAudio::Sound.open(fname) do |snd|
  while snd.read(buf) != 0
    na = NArray.to_na(buf.to_a)

    fft_slice = FFTW3.fft(na).to_a[0, window_size / 2]


    # fft_slice.each_with_index do |complex, i| 
    #   fft[i] << complex
    # end

    fft_to_file( fft_slice, "test.wav", 1024,  RubyAudio::SoundInfo.new(:channels => 1, :samplerate => 44100, :format => RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16) )
  end
end

