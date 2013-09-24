sub vcl_error {
  if (obj.status == 801) {
     set obj.status = 301;
     set obj.response = "Moved Permanently";
     set obj.http.Location = "https://" req.http.host req.url;
     synthetic {""};
     return (deliver);
  }

  if (req.http.Fastly-Restart-On-Error) {
    if (obj.status == 503 && req.restarts == 0) {
      restart;
    }
  }

#--FASTLY ERROR START
  {
    if (obj.status == 550) {
      return(deliver);
    }
  }
#--FASTLY ERROR END

  #
  # error response if all else fails
  #

  set obj.http.Content-Type = "text/html; charset=utf-8";
  set obj.http.Retry-After = "5";

  synthetic {"
  <!DOCTYPE html>
  <html lang="no">
    <head>
      <meta charset="UTF-8">
      <title>Holder de ord</title>
      <meta property='og:description' content='Holder de ord er en politisk uavhengig organisasjon som kartlegger norske politiske partiers løfter og sammenligner disse med hva de gjør på storting og i regjering.' />
      <style type='text/css' media='screen'>
        body{background: #f6f6f6; margin: 0; padding: 200px 20px 20px; font: 14px/22px "Helvetica Neue", sans-serif; text-align: center; -webkit-font-smoothing: antialiased;}
        a {text-decoration: none; color: inherit;}
        h1 img {width: 290px; height: auto; border: none;}
        h1, h2 {font: inherit; margin: 0; opacity: 0.3}
        a:hover h1, a:hover h2 {opacity: 0.45;}
      </style>
    </head>
    <body>
      <a href='http://www.holderdeord.no'>
        <h1>
          <img alt='Holder de ord - Bringer politikken til folket' src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAhsAAAAuAgMAAAD8YTMZAAAADFBMVEUAAAAAAAAAAAAAAAA16TeWAAAABHRSTlMA/qVIp765TgAABIJJREFUeF7N2D1u7DYQB3B9YIstZFd7BDXpt3CKREfYQn9KsAVEtd8rdARdQkcwkBgBsjeILrFHcJPKbR6C56xGYw6p4VqB7SIsd6nRjx8ih4z+p+UnmKMP+PnlXEIAXW18A/A3zPMMuD7XfFYANATYlcRIABgKt0U/O3LY3yLMpY9iALh133sCgC/OI0DrMLYAKifgF4n3u3JwnUY7cBdwoF468PWSY2CYVR4l3lE5UnDjlQNdwIFx6cAYdmQEqxxHLQ6jHFv7TuWoQ45OORrtcGS9OIw40LkODnb/QFblwBhwNMphwg4Ajw8kE5M46oUjpXnwBOM5qpeX7wOjbx+nMp4dRXT9hNJxnKv9xeFzQ9Xkw4unmZMOKOeAUXQ12Hi/Ed5zxNTqhKyOg4TkxcEGLqaKleOYGnUFtPyIVzZUM4OxAfdoX+PdEN51bFATGK3voOcq5YhOZuGInlArB0ekj6Z/dcTSrnRA6ztydPNsbZQjgdGOHEvHFlXIMWCcG9NJB7ODfm58x2munqL0HRxKOTYYF44UCDhSHsAMB6scauvIUPoOVMw32pGjWHMQB712JGjYU4ccKYzroL7id2rHFq1yWKs49ii0I0PHDazEUZKD8Z4jRsvTG71yxDisOJjbKYd4d8Y6To4jR+86MhTsR6EcCRo9LtoRo1UOGb899LhQnEIcDjtGpxwR6rX5wVztyI3tmFE5eNzEIewErXYMpXJQ83xHqh2OK0Ovv1vqRNexf2WnIcepUo6d8R3cTuXYlcJnR4KDOJKgg5zasVOOFFXAUVqHMkaJncU3dl1nFOY9yX980A5qPH6ZksR/2HGDWjtOk8O8TEUczdJxPaBnBw8SuEyO0joa5aDJZqvGuH8cgDbgqOzOHkk4O+Cd/XcUR3TJcVp3UOm1Y/e2o2UHqugTHdH7Hc1nOrr3O4xy8DzV82PdcQg43js/yvnx1e8l97+XuylZrC/M0+rN7wV/vnwDOs/x3vVjCnOFKuB4e/0oeJXP0Xrf7YfW08FcWMfW19MMjbeOfWh/yaEdqP/j/lK7jvZD++2e4Kv7nHT0Zm2/Xc8/0vX8g7t4Lf/Q+dgWxYV8bAznY+uODO1aPqYde/SfnZ9uwvlpK/lpIC/cYfTz9VKqB/P1dUe+nq9rx2CW5xepHjy/rDsGCF2KnF9CjgSV78gxUvVL57l1RxY+z50w2mReO7aoFw7Dfdspxx5lyFEsHPmb59vYdVTWcVqeb3ckTcPn/cOKgy8uWuUgMEduA45MnfeHem66sX3Ig5U+gF6JOuzguOkT+P5j4UiAI2+8vqOmFNG//+Dt9BvfB813Ln2Uu5dYfMHCjsx14Jw82Pug+6narwIZYP44xx5k1HYVx9P3QQng3o9RKUL3Y61yBO/HSnU/hsp3hO/HYkjTleMYdHRLRx92XNnQ1mGsw4y+g1+NrwHHXRRwxMpB1ZRDmLLP0RyS9/n7PvO0w4xhRysOqSYO3SG9dYAdHFsc/Lg5Rp7jh2nKPUchR4KD57g9qitXW37kqSAL0jg77onxL1YFWov3xdyXAAAAAElFTkSuQmCC">
        </h1>
        <h2>tekniske problemer - straks tilbake</h2>
      </a>
    </body>
  </html>
  "};

  return(deliver);
}
