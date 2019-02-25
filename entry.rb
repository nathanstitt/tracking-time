class Entry < Hashie::Mash

    def initialize(query, entry)
        @query = query
        super(entry)
    end

    def start_date
        DateTime.parse(start)
    end

    def end_date
        DateTime.parse(self['end'])
    end

    def in_range?
        @query[:from] <= start_date && @query[:to] >= end_date
    end

    def to_s
        "#{task_id} #{start_date.strftime('%m/%d')} #{(duration.to_f / 60 / 60).round(2)} #{task}: #{notes}"
    end


end
