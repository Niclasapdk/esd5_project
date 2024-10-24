'use strict';

class TsoftWebPush {
    
    constructor(){
        
        var _this = this;
        
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js').then(function() {
                return navigator.serviceWorker.ready;
            }).then(function(reg) {

                reg.pushManager.subscribe({
                    userVisibleOnly: true,
                    applicationServerKey: "BOw5hIuGSMUHIDpKZNRX4PaGBlklPlhJhQeIhKATQfysNtksthiesDhVDeMLoE9z-Pr9jYDGyYFRzoiyzYZLp7w",
                }).then(function(sub) {

                    var params = JSON.parse(JSON.stringify(sub));
                    var replaced = 'https://android.googleapis.com/gcm/send/';


                    let form = new FormData();
                    form.append('registration_id', params.endpoint);
                    form.append('p256dh', params.keys.p256dh);
                    form.append('auth', params.keys.auth);

                    fetch('/srv/service/guest/registerNotificationList', {
                        method: 'POST',
                        body:form
                    })
                    .then(response => response.json())
                    .then(json => {
                        console.log(json);
                    })
                    .catch(err => {
                       console.log(err); 
                    });

                    _this.setCookie('webpush', 1, 30);

                });
            }).
            catch (function(error) {
                console.log('Service Worker error :^(', error);
            });
        } 
    }
    
    setCookie(c_name, value, exdays) {
        var exdate = new Date();
        exdate.setDate(exdate.getDate() + exdays);
        var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
        document.cookie = c_name + "=" + c_value;
    }
    
    getCookie(c_name) {
        var i, x, y, ARRcookies = document.cookie.split(";");
        for (i = 0; i < ARRcookies.length; i++) {
            x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
            y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
            x = x.replace(/^\s+|\s+$/g, "");
            if (x == c_name) {
                return unescape(y);
            }
        }
    }
    
}

