require "./spec/spec_helper"
require "json"

describe 'The Word Counting App' do
  def app
    Sinatra::Application
  end
  
  text = File.read("../texts/2")
  exclude = ["quick","jumped"]
  count = Hash.new
  count["the"] = 2
  count["fox"] = 1
  count["brown"] = 1
  count["lazy"] = 1
  count["dog"] = 1
  count["over"] = 1

  it "returns 200 and has the right keys" do
    get '/'
    expect(last_response).to be_ok
    parsed_response = JSON.parse(last_response.body)
    expect(parsed_response).to have_key("text")
    expect(parsed_response).to have_key("exclude")
  end
  
  it "returns 400 when all keys not present" do
	data_hash = {:text => text,:exclude => []}
	post '/', JSON.generate(data_hash), { "CONTENT_TYPE" => "application/json" }
	expect(last_response.status).to eq(400)
  end
  
  it "returns 400 when sample text not present" do
	data_hash = {:text => "Hello, my name is Troll alien",:exclude => ["my", "troll", "is"],:count => {"hello" => 1,"name" => 1,"alien" => 1}}
	post '/', JSON.generate(data_hash), { "CONTENT_TYPE" => "application/json" }
	expect(last_response.status).to eq(400)
  end
  
  it "returns 400 when sample text has only one unique word and exclude is not empty" do
	data_hash = {:text => "Hodor, hodor hodor. Hodor! Hodor hodor hodor hodor hodor hodor.",:exclude => ["hodor"], :count => {"hodor" => 10}}
	post '/', JSON.generate(data_hash), { "CONTENT_TYPE" => "application/json" }
	expect(last_response.status).to eq(400)
  end
  
  it "returns 400 when count is incorrect" do
	data_hash = {:text => text,:exclude => ["the"], :count => count}
	post '/', JSON.generate(data_hash), { "CONTENT_TYPE" => "application/json" }
	expect(last_response.status).to eq(400)
  end
  
  it "returns 200 when count is correct" do
	data_hash = {:text => text, :exclude => exclude, :count => count}
	post '/', JSON.generate(data_hash), { "CONTENT_TYPE" => "application/json" }
	expect(last_response).to be_ok
  end
end