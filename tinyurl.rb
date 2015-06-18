require 'sinatra'

@@redirects = { 'test' => 'http://example.com' }

get '/' do
  send_file 'index.html'
end

post '/create_url' do
  formatted_url = format_url(params['url'])
  if formatted_url
    slug = generate_uniq_slug
    @@redirects[slug] = formatted_url
    '/' + slug
  else
    status 400
    "Invalid url: \"#{ params[url] }\""
  end
end

get '/404' do
  status 404
  "Not found"
end

get '/:slug' do |slug|
  url = @@redirects[slug]
  if url
    redirect to(url)
  else
    status 404
    redirect to('/404')
  end
end


# helpers

def format_url(url)
    # Check if string has rough url structure
    return nil if !url || url.empty? || !/\w\w\.\w/.match(url)

    has_http = /^https?:\/\//.match(url)
    if !has_http
        url = "http://#{url}"
    end
    url
end

def generate_uniq_slug
    # http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    slug = (0...8).map { o[rand(o.length)] }.join
    # check if slug exists
    @@redirects[slug] ? generate_uniq_slug : slug
end


# test routes
#   Not prod tests, but gives rough idea of functionality

get '/test/slug_gen' do
  generate_uniq_slug
end

get '/test/format_url' do
    examples = [
        nil,
        '',
        'invalid',
        'example.com',
        'http://example.com',
        'https://example.com',
        'example.com/some/cool/path',
    ]
    examples.map do |eg|
        "\"#{eg}\" -> \"#{format_url(eg)}\""
    end.join('<br/>')
end


