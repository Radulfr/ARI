require 'mongo'

include Mongo

class Indexer

  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI")
    @stopwords  = @db.collection("stopWords")
    @docs       = @db.collection("documents")
    @termscoll  = @db.collection("terms")
    @postings   = @db.collection("postings")
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
    n = @terms.size - 1
    m = @all_files.size - 1
    for i in 0..n
      re = Regexp.new(@terms[i])
      total_count = 0
      for j in 0..m
        content = ""
        File.open('Docs/'+@all_files[j], 'r') do |f1|
          while linea = f1.gets
            content += linea
          end
          content.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
          file_count = content.scan(re).size
          total_count += file_count
          #insertion
          #...
        end
      end
    #update value terms
    end
  end

  def start
    @all_files.size.times { |i| index_words('Docs/'+@all_files[i], i+1)}
    puts "Saving..."
    @indexed.size.times { |i| @termscoll.insert(@indexed[i] => 0)}
    puts "Done!"
  end

  #Don't like this solution
  def getID(word)  #UGLY CODE UGLY CODE UGLY CODE UGLY CODE UGLY CODE UGLY CODE 
    all_terms = @termscoll.find.to_a
    re = Regexp.new(word)
    value = all_terms
    n = value.size - 1
    for i in 0..n
      if value[i].include?(word)
        value = value[i].to_s
        break
      end
    end
    value = value.scan(/'.+'/)
    value = value[0]
    value = value[1..value.size-2]
    return value
  end  #UGLY CODE UGLY CODE UGLY CODE UGLY CODE UGLY CODE UGLY CODE 

#for testing
  def test
   # puts @termscoll.find("_id" => self.getID("linux")).to_a
    puts @termscoll.find_one(:_id => BSON::ObjectId(getID(@terms[1]))).to_a
  end
end

#Main
a = Indexer.new
a.getIndexedTerms
#a.start
a.test
