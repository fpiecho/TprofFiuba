module MobileAppsHelper

	def self.create_app(name, userPath, appType)
		FileUtils.mkdir_p(userPath) unless File.directory?(userPath)
        appPath = userPath.join(name);
        modelName = get_model_name(appType);
        modelPath = Rails.root.join('modelos').join(modelName);
        FileUtils.cp_r modelPath, appPath
        replace_on_app_creation(appPath, name, modelName);

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

	def self.new_page(appPath, tabName, appType)
		system("cd \"#{appPath}\" && ionic g page \"#{tabName}\"");

		if (appType == 'Tabs')
			new_tab(appPath, tabName.downcase)
		else
			new_menu_page(appPath, tabName.downcase)
		end
	end

	def self.new_menu_page(appPath, tabName)
		#app.ts
		tabsTsPath = appPath.join('app').join('app.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(tabsTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from './pages/" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
		replace(tabsTsPath, /\}((?!,)[\S\s])*];/) { |match| "},\n { title: '" + tabName + "', component: " + tabNameForPage + "Page }" + "\n" + "    ];" }

		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		
		File.open(coreCssPath, "a+") do |f|
  			f << importCore
		end

		#page.html 
		pagePath = appPath.join('app').join('pages').join(tabName).join(tabName + '.html')
		replace(pagePath, '<ion-navbar>') { |match| "#{match}" + '<button menuToggle>
      <ion-icon name="menu"></ion-icon>
    </button>' }

	end

	def self.new_tab(appPath, tabName)
		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		
		File.open(coreCssPath, "a+") do |f|
  			f << importCore
		end

		#tabs.html
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html')
		tabLine = '<ion-tab [root]="tab' + tabName + '" tabTitle="' + tabName +'" tabIcon="' + tabName + '"></ion-tab>' + "\n"
		replace(tabsPath, /<\/ion-tabs>/mi) { |match| tabLine + "#{match}"}

		#tabs.ts
		tabsTsPath = appPath.join('app').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, 'constructor() {') { |match| "#{match}" + "\n" + "this.tab" + tabName + " = " + tabNameForPage + "Page;"}
		replace(tabsTsPath, 'export class TabsPage {') { |match| "#{match}" + "\n" + "public tab" + tabName + ": any;"}
		replace(tabsTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from '../" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
	end

	def self.replace(filepath, regexp, *args, &block)
		content = File.read(filepath).gsub(regexp, *args, &block)
		File.open(filepath, 'wb') { |file| file.write(content) }
	end

	def self.set_content(appPath, tabName, content)
		tabPath = appPath.join('app').join('pages').join(tabName).join(tabName + '.html')
		replace(tabPath, /<ion-content padding>\n(.*\n)*<\/ion-content>/) { |match| "<ion-content padding>" + "\n" + content + "\n" + "</ion-content>"}
	end


	def self.delete_page(appPath, tabName, appType)
		tabsPath = appPath.join('app').join('pages');
		count = Dir.entries(tabsPath).delete_if {|i| i == "." || i == ".." || i == "tabs"}.count;
		if(count > 1)
			FileUtils.rm_rf(tabsPath.join(tabName))

			if (appType == 'Tabs')
				delete_tab(appPath, tabName)
			else
				delete_menu_page(appPath, tabName, appType)
			end
		end
	end

	def self.delete_menu_page(appPath, tabName, appType)
		#app.ts
		appTsPath = appPath.join('app').join('app.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(appTsPath, "import { " + tabNameForPage +"Page } from './pages/" + tabName +"/" + tabName + "';" + "\n" ) { |match| '' }
		replace(appTsPath, /,((?!,)[\S\s])*{ title: '#{tabName}', component: #{tabNameForPage}Page }/) { |match| '' }
		#rootPage
		somePage = get_pages(appPath, appType)[0][0];
		tabNameForSomePage = somePage[0].upcase + somePage[1..somePage.length - 1]		
		replace(appTsPath, "rootPage: any = " + tabNameForPage + "Page;") {|match| "rootPage: any = " + tabNameForSomePage +"Page;"}
		

		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		replace(coreCssPath, importCore) { |match|  }

	end

	def self.delete_tab(appPath, tabName)
		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		replace(coreCssPath, importCore) { |match|  }

		#tabs.html
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html')
		replace(tabsPath, /<ion-tab \[root\]=\".*\" tabTitle=\"#{tabName}\" tabIcon=\".*\"><\/ion-tab>\n/) { |match| ''}

		#tabs.ts
		tabsTsPath = appPath.join('app').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, /this.tab.* = #{tabNameForPage}Page;\n/) { |match| ''  }
		replace(tabsTsPath, "public tab" + tabName + ": any;"+ "\n") { |match| ''}
		replace(tabsTsPath, "import { " + tabNameForPage +"Page } from '../" + tabName +"/" + tabName + "';" + "\n") { |match|  '' }
	end

	def self.get_pages(appPath, appType)
		if(appType == 'tabs')
			return get_pages_tabs(appPath, appType);
		else
			return get_pages_menu(appPath, appType);
		end

	end

	def self.get_pages_tabs(appPath, appType)
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html');
		fileText = File.read(tabsPath);
		return fileText.scan(/tabTitle=\"(.*)\" tabIcon/);
	end

	def self.get_pages_menu(appPath, appType)
		appTsPath = appPath.join('app').join('app.ts')
		fileText = File.read(appTsPath);
		return fileText.scan(/title: \'(.*)\',/);
	end

	def self.page_exists(appPath, name)
		tabsPath = appPath.join('app').join('pages')
		return Dir.entries(tabsPath).include?(name)
	end
end
