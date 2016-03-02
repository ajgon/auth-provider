/* global jQuery */

(function ($) {
    'use strict';

    var self = this;

    $('body').on('click', '.app-sign-in', function (e) {
        e.preventDefault();
        if (self.widget) {
            self.widget.signIn({
                beforeRender: function () {
                    self.componentHandler.upgradeDom();
                }
            });
        }
    });
}.call(window, jQuery));
