/*
  Create highchart plot from dataset
  Ben Southgate
  08/20/14
*/



capture program drop injectFile
program define injectFile
  /*
    Read a file (`1') and write it line by line
    to another file (`2'). Both files should be 
    passed as file object handles.
  */
  file read `1' line
  while r(eof) == 0 {
    if ("`3'" == "1") {
      file write `2' `"`macval(line)'"' "\n" 
    }
    else {
      file write `2' `"`macval(line)'"' _n //"
    }
    file read `1' line
  }
end

capture program drop stataHC
program define stataHC

  syntax varlist(min=2 numeric) [if] using/ [, ///
      title(string) type(string) xdate(integer 0) ///
      xTitle(string) yTitle(string) by(varname) replace ///
    ]

  // Grab passed variables
  tokenize `varlist'
  local first `1'
  macro shift
  local rest `*'

  // Create list of all secondary variables
  local y_var_string "[" 
  foreach v in `rest' {
    local c ","
    if ("`v'" == "`: word 1 of `rest''") {
      local c ""
    }
    local y_var_string "`y_var_string' `c' '`v''" 
  }
  local y_var_string "`y_var_string']"

  // Create a temporary csv file and write out the current dataset
  tempfile tcsv

  // temporary names for files
  tempname thtml_file
  tempname tcsv_file
  tempname tjs_file

  // The start of the new html file
  local html_top ///
  <html>  ///
    <head>  ///
      <meta http-equiv='Content-Type' content='text/htmlcharset=utf-8' / > ///
      <script src='https://code.jquery.com/jquery-1.11.1.min.js'></script>  ///
      <script src='http://code.highcharts.com/highcharts.js'></script>  ///
    </head> ///
    <body> ///
      <div id='chart'></div> ///
      <script> 

  local outvars `first' `rest' `by'
  outsheet `outvars' using `tcsv' `if', replace comma

  // Local path to ado file
  findfile stataHC.ado
  local thisDir = subinstr("`r(fn)'", "/stata.ado", "", .)
  local script "`thisDir’/stataHC.js"

  // Open all the component files for the chart
  file open `thtml_file' using "`using'", write `replace'
  file open `tjs_file' using "`script'", read
  file open `tcsv_file' using `tcsv', read

  // Write the beginning of the html file
  file write `thtml_file' "`html_top'" _n

  // Inject the javascript
  injectFile `tjs_file' `thtml_file'

  // defaults
  if ("`type'" == "") { 
    local type "scatter" 
  }
  if ("`title'" == "") { 
    local title "Stata Output" 
  }

  // Write user settings
  local hc_options  ///
    var stataHC = { ///
      'title' : '`title'', ///
      'y_variables' : `y_var_string', ///
      'x_var' : '`first'', ///
      'type' : '`type'', ///
      'byvar' : '`by'', ///
      'date' : `xdate', ///
      'xTitle' : '`xTitle'', ///
      'yTitle' : '`yTitle'' ///
    } 

  file write `thtml_file' "`hc_options'" _n

  // Inject the csv string
  file write `thtml_file' "stataHC.data = '"
  injectFile `tcsv_file' `thtml_file' 1
  file write `thtml_file' "';</script></body></html>" 

end

