
$(document).on('click', '#user_billable', function() {
    // code here
    member_id = $(this).attr("member_id");


    if($(this).is(":checked")) {
        var billable_status= true
        $('<input>').attr({
            type: 'hidden',
            id: 'member_billable_'+member_id,
            name: 'billable',
            value: billable_status
        }).appendTo('#member-'+member_id+'-roles-form');


//             <input id="member_billable_6826" name="billable" type="hidden" value="true">

//        $("#member_billable_"+member_id).val("true")
    }
    else
    {
        var billable_status= false
        $('<input>').attr({
            type: 'hidden',
            id: 'member_billable_'+member_id,
            name: 'billable',
            value: billable_status
        }).appendTo('#member-'+member_id+'-roles-form');
//        $("#member_billable_"+member_id).val("false")
    }

});

$(document).on('click', 'table.members .icon-edit', function() {
    $(this).closest('tr').find("#user_billable").attr("disabled", false);

    var billable_status = $(this).closest('tr').find("#member_billable_status").val();
    var member_id = $(this).closest('tr').find("#member_billable_status").attr("member_id");
    console.log(billable_status);
    console.log(member_id);

    $('<input>').attr({
        type: 'hidden',
        id: 'member_billable_'+member_id,
        name: 'billable',
        value: billable_status
    }).appendTo('#member-'+member_id+'-roles-form');

});

