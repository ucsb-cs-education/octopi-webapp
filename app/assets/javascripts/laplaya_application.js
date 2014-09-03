//= require laplaya
//= require idle-timer

function set_record_time_functions() {
    $(document).on("idle.idleTimer", function () {
        //when a user goes idle, record the time it occurred and prevent further recording
        complete_time_interval();
        user_is_interacting_with_page = false;
    });

    $(document).on("active.idleTimer", function () {
        //when a user returns, create a new time interval and record the beginning of interaction
        $.ajax({
            type: 'POST',
            url: '/time_intervals',
            format: 'json',
            data: {
                task_response_id: laplaya_task_response_id
            },

            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            success: function (data) {
                time_interval_id = data.id
            }
        });
        user_is_interacting_with_page = true;
    });

    recordTime = function () {
        if (user_is_interacting_with_page) {
            $.ajax({
                type: 'PATCH',
                url: '/time_intervals/' + time_interval_id,
                format: 'json',

                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                }
            });
        }
    };

    complete_time_interval = function (unload) {
        unload = unload || false
        $.ajax({
            type: 'PATCH',
            async: false,//!unload,
            url: '/time_intervals/' + time_interval_id + '/complete',
            format: 'json',

            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            }
        });
    };

    recordTime();
    setInterval(recordTime, 30000);
}

$(window).unload(function () {
    if (typeof complete_time_interval !== 'undefined') {
        recordTime()
        complete_time_interval(true);
    }
});