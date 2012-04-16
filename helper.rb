require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra/reloader' if development?
require 'yaml'
require 'json'
require 'open-uri'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
  exit 1
end

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

#リンクの生成
def atag(word,href)
  "<a href='#{href}' target='_blank'>#{word}</a>"
end

#大カッコを外す
def stripBrackets(str)
  return str.gsub(/\[+|\]+/,"")
end

#Gyazzからtitleを取得
def getTitleFromGyazz(wiki)
  wiki = URI.encode(wiki)
  url = "#{@@conf['gyazz']}/#{wiki}/title"
  titleString = open(url+"/text").readlines[0].to_s.chomp
  unless titleString.length > 0 then
    titleString="undefined. Check to gyazz: #{atag("#{wiki}/title",url)} "
  end
  return titleString
end

def getMenuFromGyazz(wiki)
  wiki = URI.encode(wiki)
  url = "#{@@conf['gyazz']}/#{wiki}/#{@@conf['menu']}/text"
  menuArray = []
  open(url).readlines.each do |menu|
    next if menu =~ /^\s/       #頭がスペースの行ならスキップ
    menu = stripBrackets(menu)	#大カッコ[]を取り除く
    menuArray.push(menu.chomp)
  end
  return menuArray
end

def getContentFromGyazz(wiki,content)
  wiki    = URI.encode(wiki)
  content = URI.encode(content)
  url = "#{@@conf['gyazz']}/#{wiki}/#{content}/text"

  contentsArray = []
  indent = 0
  open(url).readlines.each do |line|
    next unless line.length > 0
    line.chomp!
    indent = line.scan(/^\s*/)[0].length	#頭のスペースを数える
    line = line.gsub(/^\s+/,"")		#頭のスペースを取り除く
    line = resolveBrackets(line)	#カッコの変換
    line = stripBrackets(line)		#大カッコを取り除く

    contentsArray.push("<h#{indent+2}>"+line+"</h#{indent+2}>")
  end

  return contentsArray
end

#大カッコのタグを適切に変換する
def resolveBrackets(str)
  boldArray = str.scan(/\[\[\[.+?\]\]\]/)		#大カッコ３連を探す
  boldArray.each do |bold|
    str.gsub!(/#{stripBrackets(bold)}/){
      "<u>#{stripBrackets(bold)}</u>"
    }
    return str
  end

  linkArray = str.scan(/\[\[.+?\]\]/)			#大カッコ２連を探す
  linkArray.each do |link|
    str.gsub!(/#{stripBrackets(link)}/){|match|
      result = ""
      #「スペースでない任意の文字の連続で末尾が画像拡張子」なら変換
      # File.extnameという便利なメソッドがあるらしいが
      match.gsub!(/[^\s]+#{@@conf['image']}$/){|src|
        "<a href='#{src}' rel=\"lightbox\"><img src='#{src}'/></a>"
      }
      #音楽ファイル
      match.gsub!(/[^\s]+#{@@conf['audio']}$/){|src|
        "<audio src='#{src}' controls><p>audioタグをサポートしたブラウザが必要です</p></audio>"
      }
      #映像ファイル
      match.gsub!(/[^\s]+#{@@conf['movie']}$/){|src|
        "<video src='#{src}' width='100%' preload='none' controls></video>"
      }
      #youtubeの埋込み
      #match.gsub!(/^#{@@conf['youtube']}/){|src|
	#"<iframe width='560' height='315' src='#{src.sub("watch?v=","embed")}' frameborder='0' allowfullscreen></iframe>"
      #}
      result = match
      word = match.match(/(<img\s)?[^\s]+$/) #後ろ側の文字列を取得（スペースがなければ全てマッチする）
      if url = match.match(/^http:\/\/[^\s]+/) then
        result = atag(word,url)
      end
      result
    }
  end

  return str
end
