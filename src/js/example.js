(function ( W ) {
  "use strict";

  var Namespace = function () {
    this.VERSION = "0.1.0";
  };

  Namespace.prototype.removeHeader = function () {
    $( "h1" ).remove();
  };

  Namespace.prototype.calculateTotal = function ( digits ) {
    return digits.reduce( function( prev, current ){
      return prev + current;
    }, 0);
  };

  Namespace.prototype.subscribeToObserver = function ( observer ) {
    observer.subscribe( this );
  };

  W.ns = new Namespace();

}( this ));
