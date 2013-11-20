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
    @all_files  = Dir.entries('Docs') - ['.', '..']
#    @terms      = getIndexedTerms
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
      return @terms
    end
  end

  #Recover the StopWords list
  def getSW
    @sw = Array.new
    stopWords = @stopwords.find.to_a
    stopWords.size.times { |i| @sw[i] = stopWords[i].to_s.scan(/=>"[a-z]+"/)}
    @sw.size.times { |i| @sw[i].to_s.scan(/\w+/){ |w| @sw[i] = w} }
    return @sw
  end

  #Indexing words of a document
  def index_words(document, index)
    puts "["+index.to_s+"]\t" + "Processing document: " + document.to_s
    content = ""
    File.open(document) do |doc|
      while linea = doc.gets
        content += linea.force_encoding("UTF-8")
      end
    end
    content.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    content = content.scan(/\S\w+\D/)
    content.size.times { |i| content[i] = content[i].gsub(/\p{^Alnum}/, '').to_s.downcase}

    #Deleting StopWords
    content = content - @sw

    #warning
    self.getIndexedTerms

    #Deleting repeated
    content = content.uniq

    @indexed += content
    @indexed = @indexed.uniq
  end

  #Count word in every doc
  def count_word
    self.getIndexedTerms
  end

  def start
    @all_files.size.times { |i| index_words('Docs/'+@all_files[i], i+1)}
    puts "Saving..."
    @indexed.size.times { |i| @termscoll.insert(@indexed[i] => 0)}
    puts "Done!"
  end
end

#Main
a = Indexer.new
a.start


