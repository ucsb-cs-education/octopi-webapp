//= require laplaya
//= require idle-timer

function set_record_time_functions() {
    $(document).on("idle.idleTimer", function () {
        //when a user goes idle, record the time it occurred and prevent further recording
        recordTime()
        user_is_interacting_with_page = false;
    });

    $(document).on("active.idleTimer", function () {
        //when a user returns, create a new time interval and record the beginning of interaction
        $.ajax({
            type: 'POST',
            url: '/time_intervals',
            format: 'json',
            data: {
                task_response_id: laplaya_task_response_id,
                begin_time: (new Date().getTime() / 1000)
            },

            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            success: function (data) {
                time_interval_id = data.id
            }
        })
        user_is_interacting_with_page = true;
    });

    recordTime = function (beginTime) {
        if (user_is_interacting_with_page) {
            var ajax_data;
            if (beginTime) {
                ajax_data = {
                    begin_time: beginTime,
                    end_time: (new Date().getTime() / 1000)
                }
            } else {
                ajax_data = {
                    end_time: (new Date().getTime() / 1000)
                }
            }
            $.ajax({
                type: 'PATCH',
                url: '/time_intervals/' + time_interval_id,
                format: 'json',
                data: ajax_data,

                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
                }
            })
        }
    }

    recordTime(new Date().getTime() / 1000);
    setInterval(recordTime, 30000);
}