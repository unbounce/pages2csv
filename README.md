# pages2csv.rb

A simple Ruby script that illustrates using the Unbounce API to fetch
landing page data for one of your subaccounts and export it to a CSV file.

You'll need an Unbounce API key and the ID of the subaccount
holding your pages.

[Unbounce API Access](https://api.unbounce.com/doc/requesting_access)

## Simple Usage

Via the command line:

    ruby pages2csv.rb -k [your Unbounce API key] -s [your subaccount id]

ie:

    ruby pages2csv.rb -k 07b491ee5a6147d92b143345a48b848f -s 47742

The output will be a file similar to:

    2013-05-14-47742-page-export.csv

Columns in the CSV file are:

    id          - the unique id of the page
    name        - the name of the page
    url         - the link to the page
    visitors    - the number of unique visitors to the page
    conversions - the number of conversions from the page

Note that the script supports other command line arguments. Type:

    ruby pages2csv.rb -h

to view other options.


# api_key_check.rb

A utility useful for checking whether or not an API key is working.
Returns the number of pages in a given sub-account if the key is good.

## Usage

    ruby api_key_check.rb -k [the Unbounce API key] -s [the subaccount id]

