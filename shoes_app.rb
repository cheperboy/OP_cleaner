require_relative "modif_dvs_method.rb"

@source_dir = ""
check_concat_name = "générer un fichier concaténé DVS_ALL.txt?"

Shoes.app {
	@check_options = [check_concat_name]
	@check_concat_selected = false
	title "DVS cleaner "
	stack {
		flow do
			@button_select_source_dir = button "Dossier source"
			@note_source_dir = para ""
		end
		@button_proceed = button "Modifier DVS"
		para "\n--- OPTIONS ---"
		@check_options.map! do |name|
			flow { @c = check; para name }
			[@c, name]
		end	
		
		flow do 
			para "regex 1 :"
			@reg1 = edit_line "#{@@REGEX1}"
		end
		flow do 
			para "regex 2 :"
			@reg2 = edit_line "#{@@REGEX2}"
		end
		flow do 
			para "regex 3 :"
			@reg3 = edit_line "#{@@REGEX3}"
		end
		flow do 
			para "regex 4 :"
			@reg4 = edit_line "#{@@REGEX4}"
		end
		flow do 
			para "regex 5 :"
			@reg5 = edit_line "#{@@REGEX5}"
		end
		@button_test = button "DEBUG"
	}
	   
	@button_select_source_dir.click {
		@source_dir = ask_open_folder
		@note_source_dir.replace "#{@source_dir}"
	}

	@button_proceed.click {
		selected_options = @check_options.map { |c, name| name if c.checked? }.compact
		if (@source_dir.to_s.eql?(""))
			alert("Choisir un dossier source ! ")
		else
			@@REGEX1 = Regexp.new(@reg1.text)
			@@REGEX2 = Regexp.new(@reg2.text)
			@@REGEX3 = Regexp.new(@reg3.text)
			@@REGEX4 = Regexp.new(@reg4.text)
			@@REGEX5 = Regexp.new(@reg5.text)
			dir_dest_name = clean_tab(@source_dir)
			alert("DVS modifié dans "+ dir_dest_name.to_s)
			#options
			#si option : générer un fichier DVS_ALL.txt (DVS concatené)
			if (selected_options.include?(check_concat_name))
				concat(dir_dest_name)
			end
		end
	}
	@button_test.click {
		@@REGEX1 = Regexp.new(@reg1.text)
		@@REGEX2 = Regexp.new(@reg2.text)
		@@REGEX3 = Regexp.new(@reg3.text)
		@@REGEX4 = Regexp.new(@reg4.text)
		@@REGEX5 = Regexp.new(@reg5.text)
		alert("REGEX1 : #{@@REGEX1.inspect}\n
		REGEX2 : #{@@REGEX2.inspect}\n
		REGEX3 : #{@@REGEX3.inspect}\n
		REGEX4 : #{@@REGEX4.inspect}\n
		REGEX5 : #{@@REGEX5.inspect}\n")
	}
}



