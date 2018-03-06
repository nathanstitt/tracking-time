class Stockor

    include HTTParty
    base_uri 'https://argosity.stockor.com/api/skr'

    # logger ::Logger.new STDOUT

    def post_entry(e)
        cookie = CookieHash.new
        cookie.add_cookies(
            'lanes.session' => ENV['SESSION_COOKIE']
        )
        self.class.post(
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
                    description: e['notes'],
                    options: { tt_id: e['id'] }
                }.to_json
            }
        )

    end

end
