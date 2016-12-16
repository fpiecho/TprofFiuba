import {Page} from 'ionic-angular';
import { AlertController } from 'ionic-angular';
import {NgZone} from '@angular/core';
declare var io;

@Page({
  templateUrl: 'build/pages/chat/chat.html'
})
export class ChatPage {
    chatinp: string= null;
    zone: NgZone= null;;
    chats : ChatMessage[];
    socket: any = null;
    nickname: string =null;
    someBool: boolean = true;
    appName='[appName]'

    static get parameters() {
        return [NgZone, AlertController];
    }
    constructor(ngzone, private alertController: AlertController) {
        this.zone = ngzone;
        this.chats = [];
        this.chatinp ='';
        this.socket = io('http://localhost:4567');
        this.socket.on('message', (msg) => {
            this.zone.run(() => {
                if(msg.appName == this.appName)
                    this.chats.push(msg);
            });
        });
        this.nickname = 'nickname';
    }
    
    send(msg) {
        if(msg != ''){
            var message: ChatMessage = new ChatMessage(this.nickname, msg, this.appName);
            this.socket.emit('message', message);
        }
        this.chatinp = '';
    }

    ngAfterViewInit(){
        let alert = this.alertController.create({
                title: 'What\'s your nickname?',
                inputs: [{
                    name: 'title',
                    placeholder: 'nickname'
                }],
            buttons: [{
                text: 'Save',
                type: 'button-positive',
                handler: data => {
                    this.nickname = data.title;
                }
            }]
        });
        alert.present();
    }
}

export class ChatMessage {
   user: string;
   message:string;
   appName: string;

   constructor(user, message, appName){
       this.user = user;
       this.message=message;
       this.appName = appName;
   }
}