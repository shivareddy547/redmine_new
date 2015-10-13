
$(document).on('click', '#user_billable', function() {
    // code here
    //alert("++++")
    member_id = $(this).attr("member_id");
   if($(this).val() == "Billable") {
       //alert("billable")
        var billable_status= true
        $('<input>').attr({
            type: 'hidden',
            id: 'member_billable_'+member_id,
            name: 'billable',
            value: billable_status
        }).appendTo('#member-'+member_id+'-roles-form');

    }
    else if($(this).val() == "NonBillable")
    {

        //alert("Non billable")
        var billable_status= false
        $('<input>').attr({
            type: 'hidden',
            id: 'member_billable_'+member_id,
            name: 'billable',
            value: billable_status
        }).appendTo('#member-'+member_id+'-roles-form');

    }
    else{
       var billable_status= ""
       $('<input>').attr({
           type: 'hidden',
           id: 'member_billable_'+member_id,
           name: 'billable',
           value: billable_status
       }).appendTo('#member-'+member_id+'-roles-form');

   }

});

$(document).on('click', 'table.members .icon-edit', function() {
    $(this).closest('tr').find("#user_billable").attr("disabled", false);
    var billable_status = $(this).closest('tr').find("#member_billable_status").val();
    var member_id = $(this).closest('tr').find("#member_billable_status").attr("member_id");
    $('#member-'+member_id+'-roles-form').find('a').attr('id', 'cancel_member');
    $('#member-'+member_id+'-roles-form').find('a').attr('member_id', member_id);
    console.log(billable_status);
    console.log(member_id);

    $('<input>').attr({
        type: 'hidden',
        id: 'member_billable_'+member_id,
        name: 'billable',
        value: billable_status
    }).appendTo('#member-'+member_id+'-roles-form');



});

$(document).on('click', '#cancel_member', function() {
    var billable_status = $(this).closest('tr').find("#member_billable_status").val();
    //alert(billable_status);
    var member_id = $(this).attr("member_id");
    if(billable_status=="true")
    {

        $(this).closest('tr').find("#user_billable").prop('checked', true);
    }
    else{

        $(this).closest('tr').find("#user_billable").prop('checked', false);
    }

    $(this).closest('tr').find("#user_billable").attr("disabled", true);
    return false;

});