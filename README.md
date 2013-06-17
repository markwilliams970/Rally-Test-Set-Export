Rally-Test-Set-Export
=====================

Requires:
Ruby 1.9.3 or higher
rally_api 0.9.5 or higher

Configuring and Using the Export Test Set script
Create directory for script and associated files:

<pre>
C:\Users\username\Documents\Rally Export Test Set\
</pre>
Download the export_test_set.rb script and the my_vars.rb file to the above directory

Using a text editor, customize the code parameters in the my_vars.rb file for your environment.
<pre>
my_vars.rb:

# Connection Parameters
$my_base_url              = "https://rally1.rallydev.com/slm"
$my_username              = "user@company.com"
$my_password              = "topsecret"
$my_page_size             = 200
$my_limit                 = 50000
$my_delim                 = "\t"
$wsapi_version            = "1.43"

# Workspace/project info
$my_workspace             = "My Workspace"
$my_project               = "My Project"

# Test Set Info
$my_test_set_formatted_id = "TS7"

# output
$my_output_file           = "testset.txt"

Run the script.

C:\> ruby export_test_set.rb
Connecting to Rally.
Querying Rally for Test Set.
Fount Test Set: TS7. Looking for Test Cases.
Exporting test cases to file: testset.txt.
Total Test Cases to Export: 4
Test Case TC2: 1 of 4 exported.
Test Case TC3: 2 of 4 exported.
Test Case TC4: 3 of 4 exported.
Test Case TC5: 4 of 4 exported.
Done! Test Cases for Test Set: TS7 written to: testset.txt.

</pre>