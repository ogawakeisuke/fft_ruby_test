require "narray"
require "fftw3"


def wav_read( file )
  system("sox -t wav #{file} -c 2 -r 48000 -t sw _tmp1.sw")
  data = NArray.to_na(open("_tmp1.sw", "rb").read.unpack("s*"))
  return data.reshape(2,data.length/2).transpose(1,0)
end


# array = wav_read(ARGV[0])
# fc = FFTW3.fft(array, -1)
# p fc
