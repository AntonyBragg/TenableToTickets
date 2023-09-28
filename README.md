# [TenableToTickets](https://github.com/Gen2Training/TenableToTickets)
Creates Helpdesk tickets from a Tenable Export

## Links
* [GitHub - Code](https://github.com/Gen2Training/TenableToTickets)
* [GitHub - Issues](https://github.com/Gen2Training/TenableToTickets/issues)

## Requirements
* PowerShell 7

## Description
Using a Tenable JSON export this script will create tickets with all of the information from the export as well as attempting to get 
the owner of the device.

## Script Execution - Manual
Set the dashboard to "asset", tick the devices you would like to raise tickets for, click export, set the format to JSON, drop down configuration and ensure the at least 
the following are selected:
* Asset Name
* Plugin Description
* Plugin Name
* Plugin Output
* Severity
* Solution

Click Export.

Put the exported JSON in to the "Files" folder along side the script.  The script can now be executed.  Please delete the JSON file when complete.

## Authors
* [Antony Bragg](https://github.com/captainqwerty)

## Version History
* 1.0.0
    * Initial rewrite and release