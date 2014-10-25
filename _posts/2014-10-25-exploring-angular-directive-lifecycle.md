---
layout: post
title: "Exploring the Angular Directive Life Cycle"
---

I recently dropped into a fairly advanced [Angular](http://www.angularjs.org) project and needed to get up to speed with custom directive creation quickly.  This [blog post](http://odetocode.com/blogs/scott/archive/2014/05/28/compile-pre-and-post-linking-in-angularjs.aspx) by K. Scott Allen really helped with the fundamentals of directive events but I was thrown for a loop by templates loaded inside `ng-include` directives.  After testing, it appears that the asynchronous loading of `ng-include` contents means that the `ng-include`'s contents will be processed _after_ the containing directive's post link method is called.

This makes complete sense after further reflection, but can be confusing at first.  The following code (and [Plunkr Demo](http://plnkr.co/edit/9tgzh9vEJOpb1OHMPg0B?p=preview)) illustrates the angular directive life cycle through several layers of `ng-include`s:


## `index.html`
```html
<!DOCTYPE html>
<html ng-app="exploration">

<head>
  <script data-require="angular.js@*" data-semver="1.2.18" src="https://code.angularjs.org/1.2.18/angular.js"></script>
  <script src="script.js"></script>
</head>

<body ng-controller="mainController as main">
  <div outermost>
    <h2>Test Items</h2>
    <ul>
      <li ng-repeat="item in main.repeatItems" on-repeat>
        <span ng-include="'repeatItemTemplate.html'"></span>
      </li>
    </ul>
  </div>

  <h2>Log Output</h2>
  <ul style="list-style:none; padding-left:0">
    <li ng-style="{ 'padding-left': '{{message.indentationLevel * 5}}0px'}"
        ng-repeat="message in main.messages">
        <code>{{ message.timestamp | date:'HH:mm:ss.sss' }} - {{ message.message }}</code>
    </li>
  </ul>
</body>

</html> 
```

## `repeatItemTemplate.html`
```html
<span in-template>
  <span ng-include="'repeatItemSubTemplate.html'"></span>
</span>
```

## `repeatItemSubTemplate.html`
```html
<span in-sub-template>{{item}}</span>
```

## `script.js`
```javascript
(function() {
    var module = angular.module("exploration",[]);

    var messages = [];
    var logMessage = function(message, indentationLevel) {
        messages.push({ message: message, timestamp: new Date(), indentationLevel: indentationLevel });
        console.log(message);
    };

    module.controller("mainController", ["$scope", function($scope){
        logMessage("mainController");

        var self = this;

        self.messages = messages;
        self.repeatItems = [ "one", "two", "three" ];

        var requestedCount = 0;
        var stopRequestListener = $scope.$on('$includeContentRequested', function () {
            requestedCount++;
        });

        var loadedCount = 0;
        var stopLoadListener = $scope.$on('$includeContentLoaded', function () {
            loadedCount++;
            logIncludeLoadEventCounts();
        });

        var errorCount = 0;
        var stopErrorListener = $scope.$on('$includeContentError', function () {
            errorCount++;
            logIncludeLoadEventCounts();
        });

        var logIncludeLoadEventCounts = function(){
            logMessage("mainController - include load events - requestedCount: " + requestedCount + " loadedCount: " + loadedCount);
        };
    }]);

    var createDirective = function(directiveName, indentationLevel) {
        module.directive(directiveName, ["$timeout", function($timeout){
            return {
                link: {
                    pre: function (scope, element, attrs) {
                        logMessage(directiveName + " - prelink", indentationLevel);
                    },
                    post: function (scope, element, attrs) {
                        logMessage(directiveName + " - postlink", indentationLevel);

                        scope.$evalAsync(function() {
                            logMessage(directiveName + " - postlink - scope.$evalAsync", indentationLevel);
                        }, 0);

                        $timeout(function() {
                            logMessage(directiveName + " - postlink - timeout", indentationLevel);
                        }, 0);
                    },
                },
                controller: function() {
                    logMessage(directiveName + " - controller", indentationLevel);
                },
            };
        }]);
    };

    createDirective("outermost", 1);
    createDirective("onRepeat", 2);
    createDirective("inTemplate", 3);
    createDirective("inSubTemplate", 4);
})();
```

## Output
<div class="well">
  <div outermost="">
    <h2>Test Items</h2>
    <ul>
      <!-- ngRepeat: item in main.repeatItems --><li ng-repeat="item in main.repeatItems" on-repeat="" class="ng-scope">
        <!-- ngInclude: 'repeatItemTemplate.html' --><span ng-include="'repeatItemTemplate.html'" class="ng-scope"><span in-template="" class="ng-scope">
  <!-- ngInclude: 'repeatItemSubTemplate.html' --><span ng-include="'repeatItemSubTemplate.html'" class="ng-scope"><span in-sub-template="" class="ng-binding ng-scope">one</span></span>
</span></span>
      </li><!-- end ngRepeat: item in main.repeatItems --><li ng-repeat="item in main.repeatItems" on-repeat="" class="ng-scope">
        <!-- ngInclude: 'repeatItemTemplate.html' --><span ng-include="'repeatItemTemplate.html'" class="ng-scope"><span in-template="" class="ng-scope">
  <!-- ngInclude: 'repeatItemSubTemplate.html' --><span ng-include="'repeatItemSubTemplate.html'" class="ng-scope"><span in-sub-template="" class="ng-binding ng-scope">two</span></span>
</span></span>
      </li><!-- end ngRepeat: item in main.repeatItems --><li ng-repeat="item in main.repeatItems" on-repeat="" class="ng-scope">
        <!-- ngInclude: 'repeatItemTemplate.html' --><span ng-include="'repeatItemTemplate.html'" class="ng-scope"><span in-template="" class="ng-scope">
  <!-- ngInclude: 'repeatItemSubTemplate.html' --><span ng-include="'repeatItemSubTemplate.html'" class="ng-scope"><span in-sub-template="" class="ng-binding ng-scope">three</span></span>
</span></span>
      </li><!-- end ngRepeat: item in main.repeatItems -->
    </ul>
  </div>

  <h2>Log Output</h2>
  <ul style="list-style:none; padding-left:0">
    <!-- ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.586 - mainController</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '50px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 50px;">
        <code class="ng-binding">14:47:05.586 - outermost - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '50px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 50px;">
        <code class="ng-binding">14:47:05.586 - outermost - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '50px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 50px;">
        <code class="ng-binding">14:47:05.588 - outermost - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '50px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 50px;">
        <code class="ng-binding">14:47:05.589 - outermost - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.590 - onRepeat - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.590 - onRepeat - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.591 - onRepeat - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.592 - onRepeat - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.605 - onRepeat - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.605 - onRepeat - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.605 - onRepeat - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '50px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 50px;">
        <code class="ng-binding">14:47:05.637 - outermost - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.639 - onRepeat - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.642 - onRepeat - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '100px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 100px;">
        <code class="ng-binding">14:47:05.645 - onRepeat - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.662 - inTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.662 - inTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.663 - inTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.663 - mainController - include load events - requestedCount: 3 loadedCount: 1</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.664 - inTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.664 - inTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.664 - inTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.664 - mainController - include load events - requestedCount: 3 loadedCount: 2</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.665 - inTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.665 - inTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.665 - inTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.665 - mainController - include load events - requestedCount: 3 loadedCount: 3</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.666 - inTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.666 - inTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.666 - inTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.687 - inTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.691 - inTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '150px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 150px;">
        <code class="ng-binding">14:47:05.694 - inTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.720 - inSubTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.720 - inSubTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.720 - inSubTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.720 - mainController - include load events - requestedCount: 6 loadedCount: 4</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.721 - inSubTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.721 - inSubTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.721 - inSubTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.721 - mainController - include load events - requestedCount: 6 loadedCount: 5</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.721 - inSubTemplate - controller</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.722 - inSubTemplate - prelink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.722 - inSubTemplate - postlink</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': 'NaN0px'}" ng-repeat="message in main.messages" class="ng-scope">
        <code class="ng-binding">14:47:05.722 - mainController - include load events - requestedCount: 6 loadedCount: 6</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.722 - inSubTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.722 - inSubTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.722 - inSubTemplate - postlink - scope.$evalAsync</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.745 - inSubTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.749 - inSubTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages --><li ng-style="{ 'padding-left': '200px'}" ng-repeat="message in main.messages" class="ng-scope" style="padding-left: 200px;">
        <code class="ng-binding">14:47:05.756 - inSubTemplate - postlink - timeout</code>
    </li><!-- end ngRepeat: message in main.messages -->
  </ul>
</div>
