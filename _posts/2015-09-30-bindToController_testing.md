---
layout: post
title: "Unit Testing Angular Directives with bindToController"
---

Angular's `controllerAs` and `bindToController` directive options have worked wonders to enforce good practices on my code.  However, these can make other good practices, namely unit testing, a bit less straightforward.  A bit of extra plumbing in your tests (and `ngMocks` greater than `1.3.15`) can easily work around these issues.

## $controller Service and Binding Parameters

ngMocks 1.3.15 introduced a third parameter to the `$controller` service that allows tests to inject controller bound parameters.  [The Angular documentation](https://code.angularjs.org/1.3.15/docs/api/ngMock/service/$controller) explains the functionality very succinctly.  An example using jasmine tests follows below:

```html
<!DOCTYPE html>
<html ng-app="example">

  <head>
    <link data-require="jasmine@*" data-semver="2.2.1" rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/jasmine/2.2.1/jasmine.css" />
    <script data-require="jasmine@*" data-semver="2.2.1" src="http://cdnjs.cloudflare.com/ajax/libs/jasmine/2.2.1/jasmine.js"></script>
    <script data-require="jasmine@*" data-semver="2.2.1" src="http://cdnjs.cloudflare.com/ajax/libs/jasmine/2.2.1/jasmine-html.js"></script>
    <script data-require="jasmine@*" data-semver="2.2.1" src="http://cdnjs.cloudflare.com/ajax/libs/jasmine/2.2.1/boot.js"></script>
    <script data-require="angular.js@~1.3.15" data-semver="1.3.17" src="https://code.angularjs.org/1.3.17/angular.js"></script>
    <script data-require="angular-mocks@1.3.15" data-semver="1.3.15" src="https://code.angularjs.org/1.3.15/angular-mocks.js"></script>
    <script src="script.js"></script>
  </head>

  <body>
    <h3>Odd Numbers</h3>
    <ex-odd-number-lister in-items="[1, 2, 3, 4, 5]"></ex-odd-number-lister>
  </body>

</html>
```

```javascript
// module
(function() {
  angular.module('example', []);
})();

// directive
(function() {
  function OddNumberLister() {
    return {
      controller: 'ExampleController',
      controllerAs: 'vm',
      bindToController: true,
      scope: {
        inItems: '=',
      },
      template: "<ul><li ng-repeat='oddItem in vm.oddDataItems()'>{{oddItem}}</li></ul>",
    };
  }

  angular.module('example').directive('exOddNumberLister', OddNumberLister);
})();

// controller
(function() {
  function ExampleController() {
    var vm = this;

    vm.oddDataItems = function() {
      return vm.inItems.filter(function(item) {
        return 1 === (item % 2);
      });
    }
  }
  angular.module('example').controller('ExampleController', ExampleController);
})();

// tests
(function() {
  describe('ExampleController', function() {

    beforeEach(module('example'));

    var exampleController;
    var expectedInItems;

    beforeEach(inject(function($controller) {
      expectedInItems = [1, 2, 3];
      var locals = {};
      var bindingsParams = {
        inItems: expectedInItems,
      };
      exampleController = $controller('ExampleController', locals, bindingsParams);
      console.log(exampleController.inItems);
    }));

    describe('when it is constructed', function() {
      it('can be constructed', function() {
        expect(exampleController).toBeDefined();
        expect(exampleController).not.toBeNull();
      });

      it('sets inItems from the scope', function() {
        expect(exampleController.inItems).toBe(expectedInItems);
      });
    });

    describe('oddDataItems()', function() {
      it('filters even items', function() {
        expect(exampleController.oddDataItems().length).toBe(2);
        expect(exampleController.oddDataItems()[0]).toBe(1);
        expect(exampleController.oddDataItems()[1]).toBe(3);
      });
    });
  });
})();
```

Demo [here (plnkr)](http://plnkr.co/edit/LRkiD4?p=preview)
