#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'ostruct'
require 'erb'
require 'date'
require 'time'

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

data = JSON.parse(File.read(opts.input))

promises = data['data']['promises']

stats = {
  total: promises.size,
  completed: 0,
  kept: 0,
  broken: 0,
  partly_kept: 0,
  not_yet: 0,
  unknown: 0,
}

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
    unknown: 0
  }
end

promises.each do |p|
  completed = p['Ferdigsjekka?'].to_s.downcase == 'ja'
  name      = p['Hvem sjekker?']

  pers = stats[:by_person][name]
  pers[:total] += 1

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
    stats[:unknown] += 1
    pers[:unknown] += 1
  else
    STDERR.puts "invalid value: #{p['Holdt?'].inspect}"
  end

  if completed
    stats[:completed] += 1
    pers[:completed] += 1
  end
end

election = Date.new(2017, 9, 11)
campaign = Date.new(2017, 4, 1)

stats[:percent_complete] = ((stats[:completed] / stats[:total].to_f) * 100).round(1)
stats[:percent_not_yet] = ((stats[:not_yet] / stats[:total].to_f) * 100).round(1)
stats[:remaining] = stats[:total] - stats[:completed]
stats[:days_to_election] = (election - Date.today).to_i
stats[:days_to_campaign] = (campaign - Date.today).to_i

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
            <div class="huge"><%= stats[:days_to_campaign] %></div>
            <div>dager til valgkampstart <%= campaign.strftime("%e. %b").downcase %></div>
            <div><%= (stats[:remaining] / stats[:days_to_campaign].to_f).round(1).to_s.sub('.', ',') %> løfter per dag</div>
          </div>
        </div>
      </div>

      <div class="row">
          <div class="col-md-12">
            <div id="promise-status"></div>
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
        // $("#complete-pie").highcharts({
        //   chart: {
        //     type: 'pie'
        //   },

        //   title: {
        //     text: ''
        //   },

        //   series: [{
        //     name: 'Antall løfter',
        //     data: [
        //       {name: 'Ikke ferdig', y: stats.current.remaining },
        //       {name: 'Ferdig', y: stats.current.completed }
        //     ]
        //   }]
        // });

        $("#promise-status").highcharts({
          chart: {
            type: 'pie'
          },

          title: {
            text: 'Løftestatus'
          },

          series: [
            {
              name: 'Status',
              data: [
                { name: 'Holdt',        y: stats.current.kept },
                { name: 'Delvis holdt', y: stats.current.partly_kept },
                { name: 'Brutt',        y: stats.current.broken },
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
            {name: 'Totalt', data: names.map(function(name) { return stats.current.by_person[name].total; })},
            {name: 'Ferdigsjekka', data: names.map(function(name) { return stats.current.by_person[name].completed; })},
            {name: 'Ikke enda', data: names.map(function(name) { return stats.current.by_person[name].not_yet; })},
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
              name: 'Totalt',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].total] })
            },
            {
              name: 'Ferdigsjekka',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].completed] })
            },
            {
              name: 'Ikke enda',
              data: dates.map(function(d) { return [moment(d).valueOf(), stats.by_date[d].not_yet] })
            }
          ]
        })
      })
    </script>
  </body>
</html>