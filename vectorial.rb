# -*- coding: utf-8 -*-
#delete stopwords
#recover terms - count - etc

require 'mongo'
include Mongo

class Vectorial
  #Constructor
  def initialize
    @connection = MongoClient.new("localhost", "27017")
    @db         = @connection.db("ARI_TESTING")
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
    docs_names = Array.new
    terms = Array.new
    data = Array.new

    @question.each { |word| docs += (@postings.find_one({:term => word}).to_a) }

    for i in 0..@question.size-1
      terms[i] = @postings.find_one({:term => @question[i]}).to_a
    end

    for i in 0..docs.size-1
      docs_names[i] = docs[i][0]
    end
    docs_names = docs_names - ['_id', 'term']
 
#need to refine TERMS   
#    puts docs_names[1], terms[1][0]
    for i in 0..docs_names.size-1
      data [i] = Array.new
      for j in 0..terms.size-1
        puts terms[j][0][0].to_s+ "--->"+ docs_names[i].to_s
        if terms[j][0][0].eql?(docs_names[i])
          data[i][j] = terms[j][1]
        else
          data[i][j] = 0
        end
      end
    end
    terms.each{ |term| puts term[0][1], "----------------" }
    puts "# Docs: " + docs_names.size.to_s
    puts "# Terms: "+ terms.size.to_s
    return data
  end

  #Design Under Test
  def DUT
    puts @postings.find_one({:term => @question[0]}).to_a[0]
  end

end

a = Vectorial.new
puts "==== QUESTION ===="
puts a.getQuestion("the semantic flesh")
puts "==== RESULTS ===="
docs = a.getDocuments

docs.each { |entry| puts entry, "----" }
