;(function( $, window, document, undefined ){

  $('.delete').on('click', function (e) {
    e.preventDefault();
    var location = $(this).attr('href');

    bootbox.confirm('Are you sure you want to delete this user?', function(result){
      if ( result ) {
         window.location.replace(location);
      }
    });
  });

})( jQuery, window, document );
