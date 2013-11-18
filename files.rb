all_files = Dir.entries('Docs') - ['.', '..']
content = "" 

File.open('Docs/'+ all_files[rand(all_files.size)], 'r') do |f1|
  while linea = f1.gets
    content += linea
  end
end

puts content
