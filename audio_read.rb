require "narray"
require "fftw3"


def wav_read( file )
  system("sox -t wav #{file} -c 2 -r 44100 -t sw _tmp1.sw")
  data = NArray.to_na(open("_tmp1.sw", "rb").read.unpack("s*"))
  return data
  # return data.reshape(2,data.length/2).transpose(1,0)
end


def fft(na, window_size)
  FFTW3.fft(na, -1)
end

def ifft(na, window_size)
  FFTW3.fft(na, 1)
end

#まびく
def thin(fc) 
  fc.to_a[0, window_size/2] 
end

na = wav_read("dot.wav")

p fft(na, 1024)
