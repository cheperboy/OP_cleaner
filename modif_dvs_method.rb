require 'fileutils'
require 'pathname'
require 'time'

#---- CONSTANTES -----
# regex ruby stockées en string
# 	un \ est ajouté volontairement avant chaque \ sinon la classe String supprime les \
#	Donc "\\" devient "\"
@@REGEX1 = "^Ansaldo.+$"
@@REGEX2 = "^DOSSIER DE VERIFICATION SYSTEME.+$"
@@REGEX3 = "^SEI_TVM300 -.+$"
@@REGEX4 = "^(\\||_)*$" #lignes du type "|______|_____|"
@@REGEX5 = "^(\\||\\s)*$" #lignes du type "|   |    |    |"

# pour effacer les en-tete de tableau, nombre de ligne à supprimer avant et après le titre du tableau
@@DELETE_NB_LIGNE_BEFORE = 2
@@DELETE_NB_LIGNE_AFTER = 5



#sleep 10

def test_func
	File.open("toto_test.txt", "w") {|file| file.puts "titi" }
end

#TODO : ajouter list des fichiers trouvés dans IHM après sélection dossier source
def list
	Dir.chdir(DIR_SOURCE)
	#Liste des fichiers dont le nom contient terme "DVS"
	Dir.glob("*{DVS}*") {|f| puts "File :  #{f}" }
end

# creation du fchier dvs_all.txt
# copie du contenu de DVS.PRE et DVS.TAB dans dvs_all.txt
def concat(dir_dest)
	Dir.chdir(dir_dest)
	dvs_all = File.open("DVS_ALL.txt", "a")
	Dir.glob("*.{pre,PRE}*").each do |f|
		dvs_files = File.open(f,'r')
		dvs_files.each_line{|line| dvs_all.puts line}
	end
	Dir.glob("*.{tab,TAB}*").each do |f|
		dvs_files = File.open(f,'r')
		dvs_files.each_line{|line| dvs_all.puts line}
	end
	dvs_all.close
end
#lecture du fichier COMPLET et suppression des en-tetes
def clean_tab(dir_source)
	#creer nouveau repertoire dans un niveau antérieur au répertoire source
	Dir.chdir(dir_source)
	Dir.chdir("../")
	dir_dest_name = "modif_DVS_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}"
	
	Dir.mkdir dir_dest_name
	dir_dest_name_absolute = "#{Dir.pwd}/#{dir_dest_name}"
	puts dir_dest_name_absolute.to_s
	
	#copier les fichiers originaux DVS dans nouveau repertoire daté
	FileUtils.cp_r "#{dir_source}/.", "#{dir_dest_name}"

=begin
	#copie des .TAB
	Dir.glob("*{TAB}*").each do |file_name|
		FileUtils.cp("#{file_name}", "../#{dir_dest_name}/#{file_name}")
	end
=end
	
	#positionner le programme dans le nouveau repertoire
	Dir.chdir("#{dir_dest_name}")
	puts "#{Dir.pwd}"

	temp_file_name = "temp.txt" #fichier temp
	
	#modification de chaque fichier .TAB ou .tab
	Dir.glob("*.{tab,TAB}*").each do |file_name|
		# donner les droit d'écriture sur les fichiers .tab
		File.chmod(0777, file_name)
		#vider le fichier temp
		File.open(temp_file_name, 'w') {|file| file.truncate(0) }
		#supprimer les en-tete DVS (Ansaldo, version DVS, nom projet) et lignes du type "|___|___|_____|"
		text = File.read(file_name)
		text = text.gsub(Regexp.new(@@REGEX1), "")
		text = text.gsub(Regexp.new(@@REGEX2), "")
		text = text.gsub(Regexp.new(@@REGEX3), "")
		text = text.gsub(Regexp.new(@@REGEX4), "")
		text = text.gsub(Regexp.new(@@REGEX5), "")
		
		File.open(temp_file_name, "w") {|file| file.puts text }
  
		#supprimer lignes vides et en-tete sauf le premier en-tête (TABLEAU 03.03: ...)		
		text_tab = IO.readlines(temp_file_name) #copie le text dans un tableau
		File.open(file_name, 'w') {|file| file.truncate(0) } #supprimer le contenu du fichier de destination (DVSxxx.tab)
		
		found_first = false
		i=0
		while (text_tab[i])
			if ((text_tab[i].index(/^.+TABLEAU /)) && (found_first == true))
				#supprime 2 lignes avant l'entete et 5 lignes apres
				for ligne in -(@@DELETE_NB_LIGNE_BEFORE)..(@@DELETE_NB_LIGNE_AFTER)
					text_tab[i+ligne] = ""
				end
			end
			if ((text_tab[i].index(/^.+TABLEAU /)) && (found_first == false))
				found_first = true
			end
			i=i+1
		end
		file = File.open(file_name, "a")
		i=0
		while (text_tab[i])
			file.puts text_tab[i] unless ((text_tab[i].chomp.empty?) || 
			(text_tab[i].codepoints.to_a[0].eql?(12)))
			i = i+1
		end
		file.close
	end
	File.delete(temp_file_name)
	return dir_dest_name_absolute
end
