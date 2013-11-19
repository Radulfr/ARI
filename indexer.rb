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
#    @sw.size.times { |i| @sw[i] = @sw[i].to_s.scan(/\w+/)}
    @sw.size.times { |i| @sw[i].to_s.scan(/\w+/){ |w| @sw[i] = w} }
    return @sw
  end

  def index_words(document)
    content = ""
    File.open(document) do |doc|
      while linea = doc.gets
        content += linea.force_encoding("UTF-8")
      end
    end
    content.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
     content = content.scan(/\S\w+\D/)
    content.size.times { |i| content[i] = content[i].gsub(/\p{^Alnum}/, '').to_s}
#    @sw.size.times { |i| puts @sw[i].to_s + " - " + content[i].to_s}

    #Deleting StopWords
    content = content - @sw
    self.getIndexedTerms

    for i in 0..content.size-1
      if not @terms.include?(content[i])
        @termscoll.insert(content[i] => 0)
      else
      end
    end
#    content.each { |doc| puts doc.to_s}
#    puts content.size.to_s
  end
end

#Main
a = Indexer.new
#puts a.getSW.size.to_s
a.index_words('Docs/Diald-HOWTO.txt')
#puts a.getIndexedTerms
