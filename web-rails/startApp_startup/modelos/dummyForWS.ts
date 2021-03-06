import { Component } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';

/*
  Generated class for the Empty page.

  See http://ionicframework.com/docs/v2/components/#navigation for more info on
  Ionic pages and navigation.
*/
@Component({
  selector: 'page-[pageName]',
  templateUrl: '[pageName].html'
})
export class [pageTitle] {

  constructor(public navCtrl: NavController, public navParams: NavParams) {}

  ionViewDidLoad() {
    console.log('ionViewDidLoad [pageTitle]');

    var loadingElement = document.getElementById('loading');
    
    loadingElement.style.display = 'block';

    var xmlhttp = new XMLHttpRequest();

    xmlhttp.onreadystatechange = function() {
      if (xmlhttp.readyState == XMLHttpRequest.DONE ) {
        if (xmlhttp.status == 200) {
          console.log('OK');
          var jsonResponse = JSON.parse(xmlhttp.responseText);
          var data = jsonResponse["data"];

          for (var i = 0; i < data.length; i++){
            var obj = data[i];
            var elemToClone = document.getElementById('wsElemToCopy').cloneNode(true);
            (elemToClone as HTMLElement).id = "wsDivCopy"+i;
            (elemToClone as HTMLElement).style.display = 'block';           
            
            var elemHeight = (elemToClone as HTMLElement).style.height;
            if(elemHeight.includes("%")){
              var elemHeightNumber = Number(elemHeight.replace("%",""));
              /*var totalHeight = document.getElementById('build-screen-area').clientHeight;*/
              var totalHeight = document.getElementsByClassName('scroll-content')[1].clientHeight;
              var fixedHeight = totalHeight*elemHeightNumber/100;
              (elemToClone as HTMLElement).style.height = fixedHeight+"px";
            }

            document.getElementById('wsElemCopiesContainer').appendChild(elemToClone);

            for (var key in obj){
              var attrName = key;
              var attrValue = obj[key];
              document.getElementById('wsDivCopy'+i).getElementsByClassName('control-class-ws-'+key)[0].innerHTML = attrValue;
            }
          }
        }
        else if (xmlhttp.status == 400) {
          console.log('400');
        }
        else {
          console.log('NOSE');
        }
        loadingElement.style.display = 'none';
      }
    };

    xmlhttp.open("GET", "[WsUrl]", true);
    xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlhttp.setRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8,application/json");
    xmlhttp.withCredentials = false;
    xmlhttp.send();
  }

}

