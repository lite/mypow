require 'rubygems'
require 'sinatra'
require 'haml'

$pwd = File.join(ENV['PWD'], "downloads")

get '/upload' do
  haml :upload
end

post '/upload' do 
  puts "uploaded #{env['HTTP_X_FILENAME']} - #{request.body.read.size} bytes"
  file = params[:file]
  filename = file[:filename]
  tempfile = file[:tempfile]
  File.open(filename, 'w') {|f| f.write tempfile.read}
  redirect '/browse'
end

get '/files/:filename' do |filename|
  file = File.join($pwd, filename)
  send_file(file,:disposition => 'attachment') if is_attachment(filename)
  send_file(file, :type => 'image/jpeg', :disposition => 'inline') if is_image(filename)
  
  send_file(generate_tgz(filename),:disposition => 'attachment')
end

get '/browse' do
  @files = file_listing($pwd)
  haml :browse
end

get '/' do
  haml :index
end

def is_image(filename)
  filename.include?(".png")
end

def is_attachment(filename)
  filename.include?(".txt")
end

def file_listing(directory)
  Dir.glob(directory + '/*')
end

def generate_tgz(file)
  system("mkdir -p ./tmp")
  system("cp #{$pwd}/#{file} ./tmp")
  tar_file = "./tmp/iamzip.tar.gz"
  system("tar -czvf #{tar_file} ./tmp/#{file}")
  tar_file
end