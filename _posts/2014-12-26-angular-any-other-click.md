---
layout: post
title: "An Angular 'Any Other Click' Directive"
---

I recently implemented a very plain popup menu in Angular.  Showing the menu was simple, as you would expect, but dismissing the menu threw me for a bit of a loop.  How could I have my menu respond to a click event outside of the element hosting its directive?  After a bit of thought, I wrote the following 'any other click' directive.  Basically, the directive registers a click event on the `document` element.  This click event checks to see if it was generated from the element that registered the directive.  If not, it executes the code specified in the directive attribute.  jQuery is required since [`angular.element.find()`](https://docs.angularjs.org/api/ng/function/angular.element) is limited to lookups by tag name.

## Directive Source
{% highlight javascript linenos %}
(function () {
    var module = angular.module('anyOtherClick', []);

    module.directive('anyOtherClick', ['$document', function ($document) {
        return {
            restrict: 'A',
            scope: {
                anyOtherClick: "&",
            },
            link:  function (scope, element, attr, controller) {
                var localElement = element;
                var documentClickHandler = function (event) {
                    var eventOutsideTarget = (localElement[0] !== event.target) && (0 === localElement.find(event.target).length);
                    if (eventOutsideTarget) {
                        scope.$apply(function () {
                            if (scope.anyOtherClick) {
                                scope.anyOtherClick();
                            }
                        });
                    }
                };

                $document.on("click", documentClickHandler);
                scope.$on("$destroy", function () {
                    $document.off("click", documentClickHandler);
                });
            },
        };
    }]);
})();
{% endhighlight %}

## Plunker Demo
<iframe style="width: 100%; height: 400px; background-color: white;" src="http://embed.plnkr.co/1mI8TAoTrDpIC4hQ4U4r/preview" frameborder="0" allowfullscreen="allowfullscreen"></iframe>

## Items of Interest
- Angular exposes an [`$event`](https://docs.angularjs.org/guide/expression#-event-) object during `ng-click`.  We use `$event.stopPropagation()` in the `ng-click` expression that shows the popup to prevent the popup's `any-other-click` expression from firing and immediately hiding the popup.
- As noted above, jQuery is required since [`angular.element.find()`](https://docs.angularjs.org/api/ng/function/angular.element) is limited to lookups by tag name.  Alternative pure-Angular suggestions would be greatly appreciated.

## Disclaimer

The code above is working for me in production.  However, I only use this directive a few times on my pages.  As with most things in Angular, you'd need to re-evaluate this directive's performance if it is used in a large `ng-repeat` or other looping constructs.
