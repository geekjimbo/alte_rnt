def chunker f_in, out_pref, chunksize = 1_073_741_824
    my_arr = []
    File.open(f_in,"r", :enconding=> "bom|uft-8") do |fh_in|
      until fh_in.eof?
        path_txt = Rails.root.join('tmp/files', "#{path_txt.to_s}#{out_pref}_#{"%03d"%(fh_in.pos/chunksize)}.txt")
        File.open(path_txt.to_s,"w") do |fh_out|
          c = fh_in.read(chunksize)
          c.force_encoding "utf-8"
          fh_out.write(c)
          my_arr << fh_out 
        end
      end
    end
  return my_arr
end
