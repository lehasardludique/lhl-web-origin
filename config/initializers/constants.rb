LHL_URL = "#{ENV["PROTOCOL"]||"http://"}" + "#{ENV["HOST"]||"www.lehasardludique.paris"}"
INTERNAL_LINK_FORMAT = /(\ >\ )((Page:\d)|(Article:\d)|(Fichier:\d)|(\/)|(http(s)?:\/\/))/
EVENT_CATEGORIES_URLIZE = Event.categories.keys.map{ |c| I18n.t('event.categories.'+c).urlize}