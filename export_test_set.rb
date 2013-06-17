#include for rally json library gem
require 'rally_api'
require 'csv'

#Setting custom headers
$headers = RallyAPI::CustomHttpHeader.new()
$headers.name = "Ruby Test Set Export Script"
$headers.vendor = "Rally Labs"
$headers.version = "0.10"

# constants
$my_base_url            = "https://rally1.rallydev.com/slm"
$my_username            = "user@company.com"
$my_password            = "password"

$my_workspace           = "My Workspace"
$my_project             = "My Project"

$my_headers             = $headers
$my_page_size           = 200
$my_limit               = 50000
$my_delim               = ","
$wsapi_version          = "1.43"

# Test Set Info
$my_test_set_formatted_id = "TS4"

# output
$my_output_file         = "testset.txt"
$test_case_fields       =  %w{FormattedID Name Description Type Method Priority Owner LastBuild LastVerdict TestFolder LastUpdateDate CreationDate}

if $my_delim == nil then $my_delim = "," end

begin

  # Load (and maybe override with) my personal/private variables from a file...
  my_vars= File.dirname(__FILE__) + "/my_vars.rb"
  if FileTest.exist?( my_vars ) then require my_vars end

  #==================== Making a connection to Rally ====================
  config                  = {:base_url => $my_base_url}
  config[:username]       = $my_username
  config[:password]       = $my_password
  config[:version]        = $wsapi_version
  config[:headers]        = $my_headers #from RallyAPI::CustomHttpHeader.new()

  puts "Connecting to Rally."
  @rally = RallyAPI::RallyRestJson.new(config)

  #==================== Querying Rally ==========================

  puts "Querying Rally for Test Set."
  test_set_fetch = "FormattedID,Name,TestCases,Name,FormattedID"

  test_set_query = RallyAPI::RallyQuery.new()
  test_set_query.type = :testset
  test_set_query.fetch = test_set_fetch
  test_set_query.page_size = 200 #optional - default is 200
  test_set_query.limit = 100000 #optional - default is 99999
  test_set_query.order = "FormattedID Asc"
  test_set_query.query_string = "(FormattedID = \"#{$my_test_set_formatted_id}\")"

  test_set_query_result = @rally.find(test_set_query)
  
  if test_set_query_result.total_result_count == 0 then
    puts "Test Set #{$my_test_set_formatted_id} not found. Exiting."
    exit
  end  
  
  test_set = test_set_query_result.first
  puts "Fount Test Set: #{$my_test_set_formatted_id}. Looking for Test Cases."
  
  test_cases = test_set["TestCases"]
  
  if test_cases.nil? then
    puts "Test Set #{$my_test_set_formatted_id} has no Test Cases. Exiting."
    exit
  end
    
  # Output CSV header
  test_set_csv = CSV.open($my_output_file, "w", {:col_sep => $my_delim})
  test_set_csv << $test_case_fields

  # Loop through test cases and output them

  puts "Exporting test cases to file: #{$my_output_file}."
  puts "Total Test Cases to Export: #{test_cases.length}"

  exported_count = 0

  test_cases.each do | this_test_case |
    
    # Populate all fields on the TestCase
    this_test_case.read
    
    data = []
    data << this_test_case["FormattedID"]
    data << this_test_case["Name"]
    data << this_test_case["Description"]
    data << this_test_case["Type"]
    data << this_test_case["Method"]
    data << this_test_case["Priority"]
    owner = this_test_case["Owner"]
    if owner == nil then
      owner_user_name = nil
    else
      owner.read
      owner_user_name = owner["UserName"]
    end
    data << owner_user_name
    
    last_build = this_test_case["LastBuild"]
    if last_build == nil then
      last_build = "N/A"
    end
    data << last_build
    
    last_verdict = this_test_case["LastVerdit"]
    if last_verdict == nil then
      last_verdict = "N/A"
    end
    data << last_verdict
    data << this_test_case["TestFolder"]
    data << this_test_case["LastUpdateDate"]
    data << this_test_case["CreationDate"]
    
    test_set_csv << CSV::Row.new($test_case_fields, data)
    
    exported_count += 1
    puts "Test Case #{this_test_case["FormattedID"]}: #{exported_count} of #{test_cases.length} exported."
  end
  
  puts "Done! Test Cases for Test Set: #{$my_test_set_formatted_id} written to: #{$my_output_file}."

end