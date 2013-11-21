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


all_files.size.times {|i| all_files_path[i] = File.absolute_path(File.open('Docs/' + all_files[i]))} 

#Deleting previus rows
@collection.remove

n.times { |i| @collection.insert("docname" => all_files[i].gsub(/.txt/, ""), "docpath" => all_files_path[i]) }

puts "Done! " + @collection.count.to_s + " documents indexed!"


