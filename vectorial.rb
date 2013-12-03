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
#    @data       = getData
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

  def DUT
    docs = Array.new
    docs_names = Array.new
    terms = Array.new

    @question.each { |word| docs += (@postings.find_one({:term => word}).to_a) }

    for i in 0..@question.size-1
      terms[i] = @postings.find_one({:term => @question[i]}).to_a
    end

    for i in 0..docs.size-1
      docs_names[i] = docs[i][0]
    end

    docs_names = docs_names - ['_id', 'term']
    docs_names = docs_names.uniq
 ################################need to refine TERMS   
#    puts docs_names[1], terms[1][0]
    data = Array.new(docs_names.size) { Array.new(terms.size) }

    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        for k in 0..terms[j].size-1
#          puts docs_names[i].to_s+ "--------->"+ terms[j][k][0].to_s
          if docs_names[i].eql?(terms[j][k][0])
            data[i][j] = terms[j][k][1].to_i
            puts "Im here -> " + data[i][j].to_s
            print data
            puts terms[j][k][1].class
          else
            data[i][j] = 0
          end
        end
      end
    end
#    terms.each{ |term| puts term, "----------------" }

    puts "# Docs: " + docs_names.size.to_s
    puts "# Terms: "+ terms.size.to_s
    return data
  end

  #Design Under Test
  def getData
    docs = Array.new
    docs_names = Array.new
    terms = Array.new

    @question.each { |word| docs += (@postings.find_one({:term => word}).to_a) }

    for i in 0..@question.size-1
      terms[i] = @postings.find_one({:term => @question[i]}).to_a
    end

    for i in 0..docs.size-1
      docs_names[i] = docs[i][0]
    end

    docs_names = docs_names - ['_id', 'term']
    docs_names = docs_names.uniq

#-------------
    data = Array.new(docs_names.size) { Array.new(terms.size, 0) }

    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        for k in 0..terms[j].size-1
          if docs_names[i].eql?(terms[j][k][0])
            data[i][j] = terms[j][k][1]
#            print data, " ", terms[j][k][0],"\n"
          end
        end
      end
    end
#    terms.each{ |term| puts term, "----------------" }
#    print terms
    puts "# Docs: " + docs_names.size.to_s
    puts "# Terms: "+ terms.size.to_s
    return data
  end
  def start
    puts "==== QUESTION ===="
    getQuestion
    puts "==== RESULTS ===="
    getData

  end
end

a = Vectorial.new
puts "==== QUESTION ===="
puts a.getQuestion("I have a compiler of ruby")
puts "==== RESULTS ===="
data = a.getData
print data, "\n"
#a.DUT
#docs.each { |entry| puts entry, "----" }
