# -*- coding: utf-8 -*-
#delete stopwords
#recover terms - count - etc

require 'mongo'
include Mongo

class Vectorial
  #Constructor
  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI")
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
    postings = Array.new
    #TRY TO BUILD THE TABLE IN JUST 1 QUERY
    #TODO
    @question.each { |word| postings += (@postings.find_one({:term => word}).to_a) }
   
    postings.each { |data| puts " ----------", data[0]}
  end

  #Design Under Test
  def DUT
    puts @postings.find_one({:term => @question[0]}).to_a[0]
  end

end

a = Vectorial.new
puts "==== QUESTION ===="
puts a.getQuestion("Java system añlskjdfañls")
puts "==== RESULTS ===="
a.getDocuments
