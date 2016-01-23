(function(){
  var app = angular.module('nanny',['ui.router', 'ngRoute']);

  app.config(function ($routeProvider, $locationProvider, $stateProvider, $urlRouterProvider) {
    $routeProvider
      .when('/', {
        templateUrl: "views/dashboard.html",
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
      });

    $locationProvider.html5Mode(false);
  });

  app.controller('GlobalCtrl', function($rootScope, $scope, $location, $routeParams, $http){
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
    $scope.data = {
      text: "hello"
    }
  });
// root controller for home page
})();
