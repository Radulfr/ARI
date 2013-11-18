# -*- coding: utf-8 -*-
# encoding: UTF-8

#1. get stopwords

stoplist = ""

puts stoplist

all_files = Dir.entries('Docs') - ['.', '..']
#all_content = Array.new
total_count = 0

#2. A search term we made Regular Expression
term = "computer"
r1 = Regexp.new(term)
n = all_files.size - 1

for i in 0..n
  content = "" 
  partial_count = 0
  File.open('Docs/'+ all_files[i], 'r') do |f1|
    while linea = f1.gets
      content += linea
    end
  end

#2.5Processing this string (content)
#Encoding - necessary
content.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

#scan with the regular expression
  partial_count = content.scan(r1).size
  total_count += partial_count

#Obtaining the whole path
  current_file = 'Docs/'+all_files[i]
  current_file= File.open(current_file, 'r')
  puts File.absolute_path(current_file)

  puts "["+i.to_s + "] " + "[" + all_files[i]+"] completed \n" 
end
puts "Total count " + total_count.to_s


