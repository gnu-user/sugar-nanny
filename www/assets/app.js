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
      .when('/insulin', {
        templateUrl: "views/insulin.html",
        controller: "DashCtrl"
      })
      .when('/history', {
        templateUrl: "views/history.html",
        controller: "DashCtrl"
      })
      .when('/foodInformation', {
        templateUrl: "views/foodInfo.html",
        controller: "DashCtrl"
      });

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

  app.controller('DashCtrl', function($rootScope, $scope, $location, $routeParams, $http){

    $scope.page = "Dashboard"

    $http(
      {method: 'GET',
       url: 'http://api.sugarnanny.tech/stats/blood_sugar/1'}
     )
          .success(function(data, status, headers, config) {
              $scope.sugarData = data.data;

          }).
            error(function(data, status, headers, config) {
            // called asynchronously if an error occurs
            // or server returns response with an error status.
            console.log('page not found:', data);
          });
//http://api.sugarnanny.tech/history/insulin/1
    $http({method: 'GET', url: 'http://api.sugarnanny.tech/history/insulin/1'})
          .success(function(data, status, headers, config) {
              $scope.insulinIntake = data.data
              console.log(data.data)
          }).
            error(function(data, status, headers, config) {
            console.log('page not found:', data);
          });

    $http({method: 'GET', url: 'http://api.sugarnanny.tech/stats/meals/1'})
          .success(function(data, status, headers, config) {
              $scope.mealsHistory = data.data
              console.log(data.data)
          }).
            error(function(data, status, headers, config) {
            console.log('page not found:', data);
          });


    $scope.doSearch = function() {
      if($scope.search.length > 3){
          $http({method: 'GET', url: 'http://api.sugarnanny.tech/food/search/' + $scope.search}).
            success(function(data, status, headers, config) {
              $scope.searchResults = data.data;
          }).
            error(function(data, status, headers, config) {
            // called asynchronously if an error occurs
            // or server returns response with an error status.
            console.log('page not found:', data);
          });
      };
    };

    $scope.sendInsulin = function(insulin) {
      console.log(insulin)

      $http(
      {method: 'GET',
       url: 'http://api.sugarnanny.tech/readings/insulin/1/'+insulin.units})
          .success(function(data, status, headers, config) {
              console.log(insulin);
          }).
            error(function(data, status, headers, config) {
            // called asynchronously if an error occurs
            // or server returns response with an error status.
            console.log('page not found:', data);
          });
    }
    $scope.sendBloodSugar = function(bloodsugar) {
      console.log(bloodsugar)

      $http(
      {method: 'GET',
       url: 'http://api.sugarnanny.tech/readings/blood_sugar/1/'+bloodsugar.units})
          .success(function(data, status, headers, config) {
              console.log(bloodsugar);
          }).
            error(function(data, status, headers, config) {
            // called asynchronously if an error occurs
            // or server returns response with an error status.
            console.log('page not found:', data);
          });
    }
    $scope.foodSelected = function(rows) {
      $http({
        method: 'GET',
        url: 'http://api.sugarnanny.tech/food/calculate/1/' 
             + rows.food_id + '/1'
      }).
        success(function(data, status, headers, config) {
          $scope.insulinInfo = data.data;
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
