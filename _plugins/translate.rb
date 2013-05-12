require 'yaml'
#translate( id [,category ,lang] )
#Return translated string using translations files
#category and lang are set to current page.id and page.lang, but they can also be set manually to access translations for another page or for the global layout and urls.
#translate also replace urls and anchor in translated strings. For example, #vocabulary##[vocabulary.wallet] is replaced by /en/vocabulary#wallet or /fr/vocabulaire#porte-monnaie, depending of the language.

module Jekyll
  class TranslateTag < Liquid::Tag

    def initialize(tag_name, id, tokens)
      super
      @id = id
    end

    def render(context)
      #load translations files
      site = context.registers[:site].config;
      if !site.has_key?("loc")
        site['loc'] = {};
        site['langs'].each do |key,value|
          site['loc'][key] = YAML.load_file("_translations/"+key+".yml")[key];
        end
      end
      #define id, category and lang
      lang = Liquid::Template.parse("{{page.lang}}").render context;
      cat = Liquid::Template.parse("{{page.id}}").render context;
      id=@id.split(' ');
      if !id[1].nil?
        cat = Liquid::Template.parse(id[1]).render context;
      end
      if !id[2].nil?
        lang = Liquid::Template.parse(id[2]).render context;
      end
      id=Liquid::Template.parse(id[0]).render context;
      #get translated string
      text = '';
      if site['loc'][lang].has_key?(cat) && site['loc'][lang][cat].has_key?(id) && !site['loc'][lang][cat][id].nil?
        text = site['loc'][lang][cat][id];
      end
      #replace urls and anchors in string
      url = site['loc'][lang]['url'];
      url.each do |key,value|
        if !value.nil?
          text.gsub!("#"+key+"#",'/'+lang+'/'+value);
        end
      end
      anc = site['loc'][lang]['anchor'];
      anc.each do |page,anch|
        anch.each do |key,value|
          if !value.nil?
            text.gsub!("["+page+'.'+key+"]",value);
          end
        end
      end
      text
    end
  end
end

Liquid::Template.register_tag('translate', Jekyll::TranslateTag)
