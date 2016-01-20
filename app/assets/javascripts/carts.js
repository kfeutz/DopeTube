$( document ).ready(function() {

  $(".btn-convert-vids").click(function(){
    var vid_title = $('input[name=title]').val();
    var vid_artist = $('input[name=artist]').val();
    var vid_album = $('input[name=album]').val();

    alert(vid_title + " " + vid_artist + " " + vid_album);

    var $video_rows_to_delete = $('.video-row').toArray();
    var $pending_download_titles = $('.video-title').toArray();
    for(var i = 0; i < $video_rows_to_delete.length; i++) {
      $('.top_progress_file_row').after(
        "<tr class=\"audio-row\">"
            + "<td class=\"audio-title\">" + $pending_download_titles[i].text + "</td>" 
            + "<td>DOWNLOAD AND CONVERSION PENDING ...</td>" 
          + "</tr>"
      );
      $video_rows_to_delete[i].remove();
    }
    $('.panel-videos').css('overflow', 'hidden');
    $('.panel-videos').animate({height: '0px'});
    var format_to_convert = $('#audioFormatDropdown option:selected').text();
    $.ajax({
      url: "/cart/convert_videos.json" + "?file_format=" + format_to_convert,
      dataType: "json",
      error: function() {
        $('body').append("AJAX Error");
      },
      success: function(data, textStatus, jqXHR) {
        console.log(data.length)
        console.log('data length: (json array) ' + data.length)
        var $pending_download_delete= $('.audio-row').toArray();
        for(var i = 0; i < $pending_download_delete.length; i++) {
          $pending_download_delete[i].remove();
        }

        for(var i = 0; i < data.length; i++) {
          var audio_file = data[i];
          $('.top_audio_file_row').after(
            "<tr>"
            + "<td>" + audio_file.title.replace("_", " ") + "</td>" 
            + "<td>" + audio_file.artist + "</td>" 
            + "<td>" + audio_file.album + "</td>" 
            + "<td>" + audio_file.length + "</td>" 
            + "<td>" + audio_file.file_format + "</td>" 
          + "</tr>"
          );
        }
      }
    });
  });

  $(".btn-download-audio").click(function(){
    var $audio_file_rows = $('#audioFileRow').toArray();
    for(var i = 0; i < $audio_file_rows.length; i++) {
      $audio_file_rows[i].remove();
    }
  });
});
