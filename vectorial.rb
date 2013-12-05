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

  #Vectorial
  def initVectorial
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

    data = Array.new(docs_names.size) { Array.new(terms.size, 0) }
    data_w = Array.new(docs_names.size) { Array.new(terms.size, 0) }
#INITIAL -> data
    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        for k in 0..terms[j].size-1
          if docs_names[i].eql?(terms[j][k][0])
            data[i][j] = terms[j][k][1]
          end
        end
      end
    end
#CONTAR.SI
    count_if = Array.new(@question.size, 0)
    log_count_if = Array.new(@question.size, 0)
    for j in 0..docs_names.size-1
      for i in 0..@question.size-1
        count_if[i] += data[j][i]
      end
    end
#    print count_if
#LOGARITHM count_if
#--------------------------------
    log_count_if = Array.new(count_if.size, 0)
    for i in 0..count_if.size-1
      #WARNING HERE
      log_count_if[i] = Math.log10(count_if[i]) 
    end
#DATA_W--------------------------------
#MISSING Q¿?
    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        data_w[i][j] = data[i][j]/log_count_if[j]
      end
    end

#SUM---------------------------------
    sum = Array.new(docs_names.size,0)
    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        sum[i] += data_w[i][j]
      end
    end
#SUM---------------------------------
    e1 = Array.new(docs_names.size,0)

    for i in 0..docs_names.size-1
      for j in 0..terms.size-1
        e1[i] += (data_w[i][j])**2
      end
    end
    sum.each_index { |i| e1[i] += sum[i]**2 } 
#E2---------------------------------

    e2 = e1.collect{|item|  item*terms.size}
#SUMA/E2----------------------------
    ranking = Array.new(docs_names.size,0)
    results = Array.new(docs_names.size) { Array.new(2) }

    for i in 0..e1.size-1
      results[i][0] = docs_names[i]
      results[i][1] =  sum[i]/e2[i]
    end
    results = results.sort_by{|e| e[1]}
#The less is the value, the high is the relationship
#    results = results.reverse
    return results
  end
#------------------------------------------ 
 def start(question)
   puts "==== QUESTION ===="
   print getQuestion(question), "\n"
   puts "==== RESULTS ===="
   result = initVectorial

   for i in 0..result.size-1
     puts result[i][0].to_s + "\t\t\t"+ result[i][1].to_s
   end
  end
end

a = Vectorial.new
#a.start("I have a ruby compiler emacs")
a.start("semantic approach")
