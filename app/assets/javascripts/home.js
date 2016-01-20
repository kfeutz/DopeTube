
$( document ).ready(function() {

  $(".add-to-cart-btn").click(function(e){
  	vid_id = $(this).attr("id");
    $.ajax({
      url: "/home/add_to_cart" + "?video_id=" + vid_id,
      dataType: "json",
      error: function() {
        $('body').append("AJAX Error");
      },
      success: function(data, textStatus, jqXHR) {
      	$(".video-row#" + vid_id).remove();	
      }
    });
  });
});