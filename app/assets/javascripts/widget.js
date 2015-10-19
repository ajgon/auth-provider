(function () {
    // jscs: disable
    // form serialize
    function serialize(form){if(!form||form.nodeName!=="FORM"){return }var i,j,q=[];for(i=form.elements.length-1;i>=0;i=i-1){if(form.elements[i].name===""){continue}switch(form.elements[i].nodeName){case"INPUT":switch(form.elements[i].type){case"text":case"hidden":case"password":case"button":case"reset":case"submit":case"email":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"checkbox":case"radio":if(form.elements[i].checked){q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value))}break;case"file":break}break;case"TEXTAREA":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"SELECT":switch(form.elements[i].type){case"select-one":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"select-multiple":for(j=form.elements[i].options.length-1;j>=0;j=j-1){if(form.elements[i].options[j].selected){q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].options[j].value))}}break}break;case"BUTTON":switch(form.elements[i].type){case"reset":case"submit":case"button":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break}break}}return q.join("&")}; // jshint ignore:line

    // nanoajax
    !function(e,t){function n(e){return e&&t.XDomainRequest&&!/MSIE 1/.test(navigator.userAgent)?new XDomainRequest:t.XMLHttpRequest?new XMLHttpRequest:void 0}function o(e,t,n){e[t]=e[t]||n}t.nanoajax=e;var r=["responseType","withCredentials","timeout","onprogress"];e.ajax=function(e,t){function u(e,n){return function(){d||t(c.status||e,c.response||c.responseText||n,c),d=!0}}var a=e.headers||{},s=e.body,i=e.method||(s?"POST":"GET"),d=!1,c=n(e.cors);c.open(i,e.url,!0);var l=c.onload=u(200);c.onreadystatechange=function(){4===c.readyState&&l()},c.onerror=u(null,"Error"),c.ontimeout=u(null,"Timeout"),c.onabort=u(null,"Abort"),s&&(o(a,"X-Requested-With","XMLHttpRequest"),o(a,"Content-Type","application/x-www-form-urlencoded"));for(var p,f=0,v=r.length;v>f;f++)p=r[f],void 0!==e[p]&&(c[p]=e[p]);for(var p in a)c.setRequestHeader(p,a[p]);return c.send(s),c}}({},function(){return this}()); // jshint ignore:line
    // jscs: enable

    (function () {
        /* global serialize, nanoajax */
        'use strict';

        var AuthProviderWidget = function (options) {
            this._applyOptions(options);
            this._initDOM();
            this._initEvents();
        };

        var signInTemplate =
            '<:namespace:sign-in>' +
                '<:namespace:h1>Sign In</:namespace:h1>' +
                '<:namespace:loading>Loading...</:namespace:loading>' +
                '<:namespace:content>' +
                    '<:namespace:message></:namespace:message>' +
                    '<form id=":namespace:sign-in-form">' +
                        '<input type="email" name="user[email]" id=":namespace:sign-in-email" />' +
                        '<input type="password" name="user[password]" id=":namespace:sign-in-password" />' +
                        '<button type="submit" id=":namespace:sign-in-submit">Sign In</button>' +
                    '</form>' +
                '</:namespace:content>' +
            '</:namespace:sign-in>';

        AuthProviderWidget.prototype = {
            signin: function () {
                this._wipeContainer();
                this._showTemplate('signIn');
            },
            _applyOptions: function (options) {
                var o;
                this.options = {
                    namespace: 'auth-provider',
                    signIn: {
                        template: signInTemplate
                    }
                }; // defaults

                for (o in options) {
                    if (options.hasOwnProperty(o)) {
                        this.options[o] = options[o];
                    }
                }
                if (!this.options.domain) {
                    throw 'Missing "domain" parameter!';
                }
                if (!this.options.callbackURL) {
                    throw 'Missing "callbackURL" parameter!';
                }
                if (!this.options.clientID) {
                    throw 'Missing "clientID" parameter!';
                }
            },
            _initDOM: function () {
                var parentTag = this._ns('widget'), parent;
                if (!document.querySelector('body > ' + parentTag)) {
                    parent = document.createElement(parentTag);
                    this.container = document.body.appendChild(parent);
                }
            },
            _initEvents: function () {
                var self = this;
                this.container.addEventListener('submit', function (e) {
                    if (e.target.getAttribute('id') === self._ns('sign-in-form')) {
                        e.preventDefault();
                        self._ajax({
                            url: '/login/usernamepassword',
                            method: 'POST',
                            body: serialize(e.target) + '&client_id=' + self.options.clientID +
                                  '&redirect_uri=' + self.options.callbackURL +
                                  (self.options.state ? '&state=' + self.options.state : '') +
                                  (self.options.responseType ? '&response_type=' + self.options.responseType : ''),
                            cors: true,
                            withCredentials: true
                        });
                    }
                });
            },
            _ns: function (item) {
                if (!this.options.namespace) {
                    return item;
                }
                if (!item || item === '') {
                    return this.options.namespace + '-';
                }
                return this.options.namespace + '-' + item;
            },
            _ajax: function (options) {
                var callback, dummy, self = this;
                this._loading(true);
                options.headers = options.headers || {};
                options.success = options.success || function () {};
                options.error = options.error || this._ajaxError;
                options.url = 'http://' + this.options.domain + options.url;
                if (!options.headers.Accept) {
                    options.headers.Accept = 'application/json, */*';
                }
                callback = function (status, response, xhr) {
                    if (xhr.getResponseHeader('Content-Type').match(/text\/html/)) {
                        dummy = document.createElement('div');
                        dummy.innerHTML = response;
                        dummy.firstChild.submit();
                    } else {
                        response = JSON.parse(response);
                        if (response.location) {
                            window.location.href = response.location;
                            return;
                        }
                        if (status < 300) {
                            return options.success.call(self, response);
                        }
                        return options.error.call(self, response);
                    }
                };
                nanoajax.ajax(options, callback);
            },
            _ajaxError: function (response) {
                this._loading(false);
                this.container.querySelector(this._ns('message')).textContent = response.error;
            },
            _loading: function (active) {
                this._toggleElement(this.container.querySelector(this._ns('loading')), active);
                this._toggleElement(this.container.querySelector(this._ns('content')), !active);
            },
            _toggleElement: function (element, active) {
                if (element) {
                    element.style.display = active ? 'block' : 'none';
                }
            },
            _wipeContainer: function () {
                this.container.innerHTML = '';
            },
            _showTemplate: function (template) {
                this.container.innerHTML = this.options[template].template.replace(/:namespace:/g, this._ns());
                this._loading(false);
            }
        };

        window.AuthProviderWidget = function (options) {
            var self = this;
            this.widget = new AuthProviderWidget(options);
            this.signin = function () {
                self.widget.signin.call(self.widget);
            };
        };
    })();
})();
