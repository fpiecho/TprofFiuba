module MobileAppsHelper
	def self.new_page(appPath, tabName, appType)
		system("cd \"#{appPath}\" && ionic g page \"#{tabName}\"");

		if (appType == 'Tabs')
			new_tab(appPath, tabName)
		else
			new_menu_page(appPath, tabName)
		end
		

	end

	def self.new_menu_page(appPath, tabName)
		#app.ts
		tabsTsPath = appPath.join('app').join('app.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(tabsTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from './pages/" + tabName +"/" + tabName + "';" "\n" + "#{match}" }
		replace(tabsTsPath, '];') { |match| ",{ title: '" + tabName + "', component: " + tabNameForPage + "Page }" + "\n" + "#{match}" }

	end

	def self.new_tab(appPath, tabName)
		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app/theme/app.core.scss')
		
		File.open(coreCssPath, "a+") do |f|
  			f << importCore
		end


		#tabs.html
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html')
		tabLine = '<ion-tab [root]="tab' + tabName + '" tabTitle="' + tabName +'" tabIcon="' + tabName + '"></ion-tab>' + "\n"
		replace(tabsPath, /^<\/ion-tabs>/mi) { |match| tabLine + "#{match}"}

		#tabs.ts
		tabsTsPath = appPath.join('app').join('pages').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, 'constructor() {') { |match| "#{match}" + "\n" + "this.tab" + tabName + " = " + tabNameForPage + "Page;"}
		replace(tabsTsPath, 'export class TabsPage {') { |match| "#{match}" + "\n" + "private tab" + tabName + ": any;"}
		replace(tabsTsPath, '@Component({') { |match| "import {" + tabNameForPage +"Page} from '../" + tabName +"/" + tabName + "';" "\n" + "#{match}" }
	end

	def self.replace(filepath, regexp, *args, &block)
	  content = File.read(filepath).gsub(regexp, *args, &block)
	  File.open(filepath, 'wb') { |file| file.write(content) }
	end

	def self.set_content(appPath, tabName, content)
		tabPath = appPath.join('app').join('pages').join(tabName).join(tabName + '.html')
		replace(tabPath, /<ion-content padding>\n(.*\n)*<\/ion-content>/) { |match| "<ion-content padding>" + "\n" + content + "\n" + "</ion-content>"}
	end
end
