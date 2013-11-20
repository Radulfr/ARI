require 'mongo'

include Mongo

class Indexer

  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI")
    @stopwords  = @db.collection("stopWords")
    @docs       = @db.collection("documents")
    @termscoll  = @db.collection("terms")
    @sw         = getSW
    @terms      = getIndexedTerms
    @indexed    = Array.new
  end

  def getIndexedTerms
    @terms = Array.new
    indexedTerms = @termscoll.find.to_a
    if indexedTerms.size == 0
      return 0
    else
      indexedTerms.size.times { |i| @terms[i] = indexedTerms[i].to_s.scan(/"[a-z]+"=>/)}
      @terms.size.times { |i| @terms[i].to_s.scan(/\w+/){ |w| @terms[i] = w} }
#      @terms = @terms - [ "^[a-z0-9]+" ]
      return @terms
    end
  end

  #Recover the StopWords list
  def getSW
    @sw = Array.new
    stopWords = @stopwords.find.to_a
    stopWords.size.times { |i| @sw[i] = stopWords[i].to_s.scan(/=>"[a-z]+"/)}
#    @sw.size.times { |i| @sw[i] = @sw[i].to_s.scan(/\w+/)}
    @sw.size.times { |i| @sw[i].to_s.scan(/\w+/){ |w| @sw[i] = w} }
    return @sw
  end

  def index_words(document)
    puts ">>> Processing document: " + document.to_s
    content = ""
    File.open(document) do |doc|
      while linea = doc.gets
        content += linea.force_encoding("UTF-8")
      end
    end
    content.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    content = content.scan(/\S\w+\D/)
    content.size.times { |i| content[i] = content[i].gsub(/\p{^Alnum}/, '').to_s.downcase}
#    @sw.size.times { |i| puts @sw[i].to_s + " - " + content[i].to_s}

    #Deleting StopWords
    content = content - @sw
    self.getIndexedTerms

    #Deleting repeated
    content = content.uniq
#    content = content - [ "^[a-z0-9]+" ]
#    puts content.size.to_s
    @indexed += content
    @indexed = @indexed.uniq

#    for i in 0..content.size-1
#      if not @terms.include?(content[i])
#        @termscoll.insert(content[i] => 0)
#      else
#      end
#    end
#    content.each { |doc| puts doc.to_s}
#    puts content.size.to_s
  end
end



#Main
a = Indexer.new

#for each document
#a.index_words('Docs/Diald-HOWTO.txt')

all_files = Dir.entries('Docs') - ['.', '..']

#all_files.(size/8).times { |i| a.index_words('Docs/'+all_files[i])}

puts @indexed.size.to_s
puts "Saving..."
@indexed.(size/8).times { |i| @termscoll.insert(@indexed[i] => 0)}
puts "Done! "
