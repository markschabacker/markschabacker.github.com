---
layout: post
title: "Angular Service as a Kendo DataSource"
---

I have been working a bit with an Angular app that makes heavy use of Kendo controls.  I was apprehensive at first but the Angular/Kendo bindings are actually fairly pleasant to use.  However, my team ran into a small gotcha regarding binding a Kendo grid to the results of an Angular service method.

Initially we bound the Kendo grid to an [`ObservableArray`](http://docs.telerik.com/kendo-ui/api/javascript/data/observablearray) property on the controller.  However, that broke quite a bit of the grid's built-in functionality like the loading indicator and refresh button.  After a bit of investigation, we settled on a more idiomatic Kendo solution by calling the Angular service in the [`transport.read`](http://docs.telerik.com/kendo-ui/api/javascript/data/datasource#configuration-transport.read) function as follows:

```html
<!DOCTYPE html>
<html ng-app='demo'>

<head>
  <title>Kendo Grid with Angular Service Datasource</title>
  <link href="https://kendo.cdn.telerik.com/2015.2.624/styles/kendo.common.min.css" rel="stylesheet">
  <link href="https://kendo.cdn.telerik.com/2015.2.624/styles/kendo.default.min.css" rel="stylesheet">
  <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
  <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.3.0/angular.js"></script>
  <script src="https://kendo.cdn.telerik.com/2015.2.624/js/kendo.all.min.js"></script>
  <script src='https://cdnjs.cloudflare.com/ajax/libs/lodash.js/3.10.0/lodash.min.js'></script>
  <script type="text/javascript">
    (function() {
      angular.
      module('demo', ['kendo.directives']).
      controller('demoController', ['demoService', function(demoService) {
        var vm = this;
        vm.getGridOptions = function() {
          return {
            dataSource: {
              type: 'json',
              transport: {
                read: function(options) {
                  demoService.getData().
                  then(function(results) {
                    options.success(results)
                  }).
                  catch(function(error) {
                    options.error(error);
                  });
                },
              },
              pageSize: 5,
            },
            sortable: true,
            pageable: true,
            height: 250,
            columns: [{
              field: 'firstName',
              title: 'First Name',
            }, {
              field: 'lastName',
              title: 'Last Name',
            }, ]
          };
        };
      }]).
      service('demoService', ['$q', '$timeout', function($q, $timeout) {
        return {
          getData: function() {
            // This could be $http or any other promise returning service.
            // Use a deferred and $timeout to simulate a network request.
            var deferred = $q.defer()

            $timeout(function() {
              var fakeResults = _.range(1, 21).map(function(i) {
                return {
                  firstName: 'first name ' + i,
                  lastName: 'last name ' + i,
                };
              });
              deferred.resolve(fakeResults);
            }, 2000);

            return deferred.promise;
          },
        };
      }]);
    })();
  </script>
</head>

<body ng-controller='demoController as demo'>
  <div kendo-grid k-options='demo.getGridOptions()'></div>
</body>

</html>
```

Demo [here (plnkr)](http://plnkr.co/edit/1zUx2w?p=preview)
