require 'json'

class Stockor
    TASK_PREFIX = {
        3989924 => 'AN: '.freeze
    }
    include HTTParty
    base_uri 'https://argosity.stockor.com/api/skr'

    # logger ::Logger.new STDOUT

    def post_entry(e)
        cookie = CookieHash.new
        cookie.add_cookies('lanes.session' => ENV['SESSION_COOKIE'])
        description = (TASK_PREFIX[e['task_id']] || '').dup
        description << e['notes']
        body = self.class.post(
            '/time-entries.json', {
                verify: false,
                headers: {
                    'Content-Type' => 'application/json',
                    'Cookie' => cookie.to_cookie_string,
                },
                body: {
                    lanes_user_id: 1,
                    customer_project_id: 1,
                    is_invoiced: false,
                    start_at: DateTime.parse(e['start']).iso8601,
                    end_at: DateTime.parse(e['end']).iso8601,
                    description: description,
                    options: { tt_id: e['id'] }
                }.to_json
            }
        ).body
        JSON.parse(body)
    end

end
