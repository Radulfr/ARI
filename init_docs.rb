require 'mongo'

include Mongo

#Relation [File_Name] => [File_Path]
all_files = Dir.entries('Docs') - ['.', '..']
n = all_files.size() -1
all_files_path = Array.new
all_files_names = Array.new

for i in 0..n
  all_files_path[i] = File.absolute_path(File.open('Docs/' + all_files[i]))
  all_files_names[i] = File.basename(File.open('Docs/' + all_files[i]), ".txt")
end

mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("ARI")
coll = db.collection("documents")

#Deleting previus rows
coll.remove

n.times { |i| coll.insert(all_files_names[i] => all_files_path[i]) }

puts "Done! " + coll.count.to_s + " documents indexed!"


