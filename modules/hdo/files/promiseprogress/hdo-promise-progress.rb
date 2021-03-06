#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'ostruct'
require 'erb'
require 'date'
require 'time'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'uri'

opts = OpenStruct.new

OptionParser.new do |opt|
  opt.on('-i', '--input FILE', String) { |i| opts.input = i }
  opt.on('-o', '--output DIR', String) { |o| opts.output = o }
  opt.on('-h', '--help') {
    puts opt
    exit
  }
end.parse!(ARGV)

unless opts.input && opts.output
  abort "missing --input and --output"
end

data = JSON.parse(open(opts.input).read)

promises = data['data']['promises']
errors = []

stats = {
  total: promises.size,
  completed: 0,
  kept: 0,
  broken: 0,
  partly_kept: 0,
  not_yet: 0,
  unknown: 0,
  error: 0,
  bullshit: 0
}

stats[:categories] = Hash.new { |hash, key| hash[key] = {total: 0, completed: 0} }
stats[:total] = promises.size
stats[:completed] = 0
stats[:kept] = 0
stats[:broken] = 0
stats[:not_yet] = 0
stats[:by_person] = Hash.new do |h, k|
  h[k] = {
    total: 0,
    completed: 0,
    kept: 0,
    broken: 0,
    partly_kept: 0,
    not_yet: 0,
    unknown: 0,
    error: 0,
    bullshit: 0
  }
end

promises.each_with_index do |p, idx|
  p['row']  = idx + 2;
  completed = p['Ferdigsjekka?'].to_s.downcase == 'ja'
  name      = p['Hvem sjekker?'].to_s.downcase.strip
  svada     = p['Kan ikke etterprøves'].to_s.downcase == 'ja'
  categories = p['Kategori'].to_s.split(';')

  pers = stats[:by_person][name]
  pers[:total] += 1
  pers[:unknown] += 1

  if svada
    stats[:bullshit] += 1
    pers[:bullshit] += 1
  end

  case p['Holdt?'].to_s.downcase
  when 'ja'
    stats[:kept] += 1
    pers[:kept] += 1
  when 'nei'
    stats[:broken] += 1
    pers[:broken] += 1
  when 'delvis'
    stats[:partly_kept] += 1
    pers[:partly_kept] += 1
  when 'ikke enda'
    stats[:not_yet] += 1
    pers[:not_yet] += 1
  when ''
    if completed && !svada
      errors << p
      stats[:error] += 1
      pers[:error] += 1
    else
      stats[:unknown] += 1
      pers[:unknown] += 1
    end
  else
    STDERR.puts "invalid value: #{p['Holdt?'].inspect}"
  end

  if completed
    stats[:completed] += 1
    pers[:completed] += 1
  end

  categories.each do |c|
    stats[:categories][c][:total] += 1
    stats[:categories][c][:completed] += 1 if completed
  end
end

election = Date.new(2017, 9, 11)
campaign = Date.new(2017, 4, 1)
launch   = Date.new(2017, 7, 1)

stats[:percent_complete] = ((stats[:completed] / stats[:total].to_f) * 100).round(1)
stats[:percent_not_yet]  = ((stats[:not_yet] / stats[:total].to_f) * 100).round(1)
stats[:remaining]        = stats[:total] - stats[:completed]
stats[:days_to_election] = (election - Date.today).to_i
stats[:days_to_campaign] = (campaign - Date.today).to_i
stats[:days_to_launch]   = (launch - Date.today).to_i
stats[:errors]           = errors

stats_path = File.join(opts.output, 'stats.json')
saved_stats = {'by_date' => {}}

if File.exists?(stats_path)
  saved_stats = JSON.parse(File.read(stats_path))
end

saved_stats['current'] = stats
saved_stats['by_date'][Time.now.strftime("%Y-%m-%d")] = stats

File.open(stats_path, 'w') { |io| io << saved_stats.to_json }

File.open(File.join(opts.output, "index.html"), "w") do |io|
  io << ERB.new(DATA.read, 0, "%-<>").result(binding)
end

is_notify_time = Time.now.strftime("%a %H:%M") == 'Tue 12:00'

if ENV['SLACK_HOOK'] && (is_notify_time || ENV['SLACK_TEST'])
  uri = URI(ENV['SLACK_HOOK'])

  one_week_ago = (Date.today - 7).strftime("%F");
  last_week_stats = saved_stats['by_date'][one_week_ago]

  if last_week_stats
    percent_complete         = stats[:percent_complete]
    checked_this_week        = stats[:completed] - last_week_stats['completed']
    percent_change_this_week = percent_complete - last_week_stats['percent_complete']

    message = []

    message << <<-END
God dag <!channel|channel>!

