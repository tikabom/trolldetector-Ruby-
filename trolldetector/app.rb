require 'sinatra'
require "sinatra/reloader" if development?

require 'set'
require 'json'

get '/' do
	files = %w(texts/0 texts/1 texts/2 texts/3 texts/4 texts/5)

	text_file = files.sample
	source_text = File.read(text_file).strip
	text_array = source_text.split(/[\s,.,\,,!,;,-]+/)

	exclude = Set.new
	num_exclude = rand(0...text_array.length)
	for i in (0...num_exclude)
	exclude.add(text_array.sample)
	end

	erb :"get.json", locals: { source_text: source_text, exclude: exclude.to_a() }
end

post '/' do
	request.body.rewind
	data_hash = JSON.parse(request.body.read)
	
	if !data_hash.key?("text") or !data_hash.key?("exclude") or !data_hash.key?("count")
		status 400
		return
	end
	
	files_set = Set.new
	files = %w(texts/0 texts/1 texts/2 texts/3 texts/4 texts/5)
	for i in (0...files.length)
		files_set.add(File.read(files[i]).strip)
	end
	
	if !files_set.include?(data_hash["text"].strip)
		status 400
		return
	end	
	
	request_text = data_hash["text"]
	text_array = request_text.split(/[\s,.,\,,!,;,-]+/)
	text_array.map!{|i| i.downcase.strip}
	
	count = Hash.new
	exclude = data_hash["exclude"]
	exclude.map!{|i| i.downcase.strip}
	
	for i in (0...text_array.length)
		if count.key?(text_array[i])
			count[text_array[i]] = count[text_array[i]] + 1
		elsif exclude.include?(text_array[i])
			next
		else
			count[text_array[i]] = 1
		end
	end
	
	if count.size == 1 && !exclude.empty?
		status 400
		return
	end
	
	downhash = Hash.new
	data_hash["count"].each_pair do |k,v|
		downhash.merge!({k.downcase => v})
	end
	
	if !count.eql?(downhash)
		status 400
		return
	end
end