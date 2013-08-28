require "pp"
require "ruby-audio"
require "narray"
require "fftw3"
require './regression_line'


#
# https://github.com/jes5199/music-experiment/blob/master/util.rb
#
def fft_to_buffer( fft, size )
  result_data = FFTW3.ifft( fft )
  data_to_buffer( result_data, size, result_data.size )
end

def data_to_buffer( data, size, scale )
  result_buffer = RubyAudio::Buffer.new("float", size, 1)
  i = 0
  data.each do |r|
    result_buffer[i] = (r.respond_to?(:real) ? r.real : r.to_f) / scale
    i += 1
  end
  result_buffer.to_a
end

def buffer_to_file( buffer, filename, info)
  output = RubyAudio::Sound.new(filename, "w", info)
  output.write(buffer)
  output.close
end

def sound_info
  RubyAudio::SoundInfo.new(:channels => 1, :samplerate => 44100, :format => RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16)
end


def ifft_process(fft_val)
  buffer_array = []
  regurate_size = fft_val.last.size
  
  fft_val.each_with_index do |fft_array,i|
    fft_val[i] = fft_array[0, regurate_size]
  end

  fft_val.transpose.each do |fft_bin_values|
    
    buffer_array << fft_to_buffer( fft_bin_values.flatten, 1024 )
  end
  return buffer_array
end

def filing_proccess(buffer_array)
  sound_data = buffer_array.flatten
  p sound_data.size
  data_result_buffer = RubyAudio::Buffer.new("float", sound_data.size, 1)
  i = 0
  sound_data.each do |r|
    data_result_buffer[i] = (r.respond_to?(:real) ? r.real : r.to_f)
    i += 1
  end

  buffer_to_file(data_result_buffer, "test2.wav", sound_info)
end

def shuffle_process(fft_val)
  fft_val.each_with_index do |fft_array, i|
    fft_val[i] = fft_array.shuffle
  end
  fft_val
end


def parallel_rect_shuffle(matrix_array, rect_size = 50)
  x_lenge = matrix_array.last.size - rect_size
  y_lenge = matrix_array.size - rect_size
  start_x, goal_x, start_y =  rand(x_lenge), rand(x_lenge), rand(y_lenge)

  matrix_array[start_y..(start_y + rect_size)].each do |columns|
    columns[start_x..(start_x + rect_size)], columns[goal_x..(goal_x + rect_size)] =  columns[goal_x..(goal_x + rect_size)], columns[start_x..(start_x + rect_size)]
  end
  matrix_array
end


def random_rect_replace(matrix_array, rect_size = 100)
  x_lenge = matrix_array.last.size - rect_size
  y_lenge = matrix_array.size - rect_size
  start_x, goal_x, start_y, goal_y =  rand(x_lenge), rand(x_lenge), rand(y_lenge), rand(y_lenge)

  start_rect = Array.new(rect_size).collect { Array.new }
  goal_rect = Array.new(rect_size).collect { Array.new }
  ofset_rect_size = rect_size -1
  #
  # get startand goal lect
  #
  matrix_array[(start_y)..(start_y + ofset_rect_size)].each_with_index do |columns, i|
    start_rect[i] << columns[(start_x)..(start_x + ofset_rect_size)]
  end
  matrix_array[(goal_y)..(goal_y + ofset_rect_size)].each_with_index do |columns, i|
    goal_rect[i] << columns[goal_x..(goal_x + ofset_rect_size)]
  end

  start_rect.flatten!(1)
  goal_rect.flatten!(1)
  
  #
  # replace startand goal lect
  #
  matrix_array[(start_y)..(start_y + ofset_rect_size)].each_with_index do |columns, i|
    #p columns[start_x..(start_x + ofset_rect_size)].first
    
    columns[start_x..(start_x + ofset_rect_size)] = goal_rect[i]
  end
  matrix_array[(goal_y)..(goal_y + ofset_rect_size)].each_with_index do |columns, i|
    columns[goal_x..(goal_x + ofset_rect_size)] = start_rect[i]
  end

  matrix_array
end




fname = "src/untan.aiff"
window_size = 1024
fft = Array.new(window_size).collect { Array.new }
buf = RubyAudio::Buffer.float(window_size)

RubyAudio::Sound.open(fname) do |snd|
  while snd.read(buf) != 0
    na = NArray.to_na(buf.to_a)
    fft_array = FFTW3.fft(na).to_a
  
    fft_array.each_with_index do |complex, i| 
      fft[i] << complex
    end
  end
end

30.times do 
  fft = random_rect_replace(fft)
end

filing_proccess ifft_process(fft)










