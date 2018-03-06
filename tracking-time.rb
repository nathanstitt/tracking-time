class TrackingTime
    USER_ID = ENV['TT_USER_ID'] # I found this by inspecting the XHR req while logged in

    include HTTParty
    base_uri 'app.trackingtime.co/api/v4'

    attr_reader :query

    def initialize(query = {})
        @query = query
        @query[:from] ||= Date.civil(Date.today.year, Date.today.month).strftime
        @query[:to] ||= Date.civil(Date.today.year, Date.today.month+1, -1).strftime
        @auth = { username: ENV['TT_LOGIN'], password: ENV['TT_PASSWORD'] }
    end

    def entries
        self.class.get('/events', options)['data']
    end

    def hours
        (entries.sum{|e| e['duration']}.to_f / 60 / 60).round(2)
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
