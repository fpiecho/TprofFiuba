import { Component, ViewChild } from '@angular/core';
import { Nav, Platform } from 'ionic-angular';
import { StatusBar, Splashscreen } from 'ionic-native';
import { Push, PushToken } from '@ionic/cloud-angular';

import { PageonePage } from '../pages/pageone/pageone';
import { PagetwoPage } from '../pages/pagetwo/pagetwo';


@Component({
  templateUrl: 'app.html'
})
export class MyApp {
  @ViewChild(Nav) nav: Nav;

  rootPage: any = PageonePage;

  pages: Array<{title: string, component: any}>;

  constructor(public platform: Platform, public push: Push) {
    this.initializeApp();

    // used for an example of ngFor and navigation
    this.pages = [
      //,
      { title: 'Page1', component: PageonePage },
      { title: 'Page2', component: PagetwoPage }
    ];

    if (!this.platform.is('core')) {
      this.push.register().then((t: PushToken) => { return this.push.saveToken(t); }).then((t: PushToken) => {
        console.log('Token saved:', t.token);
      });
      this.push.rx.notification().subscribe((msg) => { alert(msg.title + ': ' + msg.text); });
    }
  }

  initializeApp() {
    this.platform.ready().then(() => {
      // Okay, so the platform is ready and our plugins are available.
      // Here you can do any higher level native things you might need.
      StatusBar.styleDefault();
      Splashscreen.hide();
    });
  }

  openPage(page) {
    // Reset the content nav to have just this page
    // we wouldn't want the back button to show in this scenario
    this.nav.setRoot(page.component);
  }
}
