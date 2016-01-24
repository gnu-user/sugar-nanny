(function(){
  var app = angular.module('nanny',['ui.router', 'ngRoute']);

  app.config(function ($routeProvider, $locationProvider, $stateProvider, $urlRouterProvider) {
    $routeProvider
      .when('/', {
        templateUrl: "views/dashboard.html",
        controller: "DashCtrl"
      })
      .when('/about', {
        templateUrl: "views/about.html",
        controller: "DashCtrl"
      })
      .when('/readings', {
        templateUrl: "views/readings.html",
        controller: "DashCtrl"
      })
      .when('/meals', {
        templateUrl: "views/meals.html",
        controller: "DashCtrl"
      })
      .when('/history', {
        templateUrl: "views/history.html",
        controller: "DashCtrl"
      })
      .when('/foodInformation', {
        templateUrl: "views/foodInfo.html",
        controller: "DashCtrl"
      })


      ;

    $locationProvider.html5Mode(false);
  });

  app.controller('GlobalCtrl', function($rootScope, $scope, $location, $routeParams, $http){
    $scope.notifications = [
      {
        "txt":"test",
        "time":"notification time"
      }
    ]
    $rootScope.$on( "$routeChangeStart", function(event, next, current) {
      var page = $location.path().substr(1)
      if(page != ""){
        $scope.title = page.charAt(0).toUpperCase() + page.slice(1)
      } else {
        $scope.title = "Dashboard"
      }

    });
  });

  app.controller('DashCtrl', function($rootScope, $scope, $routeParams, $http){

    $scope.page = "Dashboard"

      // Calories
      // Fat
      // Cholesterol
      // Sodium
      // Carbohydrates
      // Fibre
      // Sugar
      // Protein
    $scope.doSearch = function() {
      if($scope.search.length > 3){

          $http({method: 'GET', url: 'http://jsonplaceholder.typicode.com/users'}).
            success(function(data, status, headers, config) {
              $scope.searchResults = data
          }).
            error(function(data, status, headers, config) {
            // called asynchronously if an error occurs
            // or server returns response with an error status.
            console.log('page not found:', data);
          });
      };
    };

    $scope.foodSelected = function(rows) {

      $http({
        method: 'GET',
        url: 'http://jsonplaceholder.typicode.com/users'
      }).
        success(function(data, status, headers, config) {
          $scope.foodInformation = data;
      }).
        error(function(data, status, headers, config) {
        // called asynchronously if an error occurs
        // or server returns response with an error status.
        console.log('page not found:', data);
      });
    };

  });
// root controller for home page
})();
