require 'mongo'

include Mongo
#include 'Init_docs'

class Indexer

  #Constructor
  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI")
    @stopwords  = @db.collection("stopWords")
    @docs       = @db.collection("documents")
    @termscoll  = @db.collection("terms")
    @postings   = @db.collection("postings")
    @sw         = getSW
    @all_files  = Dir.entries('Docs') - ['.', '..']
    @terms      = Array.new
    @indexed    = Array.new
    @ID_INDEX   = 0
    @ID_VALUE   = 1
  end

  #Get the indexed terms
  def getIndexedTerms
    @terms = Array.new
    indexedTerms = @termscoll.find.to_a
    indexedTerms.size.times { |i| @terms[i] = indexedTerms[i].to_a[1][1] }
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
    content = content.scan(/[a-zA-Z]+/)
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
    @indexed = "" 
    self.getIndexedTerms
    n = @terms.size - 1
    m = @all_files.size - 1
    for i in 0..10
      puts "["+(i+1).to_s+"]\tword: "+@terms[i]
      re = Regexp.new(@terms[i])
      total_count = 0
      for j in 0..10
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
          if file_count > 0
            self.insertDocumentValue(@terms[i], @all_files[j].gsub(/.txt/, ""), file_count)
          end
        end
      end
      self.updateTermValue(@terms[i], total_count)
      #update value terms
    end
  end

  def start
    @all_files.size.times { |i| index_words('Docs/'+@all_files[i], i+1)}
    puts "Saving..."
    @indexed.size.times { |i| @termscoll.insert("term" => @indexed[i], "value" => 0); @postings.insert("term" => @indexed[i])}
    puts "Done!"
    puts "Indexing... "
    count_word
    puts "Done! Finished!"
  end

  #Get the ID of a given term
  def getIdTerm(value)
    term_array = @termscoll.find_one({:term => value}).to_a
    return term_array[@ID_INDEX][@ID_VALUE]
  end

  #Get the ID of a given doc
  def getIdDoc(value)
    doc_array = @docs.find_one({:docname => value}).to_a
    return doc_array[@ID_INDEX][@ID_VALUE]
  end
  
  #Updating data in Terms table
  def updateTermValue(term,value)
    @termscoll.update({:term => term}, {"$set" => { :value => value }})
  end

  #Insert pair Term => doc/value , doc/value, ... 
  def insertDocumentValue(term, doc, value)
    @postings.update({:term => term}, {"$set" => { doc => value }})
  end

  #for testing
  def test
    self.getIndexedTerms
    @terms.size.times { |i| puts @terms[i] }
  end
end

#Main
t1 = Time.now 
a = Indexer.new
a.start
t2 = Time.now
puts "Total time: " + ((t2 - t1)/60).to_s + " minutes"
#a.test



