module MobileAppsHelper

	def self.create_app(name, userPath, appType)
		FileUtils.mkdir_p(userPath) unless File.directory?(userPath)
        appPath = userPath.join(name);
        modelName = get_model_name(appType);
        modelPath = Rails.root.join('modelos').join(modelName);
        FileUtils.cp_r modelPath, appPath
        replace_on_app_creation(appPath, name, modelName);
        system("cd \"#{appPath}\" && ionic login --email fpiechotka@gmail.com --password 123123 && ionic io init");
        replace_app_id(appPath);
	end

	def self.replace_app_id(appPath)
		appId = get_app_id(appPath)
		replace(appPath.join('src').join('app').join('app.module.ts'), '[APPID]') { |match| appId }
		
	end	

	def self.get_app_id(appPath)
		File.open(appPath.join('ionic.config.json')) do |f|
		  f.each_line do |line|
		    if line =~ /\"app_id\"/
		      return line.scan( /: \"([^>]*)\"/).last.first
		    end
		  end
		end
		return "";
	end


	def self.replace_on_app_creation(appPath, appName, modelName)
		replace(appPath.join('package.json'), modelName) { |match| appName }
		replace(appPath.join('ionic.config.json'), modelName) { |match| appName }
		replace(appPath.join('config.xml'), modelName) { |match| appName }
		replace(appPath.join('plugins/android.json'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/AndroidManifest.xml'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/android.json'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/res/values/strings.xml'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/res/xml/config.xml'), modelName) { |match| appName }

		androidDirectory = appPath.join('platforms/android/src/com/ionicframework')
		oldDirectory = Dir.entries(androidDirectory).sort_by {|x| x.length}.last()
		number = /\d+/.match(oldDirectory)[0]
		FileUtils.mv androidDirectory.join(oldDirectory), androidDirectory.join(appName + number)

		replace(androidDirectory.join(appName + number).join('MainActivity.java'), modelName) { |match| appName }
	end

	def self.get_model_name(appType)
		if(appType == 'tabs')
			return 'moldet'
		else
			return 'moldes'
		end
	end

	def self.new_page(mobileApp, appPath, originalName, appType, type, value)
		tabName = transform_name(originalName)
		
		system("cd \"#{appPath}\" && ionic g page \"#{tabName}\"");

		# modelPath = Rails.root.join('modelos').join('page')
		# tabsPath = appPath.join('src').join('pages');
		# tabPath = tabsPath.join(tabName);
		# FileUtils.mkdir_p(tabPath);
		# FileUtils.cp_r modelPath, tabsPath
		# File.rename(tabsPath.join('page'), tabPath)
		# File.rename(tabPath.join('tab.html'), tabPath.join(tabName + ".html"));
		# #File.rename(tabPath.join('tab.scss'), tabPath.join(tabName + ".scss"));
		# File.rename(tabPath.join('tab.ts'), tabPath.join(tabName + ".ts"));
		# replace(tabPath.join(tabName + ".html"), 'tab') { |match| tabName }
		# tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		# replace(tabPath.join(tabName + ".ts"), 'Tab') { |match| tabNameForPage }
		# replace(tabPath.join(tabName + ".ts"), 'tab') { |match| tabName }
		# #replace(tabPath.join(tabName + ".scss"), 'tab') { |match| tabName }


		if (appType == 'Tabs')
			new_tab(appPath, tabName, originalName)
		else
			new_menu_page(appPath, tabName, originalName)
		end

		content = ""
		case type
		when "2"#custom screen
			@mobile_app_screen = mobileApp.mobile_app_screens.select { |s| s.id.to_s == value }
			if(@mobile_app_screen.present? && @mobile_app_screen.size > 0)
				content= @mobile_app_screen.first.raw_html

				if (@mobile_app_screen.first.wsURL.present?)
					puts "present"
					set_ws_tab(appPath, tabName, mobileApp.title, @mobile_app_screen.first.wsURL)
				else
					puts "not present"
				end
			end
		when "3"#facebook feed
			content = get_fb_content(value)
		when "4"#instagram feed
			content = get_ig_content(value)
		when "5"#twitter feed
			content = get_tw_content(value)
		when "6"#youtube channel
			content = get_yt_content(value)
		when "7"#chat
			content = get_chat_content()
			set_chat_tab(appPath, tabName, mobileApp.title)
		when "8"#Google map
			content = get_map_content(value)
		when "9"#html
			content = value
		end
		set_content(appPath, tabName, content)
		before_reload()
	end

	def self.new_menu_page(appPath, tabName, originalName)
		#app.component.ts
		componentTsPath = appPath.join('src').join('app').join('app.component.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(componentTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from '../pages/" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
		replace(componentTsPath, /\}((?!,)[\S\s])*];/) { |match| "},\n      { title: '" + originalName + "', component: " + tabNameForPage + "Page }" + "\n" + "    ];" }

		#app.module.ts
		moduleTsPath = appPath.join('src').join('app').join('app.module.ts')
		replace(moduleTsPath, '@NgModule({') { |match| "import { " + tabNameForPage +"Page } from '../pages/" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
		replace(moduleTsPath, 'MyApp,') { |match| "MyApp,\n    " + tabNameForPage + "Page," }

		#page.html 
		pagePath = appPath.join('src').join('pages').join(tabName).join(tabName + '.html')
		replace(pagePath, '<ion-navbar>') { |match| "#{match}" + '<button ion-button menuToggle>
      <ion-icon name="menu"></ion-icon>
    </button>' }
    	replace(pagePath, '<ion-title>' + tabName + '</ion-title>'){ |match| "<ion-title>" + originalName + "</ion-title>" }

	end

	def self.new_tab(appPath, tabName, originalName)
		#tabs.html
		tabsPath = appPath.join('src').join('pages').join('tabs').join('tabs.html')
		tabLine = '<ion-tab [root]="tab' + tabName + '" tabTitle="' + originalName +'" tabIcon="' + tabName + '"></ion-tab>' + "\n"
		replace(tabsPath, /<\/ion-tabs>/mi) { |match| tabLine + "#{match}"}

		#tabs.ts
		tabsTsPath = appPath.join('src').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, 'export class TabsPage {') { |match| "#{match}" + "\n  tab" + tabName + ": any = " + tabNameForPage + "Page;"}
		replace(tabsTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from '../" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }

		#page.html
		pagePath = appPath.join('src').join('pages').join(tabName).join(tabName + '.html')
    	replace(pagePath, '<ion-title>' + tabName + '</ion-title>'){ |match| "<ion-title>" + originalName + "</ion-title>" }

		#app.module.ts
		moduleTsPath = appPath.join('src').join('app').join('app.module.ts')
		replace(moduleTsPath, '@NgModule({') { |match| "import { " + tabNameForPage +"Page } from '../pages/" + tabName + "/" + tabName + "';" + "\n" + "#{match}" }
		replace(moduleTsPath, 'MyApp,') { |match| "MyApp,\n    " + tabNameForPage + "Page," }

	end

	def self.replace(filepath, regexp, *args, &block)
		content = File.read(filepath).gsub(regexp, *args, &block)
		File.open(filepath, 'wb') { |file| file.write(content) }
	end

	def self.set_content(appPath, tabName, content)
		tabPath = appPath.join('src').join('pages').join(tabName).join(tabName + '.html')
		replace(tabPath, /<ion-content padding>\n(.*\n)*<\/ion-content>/) { |match| "<ion-content padding>" + "\n" + content + "\n" + "</ion-content>"}
	end


	def self.delete_page(appPath, originalName, appType)
		tabsPath = appPath.join('src').join('pages');
		tabName = transform_name(originalName)
		count = Dir.entries(tabsPath).delete_if {|i| i == "." || i == ".." || i == "tabs"}.count;
		if(count > 1)
			if (appType == 'Tabs')
				delete_tab(appPath, originalName, tabName)
			else
				delete_menu_page(appPath, originalName, appType, tabName)
			end
			FileUtils.rm_rf(tabsPath.join(tabName))			
		end
		before_reload()
	end

	def self.before_reload
		sleep 9
	end

	def self.delete_menu_page(appPath, originalName, appType, tabName)
		#app.component.ts
		appComponentTsPath = appPath.join('src').join('app').join('app.component.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(appComponentTsPath, "import { " + tabNameForPage +"Page } from '../pages/" + tabName +"/" + tabName + "';" + "\n" ) { |match| '' }
		replace(appComponentTsPath, /,((?!,)[\S\s])*{ title: '#{originalName}', component: #{tabNameForPage}Page }/) { |match| '' }

		#rootPage
		somePage = get_pages(appPath, appType)[0][0];
		somePage = transform_name(somePage);
		tabNameForSomePage = somePage[0].upcase + somePage[1..somePage.length - 1]		
		replace(appComponentTsPath, "rootPage: any = " + tabNameForPage + "Page;") {|match| "rootPage: any = " + tabNameForSomePage +"Page;"}
		
		#app.module.ts
		moduleTsPath = appPath.join('src').join('app').join('app.module.ts')
		replace(moduleTsPath, "import { " + tabNameForPage +"Page } from '../pages/" + tabName + "/" + tabName + "';" + "\n" ) { |match| '' }
		replace(moduleTsPath, /,((?!,)[\S\s])*#{tabNameForPage}Page/) { |match| '' }

	end

	def self.delete_tab(appPath, originalName, tabName)
		#tabs.html
		tabsPath = appPath.join('src').join('pages').join('tabs').join('tabs.html')
		replace(tabsPath, /<ion-tab \[root\]=\".*\" tabTitle=\"#{originalName}\" tabIcon=\".*\"><\/ion-tab>\n/) { |match| ''}

		#tabs.ts
		tabsTsPath = appPath.join('src').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, "tab" + tabName + ": any = " + tabNameForPage + "Page;\n") { |match| '' }
		replace(tabsTsPath, "import { " + tabNameForPage +"Page } from '../" + tabName +"/" + tabName + "';" + "\n") { |match|  '' }

		#app.module.ts
		moduleTsPath = appPath.join('src').join('app').join('app.module.ts')
		replace(moduleTsPath, "import { " + tabNameForPage +"Page } from '../pages/" + tabName +"/" + tabName + "';" + "\n" ) { |match| '' }
		replace(moduleTsPath, /,((?!,)[\S\s])*#{tabNameForPage}Page/) { |match| '' }
	end

	def self.get_pages(appPath, appType)
		if(appType == 'tabs')
			return get_pages_tabs(appPath, appType);
		else
			return get_pages_menu(appPath, appType);
		end

	end

	def self.get_pages_tabs(appPath, appType)
		tabsPath = appPath.join('src').join('pages').join('tabs').join('tabs.html');
		fileText = File.read(tabsPath);
		return fileText.scan(/tabTitle=\"(.*)\" tabIcon/);
	end

	def self.get_pages_menu(appPath, appType)
		appTsPath = appPath.join('src').join('app').join('app.component.ts')
		fileText = File.read(appTsPath);
		return fileText.scan(/title: \'(.*)\',/);
	end

	def self.page_exists(appPath, name)
		tabsPath = appPath.join('src').join('pages')
		return Dir.entries(tabsPath).include?(name)
	end

	def self.get_fb_content(value)
		return get_tab_content('fb.html', value)
	end

	def self.get_tw_content(value)
		return get_tab_content('tw.html', value)
	end

	def self.get_ig_content(value)
		return get_tab_content('ig.html', value)
	end

	def self.get_yt_content(value)
		return get_tab_content('yt.html', value)
	end

	def self.get_chat_content()
		return get_tab_content('chat.html', '')
	end

	def self.get_map_content(value)
		return get_tab_content('map.html', value)
	end

	def self.get_tab_content(fileName, value)
		modelPath = get_model_path().join(fileName)
		content = File.read(modelPath)
		content.sub! '[value]', value
		return content
	end

	def self.get_model_path()
		return Rails.root.join('modelos').join('htmls');
	end

	def self.set_chat_tab(appPath, tabName, appName)
		tabPath = appPath.join('src').join('pages').join(tabName)
		chatModels = Rails.root.join('modelos').join('chat');
		IO.copy_stream(chatModels.join('chat.scss'), tabPath.join(tabName + ".scss"))

		tsFilePath = tabPath.join(tabName + ".ts")
		IO.copy_stream(chatModels.join('chat.ts'), tsFilePath)

		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1];
		replace(tsFilePath, 'chat.html') { |match| tabName + ".html"}
		replace(tsFilePath, 'ChatPage') { |match| tabNameForPage + "Page"}
		replace(tsFilePath, '[appName]') { |match| appName}
	end

	def self.set_ws_tab(appPath, tabName, appName, wsUrl)
		tabPath = appPath.join('src').join('pages').join(tabName).join(tabName + ".ts")
		wsModel = Rails.root.join('modelos').join('dummyForWS.ts');
		IO.copy_stream(wsModel, tabPath)

		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(tabPath, '[WsUrl]') { |match| wsUrl}
		replace(tabPath, '[pageName]') { |match| tabName}
		replace(tabPath, '[pageTitle]') { |match| tabNameForPage + "Page"}

	end

	def self.show
		sleep 22
	end

	def self.transform_name(originalName)
		tabName = originalName.gsub(/\s+/, "").downcase
		tabName = replace_numbers(tabName)
		return tabName
	end

	def self.replace_numbers(name)
		name = name.gsub('1', "one")
		name = name.gsub('2', "two")
		name = name.gsub('3', "three")
		name = name.gsub('4', "four")
		name = name.gsub('5', "five")
		name = name.gsub('6', "six")
		name = name.gsub('7', "seven")
		name = name.gsub('8', "eight")
		name = name.gsub('9', "nine")
		name = name.gsub('0', "ten")
		return name;
	end
end
