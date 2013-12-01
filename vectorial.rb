# -*- coding: utf-8 -*-
#delete stopwords
#recover terms - count - etc

require 'mongo'
include Mongo

class Vectorial
  #Constructor
  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI_T")
    @stopwords  = @db.collection("stopWords")
    @postings   = @db.collection("postings")
    @sw         = getSW
    @question   = Array.new
    @docslist   = Array.new
  end

  #Recover stopwords
  def getSW
    @sw = Array.new
    stopWords = @stopwords.find.to_a
    stopWords.size.times { |i| @sw[i] = stopWords[i].to_s.scan(/=>"[a-z]+"/)}
    @sw.size.times { |i| @sw[i].to_s.scan(/\w+/){ |w| @sw[i] = w} }
    return @sw
  end

  #get de question
  def getQuestion(q)
    q = q.downcase.scan(/\w+/)
    @question = q - @sw
  end

  def getDocuments
    docs = Array.new
    data = Array.new
    #TRY TO BUILD THE TABLE IN JUST 1 QUERY
    #TODO
    for i in 0..@question.size-1
      docs[i] = (@postings.find_one({:term => @question[i]})) 
    end
  end

  #Design Under Test
  def DUT
    puts @postings.find_one({:term => @question[0]}).to_a[0]
  end

end

a = Vectorial.new
puts "==== QUESTION ===="
puts a.getQuestion("the semantic quality")
puts "==== RESULTS ===="
a.getDocuments
