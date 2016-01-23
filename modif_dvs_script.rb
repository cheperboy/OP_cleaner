require_relative "modif_dvs_method.rb"

# lecture des paramètres d'appel du programme
dir_source = "dvs"
dir_source = ARGV[0] unless ARGV[0].nil?


#EXECUTION DU PROGRAMME
clean_tab(dir_source)