Denne uka har *#{checked_this_week} løfter* blitt sjekka ferdig, som er en endring på *#{percent_change_this_week.round(2).to_s.sub('.', ',')} %*.
Vi har nå sjekket ferdig *#{percent_complete.round(2).to_s.sub('.', ',')}* %, og bare *#{stats[:remaining]} løfter* gjenstår.
    END

    if checked_this_week > 0
      weeks_remaining = (stats[:remaining] / checked_this_week)
      done_date       = (Date.today + (weeks_remaining * 7)).strftime("%e %b %Y")

      message << "Med dette tempoet vil vi være klare til lansering om *#{weeks_remaining} uker*, altså *#{done_date}*."
    end

    message << "Det er for tiden *#{stats[:errors].length} feil* i arket. <https://files.holderdeord.no/analyse/2017/loftesjekk|Klikk her> for hele oversikten."
    message << "\n\nHvem kommer på arbeidskveld?"

    req         = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body    = {
      username: 'Løftesjekk',
      text: message.join("\n"),
      channel: ENV['SLACK_TEST'] ? "#jari-test" : '#general'
    }.to_json

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    res = http.start { |agent| agent.request req }

    if res.code != "200"
      puts "slack hook failed: #{res.code}"
    end
  end
end

__END__
<html>
  <head>
    <meta charset="utf-8">
    <meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes, shrink-to-fit=no" />
    <link rel="stylesheet" href="//files.holderdeord.no/dev/hdo-bootstrap/hdo-bootstrap.css"></link>

    <style>
      .hdo-logo {
        margin-top: 1rem;
        padding-top: 3rem;
        text-align: center;
        background-position: 50% 0;
        background-repeat: no-repeat;
        background-size: auto 2.5rem;
        font-weight: 600;
      }

      .huge {
        font-size: 7rem;
        line-height: 1.2;
      }

      .vertical-align {
        display: flex;
        flex-direction: row;
      }

      @media screen and (max-width: 768px) {
        .vertical-align {
          flex-direction: column;
        }
      }

      .vertical-align > .vertical-align-item {
        display: flex;
        align-items: center;     /* Align the flex-items vertically */
        justify-content: center; /* Optional, to align inner flex-items
                                    horizontally within the column  */
      }
    </style>
  </head>

  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-12 text-xs-center">
          <h3><div class="hdo-logo"></div> Løftesjekk 2017</h3>
        </div>
      </div>

      <div class="row vertical-align">
        <div class="col-md-8">
          <div id="person-column"></div>
        </div>

        <div class="col-md-4 text-xs-center vertical-align-item">
          <div>
            <div class="huge"><%= stats[:percent_complete].to_s.sub('.', ',') %>%</div>
            <div>ferdig</div>

            <div class="huge"><%= stats[:percent_not_yet].to_s.sub('.', ',') %>%</div>
            <div>kan ikke avgjøres enda</div>
          </div>
        </div>
      </div>

      <div class="row">
        <div id="timeline" />
      </div>

      <hr />

      <div class="row text-xs-center vertical-align">
        <div class="col-md-6 vertical-align-item">
          <div>
            <div class="huge"><%= stats[:days_to_election] %></div>
            <div>dager til valget <%= election.strftime('%e. %b').downcase %></div>
            <div><%= (stats[:remaining] / stats[:days_to_election].to_f).round(1).to_s.sub('.', ',') %> løfter per dag</div>
          </div>
        </div>

        <div class="col-md-6 vertical-align-item">
          <div>
            <div class="huge"><%= stats[:days_to_launch] %></div>
            <div>dager til lansering <%= launch.strftime("%e. %b").downcase %></div>
            <div><%= (stats[:remaining] / stats[:days_to_launch].to_f).round(1).to_s.sub('.', ',') %> løfter per dag</div>
          </div>
        </div>
      </div>

      <div class="row">
          <div class="col-md-12">
            <div id="promise-status"></div>
          </div>
      </div>

      <div class="row">
          <div class="col-md-12">
            <h3>Feil</h3>

            <table class="table table-condensed">
              <thead>
                <tr>
                  <td>Rad</td>
                  <td>ID</td>
                  <td>Løfte</td>
                  <td>Hvem</td>
                </tr>
              </thead>

              <tbody>
                <% stats[:errors].each_with_index do |error| %>
                  <tr>
                    <td>
                      <%= error['row'] %>
                    </td>
                    <td>
                      <%= error['ID'] %>
                    </td>
                    <td>
                      <%= error['Løfte'] %>
                    </td>
                    <td>
                      <%= error['Hvem sjekker?'] %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <div class="row">
              <div class="col-md-12">
                <h3>Prosent ferdigsjekka etter kategori</h3>
                <div id="categories-column"></div>
              </div>
          </div>
      </div>
    </div>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.14.1/moment.min.js"></script>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/highcharts/4.2.6/highcharts.js"></script>

    <script type="text/javascript">
      Highcharts.setOptions({
          global: {
              useUTC: false
          },

          lang: {
              numericSymbols: null,
              decimalPoint: ',',
              months: ['Januar', 'Februar', 'Mars', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Desember'],
              shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Des'],
              weekdays: ['Søndag', 'Mandag', 'Tirsdag', 'Onsdag', 'Torsdag', 'Fredag', 'Lørdag'],
              thousandsSep: ' '
          },

          colors: [
              '#b8bfcc',
              '#fadd00',
              'rgb(43, 43, 43)',
              'rgb(0, 166, 212)',
              '#d00',
              '#FA0',
              '#006800',
              '#97D3EB'
          ],

          chart: {
              reflow: true, // see https://github.com/highcharts/highcharts/issues/3478
              backgroundColor: 'transparent',

              style: {
                  width: '100%'
              }
          },

          xAxis: {
              lineColor: '#ddd',
              gridLineWidth: 0,
              minorGridLineWidth: 0,
              tickWidth: 0,
              labels: {
                  style: {
                      fontWeight: '600'
                  }
              }
          },

          yAxis: {
              min: 0,
              tickPosition: 'inside',
              gridLineWidth: 1,
              gridLineColor: 'rgba(221, 221, 221, 0.6)',
              title: {
                  enabled: false
              },
              labels: {
                  style: {
                      fontWeight: 'normal',
                      color: '#999'
                  }
              }
          },

          title: {
              style: {
                  color: '#111',
                  font: 'bold 16px "Roboto", Helvetica Neue", "Helvetica", Arial, sans-serif'
              }
          },

          subtitle: {
              style: {
                  color: '#666',
                  font: 'normal lighter 12px "Roboto", "Helvetica Neue", "Helvetica", Arial, sans-serif'
              }
          },

          legend: {
              itemStyle: {
                  font: '9pt "Roboto", "Helvetica Neue", "Helvetica", Arial, sans-serif',
                  color: '#111'
              },

              itemHoverStyle: {
                  color: 'gray'
              }
          },

          plotOptions: {
              area: {
                  marker: {
                      enabled: false
                  }
              }
          },

          credits: {
              enabled: false
          }
      });

      var stats = <%= saved_stats.to_json %>;

      $(function() {
        $("#promise-status").highcharts({
          chart: {
            type: 'pie'
          },

          title: {
            text: 'Løftestatus'
          },

          series: [
            {
              name: 'Antall løfter',
              data: [
                { name: 'Holdt',                y: stats.current.kept },
                { name: 'Delvis holdt',         y: stats.current.partly_kept },
                { name: 'Brutt',                y: stats.current.broken },
                { name: 'Kan ikke etterprøves', y: stats.current.bullshit },
              ]
            }
          ]
        })

        var names = Object.keys(stats.current.by_person).filter(function(e) { return e; });

        $("#person-column").highcharts({
          chart: {
            type: 'bar'
          },

          title: {
            text: ''
          },

          plotOptions: {
              series: {
                  pointPadding: 0,
                  // groupPadding: 0,
                  borderWidth: 0.5,
              },
          },

          xAxis: {
            type: 'category',
            categories: names
          },

          yAxis: {
            allowDecimals: false
          },

          series: [
            { name: 'Totalt',               data: names.map(function(name) { return stats.current.by_person[name].total; })},
            { name: 'Ferdigsjekka',         data: names.map(function(name) { return stats.current.by_person[name].completed; })},
            { name: 'Ikke enda',            data: names.map(function(name) { return stats.current.by_person[name].not_yet; })},
            { name: 'Kan ikke etterprøves', data: names.map(function(name) { return stats.current.by_person[name].bullshit; })},
            { name: 'Feil',                 data: names.map(function(name) { return stats.current.by_person[name].error; })},
          ]
        })

        var dates = Object.keys(stats.by_date).sort();

        $("#timeline").highcharts({
          chart: {
            type: 'area'
          },

          xAxis: {
            type: 'datetime',
          },

          title: {
            text: ''
          },

          plotOptions: {
            area: {
              stacking: 'normal',
              lineColor: '#666666',
              lineWidth: 1,
              marker: {
                lineWidth: 1,
                lineColor: '#666666'
              }
            }
          },

          series: [
            {
              name: 'Gjenstår',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].remaining] })
            },
            {
              name: 'Ferdigsjekka',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].completed] })
            },
            {
              name: 'Ikke enda',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].not_yet] })
            },
            {
              name: 'Kan ikke etterprøves',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].bullshit] })
            },
            {
              name: 'Feil',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].error] })
            },
          ]
        })
      });

      var categoryData = Object.keys(stats.current.categories).map(function(name) {
        var total = stats.current.categories[name].total;
        var completed = stats.current.categories[name].completed;

        return {
          name: name,
          completed: completed,
          total: total,
          percent: 100 * (completed / total)
        };
      }).sort(function(a, b) { return b.percent - a.percent; });

      $("#categories-column").highcharts({
        chart: {
          type: 'bar',
          height: 1200
        },

        title: {
          text: ''
        },

        plotOptions: {
            series: {
                pointPadding: 0,
                // groupPadding: 0,
                borderWidth: 0.5,
            },
        },

        xAxis: {
          type: 'category',
          categories: categoryData.map(function(c) {
            return c.name;
          }),
          labels: {
            step: 1,
            style: {
              fontSize: '9px',
              fontWeight: 300
            }
          },
          // tickInterval: 1,
        },

        yAxis: {
          allowDecimals: false,
          max: 100
        },

        series: [
          {
            name: 'Prosent ferdigsjekka etter kategori',
            data: categoryData.map(function(c) {
              return c.percent;
            })
          }
        ]
      });

    </script>
  </body>
</html>