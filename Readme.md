#stataHC - HighCharts for STATA

## Package Info

`stataHC` is a new command for [Stata](http://www.stata.com/) that allows the automatic generation of [highcharts](http://www.highcharts.com/) 2d plots fully contained in a single html file that can be dragged into any browser.

## Requirements

I've so far (lightly) tested it on Stata versions 11-13. Everything should work under both **OSX** and **Windows**.


## Installation

To install, simply drag `stataHC.do` and `stataHC.js` to your personal `.ado` folder. To determine where this is, run the Stata command `sysdir`.

## Usage syntax

The command syntax is as follows:

    stataHC <varlist> [if <condition>] using <filename> [, <options>]  
    
This creates an html file (with the filename given after `using`, including `.html`) which can be opened in any modern browser.


#### Example Usage

    // Use sample data from Stata
    sysuse auto
    
    // Produce chart and save to 'chart.html' on desktop
    stataHC mpg weight using "~/Desktop/chart.html", title("Example Plot")
    