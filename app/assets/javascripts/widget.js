(function () {
    // jscs: disable
    // form serialize
    function serialize(form){if(!form||form.nodeName!=="FORM"){return }var i,j,q=[];for(i=form.elements.length-1;i>=0;i=i-1){if(form.elements[i].name===""){continue}switch(form.elements[i].nodeName){case"INPUT":switch(form.elements[i].type){case"text":case"hidden":case"password":case"button":case"reset":case"submit":case"email":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"checkbox":case"radio":if(form.elements[i].checked){q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value))}break;case"file":break}break;case"TEXTAREA":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"SELECT":switch(form.elements[i].type){case"select-one":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break;case"select-multiple":for(j=form.elements[i].options.length-1;j>=0;j=j-1){if(form.elements[i].options[j].selected){q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].options[j].value))}}break}break;case"BUTTON":switch(form.elements[i].type){case"reset":case"submit":case"button":q.push(form.elements[i].name+"="+encodeURIComponent(form.elements[i].value));break}break}}return q.join("&")}; // jshint ignore:line

    // nanoajax
    !function(e,t){function n(e){return e&&t.XDomainRequest&&!/MSIE 1/.test(navigator.userAgent)?new XDomainRequest:t.XMLHttpRequest?new XMLHttpRequest:void 0}function o(e,t,n){e[t]=e[t]||n}t.nanoajax=e;var r=["responseType","withCredentials","timeout","onprogress"];e.ajax=function(e,t){function u(e,n){return function(){d||t(c.status||e,c.response||c.responseText||n,c),d=!0}}var a=e.headers||{},s=e.body,i=e.method||(s?"POST":"GET"),d=!1,c=n(e.cors);c.open(i,e.url,!0);var l=c.onload=u(200);c.onreadystatechange=function(){4===c.readyState&&l()},c.onerror=u(null,"Error"),c.ontimeout=u(null,"Timeout"),c.onabort=u(null,"Abort"),s&&(o(a,"X-Requested-With","XMLHttpRequest"),o(a,"Content-Type","application/x-www-form-urlencoded"));for(var p,f=0,v=r.length;v>f;f++)p=r[f],void 0!==e[p]&&(c[p]=e[p]);for(var p in a)c.setRequestHeader(p,a[p]);return c.send(s),c}}({},function(){return this}()); // jshint ignore:line

    // deepmerge
    function deepmerge(e,o){var t=Array.isArray(o),c=t&&[]||{};return t?(e=e||[],c=c.concat(e),o.forEach(function(o,t){"undefined"==typeof c[t]?c[t]=o:"object"==typeof o?c[t]=deepmerge(e[t],o):-1===e.indexOf(o)&&c.push(o)})):(e&&"object"==typeof e&&Object.keys(e).forEach(function(o){c[o]=e[o]}),Object.keys(o).forEach(function(t){c[t]="object"==typeof o[t]&&o[t]&&e[t]?deepmerge(e[t],o[t]):o[t]})),c} // jshint ignore:line
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
                        '<:namespace:providers></:namespace:providers>' +
                        '<button type="submit" id=":namespace:sign-in-submit">Sign In</button>' +
                    '</form>' +
                '</:namespace:content>' +
            '</:namespace:sign-in>';
        var providerTemplate =
            '<:namespace:provider>' +
              '<a class=":namespace:provider-link">' +
                '<:namespace:provider-name></:namespace:provider-name>' +
              '</a>' +
            '</:namespace:provider>';

        AuthProviderWidget.prototype = {
            signIn: function (options) {
                var self = this;
                options = options === undefined ? {} : options;
                this._wipeContainer();
                this._showTemplate('signIn');
                this._loadProviders(this.options.signIn.providerTemplate, function () {
                    if (options.beforeRender) {
                        options.beforeRender(self.container);
                    }
                });
            },
            close: function () {
                this.container.className = this._ns('hidden');
            },
            _applyOptions: function (options) {
                var o;
                this.options = {
                    namespace: 'auth-provider',
                    responseType: 'code',
                    signIn: {
                        template: signInTemplate,
                        providerTemplate: providerTemplate
                    }
                }; // defaults

                this.options = deepmerge(this.options, options);
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
                    parent.className = 'auth-provider-hidden';
                    this.container = document.body.appendChild(parent);
                } else {
                    this.container = document.querySelector('body > ' + parentTag);
                }
            },
            _initEvents: function () {
                var self = this;
                this.container.addEventListener('submit', function (e) {
                    if (e.target.getAttribute('id') === self._ns('sign-in-form')) {
                        e.preventDefault();
                        self._ajax({
                            url: '/login/usernamepassword?response_type=' + self.options.responseType,
                            method: 'POST',
                            body: serialize(e.target) + '&client_id=' + self.options.clientID +
                                  '&redirect_uri=' + self.options.callbackURL +
                                  (self.options.state ? '&state=' + self.options.state : ''),
                            cors: true,
                            withCredentials: true
                        });
                    }
                });
            },
            _loadProviders: function (template, callback) {
                var self = this;
                var providersContainer = this.container.querySelector(this._ns('providers'));
                callback = callback === undefined ? function () {} : callback;
                if (!providersContainer) {
                    callback();
                    return;
                }
                this._ajax({
                    url: '/widget?response_type=' + this.options.responseType,
                    body: 'client_id=' + this.options.clientID +
                          '&redirect_uri=' + self.options.callbackURL +
                          (this.options.state ? '&state=' + this.options.state : ''),
                    cors: true,
                    success: function (response) {
                        var r, provider, providerItem;
                        for (r = 0; r < response.providers.length; r += 1) {
                            provider = response.providers[r];
                            providerItem = document.createElement('div');
                            providerItem.innerHTML = template.replace(/:namespace:/g, this._ns());
                            providerItem = providerItem.querySelector(this._ns('provider'));
                            providerItem.className = provider.slug;
                            providerItem.querySelector('.' + this._ns('provider-link'))
                                        .setAttribute('href', provider.url);
                            providerItem.querySelector(this._ns('provider-name')).textContent = provider.name;
                            providersContainer.appendChild(providerItem);
                        }
                        self._loading(false);
                        callback(providersContainer);
                    },
                    error: function (response) {
                        self._loading(false);
                        callback();
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
                    var n;
                    if (xhr.getResponseHeader('Content-Type').match(/text\/html/)) {
                        dummy = document.createElement('div');
                        dummy.innerHTML = response;
                        // document.body.appendChild(dummy.firstChild);
                        for (n = 0; n < dummy.childNodes.length; n += 1) {
                            if (dummy.childNodes[n].submit) {
                                dummy.childNodes[n].setAttribute('id', 'auth-provider-widget-form-step-2');
                                document.body.appendChild(dummy.childNodes[n]);
                                document.getElementById('auth-provider-widget-form-step-2').submit();
                            }
                        }
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
                this._setMessage(response.error);
            },
            _setMessage: function (message) {
                this.container.querySelector(this._ns('message')).textContent = message;
                this._toggleElement(this.container.querySelector(this._ns('message-container')), true);
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
                this._toggleElement(this.container.querySelector(this._ns('message-container')), false);
                this._loading(false);
                this.container.className = this._ns('visible');
            }
        };

        window.AuthProviderWidget = function (options) {
            var self = this;
            this.widget = new AuthProviderWidget(options);
            this.signIn = function (options) {
                self.widget.signIn.call(self.widget, options);
            };
            this.close = function () {
                self.widget.close.call(self.widget);
            };
            this.container = self.widget.container;
        };
    })();
})();
