(function(){
  var app = angular.module('nanny',['ui.router', 'ngRoute']);

  app.config(function ($routeProvider, $locationProvider, $stateProvider, $urlRouterProvider) {
    $routeProvider
      .when('/', {
        templateUrl: "views/dashboard.html",
        controller: "DashCtrl"
      })
      .when('/meals', {
        templateUrl: "views/meals.html",
        controller: "DashCtrl"
      });

    $locationProvider.html5Mode(false);
  });

  app.controller('GlobalCtrl', function($rootScope, $scope, $routeParams, $http){

    $scope.page = "Dashboard"
    $scope.title = "whatever"
  });
  
  app.controller('DashCtrl', function($rootScope, $scope, $routeParams, $http){

    $scope.page = "Dashboard"
    $scope.data = {
      text: "hello"
    }
  });
// root controller for home page
})();