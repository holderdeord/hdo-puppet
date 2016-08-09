#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'ostruct'
require 'erb'
require 'date'

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
stats = {}

promises = data['data']['promises']

stats[:total] = promises.size
stats[:completed] = 0
stats[:by_person] = Hash.new { |h, k| h[k] = { total: 0, completed: 0 } }

promises.each do |p|
  completed = p['ferdigsjekka?'].to_s.downcase == 'ja'
  name      = p['hvem sjekker?']

  pers = stats[:by_person][name]
  pers[:total] += 1

  if completed
    stats[:completed] += 1
    pers[:completed] += 1
  end
end

election = Date.new(2017, 9, 11)
campaign = Date.new(2017, 4, 1)

stats[:percent_complete] = ((stats[:completed] / stats[:total].to_f) * 100).round(1)
stats[:remaining] = stats[:total] - stats[:completed]
stats[:days_to_election] = (election - Date.today).to_i
stats[:days_to_campaign] = (campaign - Date.today).to_i

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
        font-size: 8rem;
        /*margin-top: 4rem;*/
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
       <div class="col-md-4">
          <div id="complete-pie"></div>
       </div>

       <div class="col-md-4 text-xs-center vertical-align-item">
         <div>
           <div class="huge"><%= stats[:percent_complete].to_s.sub('.', ',') %>%</div>
           <div>ferdig</div>
         </div>
       </div>

       <div class="col-md-4">
         <div id="person-column"></div>
       </div>
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
    </div>

    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/highcharts/4.2.6/highcharts.js"></script>

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

      var stats = <%= stats.to_json %>;

      $(function() {
        $("#complete-pie").highcharts({
          chart: {
            type: 'pie'
          },

          title: {
            text: ''
          },

          series: [{
            name: 'Antall løfter',
            data: [
              {name: 'Ikke ferdig', y: stats.remaining },
              {name: 'Ferdig', y: stats.completed }
            ]
          }]
        });

        var names = Object.keys(stats.by_person).filter(function(e) { return e; });

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

          series: [
            {name: 'Totalt', data: names.map(function(name) { return stats.by_person[name].total; })},
            {name: 'Ferdigsjekka', data: names.map(function(name) { return stats.by_person[name].completed; })},
          ]

        })
      })
    </script>
  </body>
</html>