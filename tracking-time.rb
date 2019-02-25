class TrackingTime
    USER_ID = ENV['TT_USER_ID'] # I found this by inspecting the XHR req while logged in

    include HTTParty
    base_uri 'app.trackingtime.co/api/v4'

    attr_reader :query

    def initialize(query = {})
        @query = query

        month = (query[:months_ago].to_i || 0).months.ago
        @query[:from] ||= month.beginning_of_month
        @query[:to] ||= month.end_of_month #- 1.day

        @auth = { username: ENV['TT_LOGIN'], password: ENV['TT_PASSWORD'] }
    end

    def entries
        self.class.get('/events', options)['data'].map{|e| Entry.new(query, e) }
    end

    def hours
        (entries.sum{|e| e['duration']}.to_f / 60 / 60).round(2)
    end

    def expected_hours
        to = query[:months_ago] ? query[:to] : (Date.today + 1.day)
        query[:from].to_datetime.business_days_until(to) * 8
    end

    def duration
        "between #{query[:from]} to #{query[:to]}"
    end

    protected

    def options
        {
            basic_auth: @auth,
            headers: {"User-Agent" => 'TimeFetcher (nathan@stitt.org)'}, # TT docs say you have to include this
            query: query.merge({
                filter: 'USER',
                id: USER_ID,
            })
        }
    end
end
