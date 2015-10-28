$( document ).ready(function() {

   $('form.edit_user input, select').each(
        function(index){
            var input = $(this);
            var id = $(this).attr("id");
            if(id == "user_login" || id == "user_firstname" || id == "user_lastname" || id == "user_mail" || id == "user_official_info" || id == "user_auth_source_id" )
            {
                $(this).prop( "disabled", true );
            }
        }
    );
    $('div#content a.icon-del').hide();
    $('div#content a.icon-add').hide();
    $('div#content tr.user td.buttons a.icon-del').hide();

});
