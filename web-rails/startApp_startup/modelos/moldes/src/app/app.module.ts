import { NgModule, ErrorHandler } from '@angular/core';
import { IonicApp, IonicModule, IonicErrorHandler } from 'ionic-angular';
import { MyApp } from './app.component';
import { PageonePage } from '../pages/pageone/pageone';
import { PagetwoPage } from '../pages/pagetwo/pagetwo';

@NgModule({
  declarations: [
    MyApp,
    PageonePage,
    PagetwoPage
  ],
  imports: [
    IonicModule.forRoot(MyApp)
  ],
  bootstrap: [IonicApp],
  entryComponents: [
    MyApp,
    PageonePage,
    PagetwoPage
  ],
  providers: [{provide: ErrorHandler, useClass: IonicErrorHandler}]
})
export class AppModule {}
