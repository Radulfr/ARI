require 'mongo'

include Mongo

@connection = MongoClient.new("localhost", "27017")
@db         = @connection.db("ARI")
@collection = @db.collection("documents")

#Relation [File_Name] => [File_Path]
all_files = Dir.entries('Docs') - ['.', '..']
n = all_files.size() 
all_files_path = Array.new
all_files_names = Array.new

for i in 0..n-1
  all_files_path[i] = File.absolute_path(File.open('Docs/' + all_files[i]))
  all_files_names[i] = File.basename(File.open('Docs/' + all_files[i]), ".txt")
end

#Deleting previus rows
@collection.remove

n.times { |i| @collection.insert(all_files_names[i] => all_files_path[i]) }

puts "Done! " + @collection.count.to_s + " documents indexed!"


