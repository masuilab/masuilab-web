# -*- coding: utf-8 -*-
require 'haml'

get '/' do
  @wiki = 'masuilab'
  @title        = getTitleFromGyazz(@wiki)
  @menuArray    = getMenuFromGyazz(@wiki)
  #@subtitle     = getSubtitleFromGyazz(@wiki)
 haml :index
end

get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :main
end

get '/:wiki/title' do
  wiki = params[:wiki]
  @title = getTitleFromGyazz(wiki)
end

get '/:wiki/subtitle' do
  wiki = params[:wiki]
  @subtitle = getTitleFromGyazz(wiki)
end

get '/:wiki/menu.json' do
  #wiki = URI.encode(params[:wiki])
  @menu = getMenuFromGyazz(params[:wiki]).to_json
end

get '/:wiki/:content.json' do
  #wiki = URI.encode(params[:wiki])
  #content = URI.encode(params[:content])
  @content = getContentFromGyazz(params[:wiki],params[:content]).to_json
end

get '/:wiki' do
  @wiki = params[:wiki]
  @title        = getTitleFromGyazz(@wiki)
  @menuArray    = getMenuFromGyazz(@wiki)
  haml :index
end
