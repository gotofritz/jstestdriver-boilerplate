describe( "example ", function(){
  "use strict";

  beforeEach( function() {
    jasmine.getFixtures().fixturesPath = "/test/fixtures";
    jasmine.getJSONFixtures().fixturesPath = "/test/fixtures";
  });


  /////////////////////////////////////////////////////////////// version
  describe( "version", function(){

    it( "has a version", function(){

      var version = ns.VERSION
        , split = version.split(".")
        ;

      expect( split.length ).toEqual( 3 );
    });

  });


  /////////////////////////////////////////////////////////////// removeHeader
  describe( "removeHeader", function(){

    it( "removes the header if found", function(){
      jasmine.getFixtures().load( "example.html" );

      expect( $( "h1" ).length ).toEqual( 1 );
      ns.removeHeader();
      expect( $( "h1" ).length ).toEqual( 0 );
    });

  });


  ////////////////////////////////////////////////////////////// loadData
  describe( "loadData", function(){

    it( "calculates the sum of numbers", function(){
      var jsonFile = jasmine.getJSONFixtures().load( "example.json" )
        , jsonData = jsonFile[ "example.json" ]
        , actual
        , expected = 2 + 4 + 6 + 8
        ;

      actual = ns.calculateTotal(jsonData.digits);

      expect( actual ).toEqual( expected );

    });

  });

  ////////////////////////////////////////////////////////////// subscribeToObserver
  describe( "subscribeToObserver", function(){

    it( "calls the subscribe method of the object passed int", function(){
      var observer = { subscribe : function(){} }
        , spy = sinon.spy( observer, "subscribe" )
        ;

      ns.subscribeToObserver(observer);

      expect( spy ).toHaveBeenCalledOnce();

    });

  });


});