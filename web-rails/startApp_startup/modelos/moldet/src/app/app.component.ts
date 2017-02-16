import { Component } from '@angular/core';
import { Platform } from 'ionic-angular';
import { StatusBar, Splashscreen } from 'ionic-native';
import { Push, PushToken } from '@ionic/cloud-angular';

import { TabsPage } from '../pages/tabs/tabs';


@Component({
  templateUrl: 'app.html'
})
export class MyApp {
  rootPage = TabsPage;

  constructor(platform: Platform, public push: Push) {
    platform.ready().then(() => {
      // Okay, so the platform is ready and our plugins are available.
      // Here you can do any higher level native things you might need.
      StatusBar.styleDefault();
      Splashscreen.hide();
    });

    if (!platform.is('core')) {
      this.push.register().then((t: PushToken) => { return this.push.saveToken(t); }).then((t: PushToken) => {
        console.log('Token saved:', t.token);
      });
      this.push.rx.notification().subscribe((msg) => { alert(msg.title + ': ' + msg.text); });
    }
  
  }
}
