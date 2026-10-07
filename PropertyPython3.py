"""
Property returns detailed property and parcel data (ownership, deed, tax, sale,
building and lot characteristics, estimated value) for a US property identified by its
county FIPS code and Assessor's Parcel Number (APN).

High-level flow of this sample:
  1. ARGS    - main reads any --flag values off the command line with argparse.
  2. INPUT   - call_api fills in whatever wasn't supplied via interactive prompts.
  3. REQUEST - call_api builds the REST query string (license + input fields).
  4. CALL    - get_contents issues the GET request and pretty-prints the JSON response.

This sample is a thin HTTP client: it builds a query string, sends a GET request to
the Property Cloud API, and prints the JSON response.

Reference:
  - Documentation: https://docs.melissa.com/cloud-api/property/property-index.html
  - Release notes: https://releasenotes.melissa.com/cloud-api/property/
  - Result codes:  https://docs.melissa.com/melissa/result-codes/result-codes-index.html
"""

import json
import requests
import argparse
import urllib.parse

def main():
  """
  Entry point. Reads the optional command-line arguments, then hands control to
  call_api, which performs the actual request/response cycle.

  Recognized flags (each followed by its value, e.g. --fips "06059"):
  --license/-l, --fips, --apn.
  Any flag not supplied is None, and call_api prompts for it interactively.
  """
  base_service_url = "https://property.melissadata.net/"
  service_endpoint = "v4/WEB/LookupProperty/"; #please see https://www.melissa.com/developer/property-data for more endpoints

  # Create an ArgumentParser object
  parser = argparse.ArgumentParser(description='Property command line arguments parser')

  # Define the command line arguments
  parser.add_argument('--license', '-l', type=str, help='License key')
  parser.add_argument('--fips', type=str, help='FIPS Code')
  parser.add_argument('--apn', type=str, help='APN Code')

  # Parse the command line arguments
  args = parser.parse_args()

  # Access the values of the command line arguments
  license = args.license
  fips = args.fips
  apn = args.apn

  # Run the lookup with whatever values were passed on the command line.
  call_api(base_service_url, service_endpoint, license, fips, apn)

def get_contents(base_service_url, request_query):
    """
    Issues the GET request against the Property endpoint and pretty-prints the API
    call and the JSON response to the console.

    Args:
        base_service_url: The Property Cloud API base URL.
        request_query: The endpoint path plus query string built by call_api.
    """
    url = urllib.parse.urljoin(base_service_url, request_query)
    response = requests.get(url)

    # Re-serialize with indentation so the raw response is easier to read.
    obj = json.loads(response.text)
    pretty_response = json.dumps(obj, indent=4)

    print("\n=================================== OUTPUT ===================================\n")

    print("API Call: ")
    for i in range(0, len(url), 70):
        if i + 70 < len(url):
            print(url[i:i+70])
        else:
            print(url[i:len(url)])
    print("\nAPI Response:")
    print(pretty_response)

def call_api(base_service_url, service_endpoint, license, fips, apn):
    """
    Drives the interactive/CLI loop: gathers the required lookup fields, builds and
    submits the REST query, prints the result, and optionally repeats for another record.

    It runs a single pass and exits only when both the FIPS code and the APN were
    supplied on the command line. Otherwise it loops, asking for a new record each pass
    until the user answers "N".

    Args:
        base_service_url: The Property Cloud API base URL.
        service_endpoint: The specific Property endpoint path to call.
        license: The Melissa license string sent with every request.
        fips: A county FIPS code to test, or None to prompt for it.
        apn: An Assessor's Parcel Number to test, or None to prompt for it.
    """
    print("\n================== WELCOME TO MELISSA PROPERTY CLOUD API ======================\n")

    should_continue_running = True
    while should_continue_running:
        input_fips = ""
        input_apn = ""

        # Neither value was supplied via command line, so prompt for every field.
        if not fips and not apn:
            print("\nFill in each value to see results")
            input_fips = input("FIPS: ")
            input_apn = input("APN: ")
        else:
            # At least one field was supplied via command line; use those values as-is.
            input_fips = fips
            input_apn = apn

        # Prompt individually for any still-missing required field.
        while not input_fips or not input_apn:
            print("\nFill in each value to see results")
            if not input_fips:
                input_fips = input("\nFIPS: ")
            if not input_apn:
                input_apn = input("\nAPN: ")

        # Map input fields to the API's expected query parameter names and
        # request a JSON response.
        inputs = {
            "format": "json",
            "fips": input_fips,
            "apn": input_apn
        }

        print("\n=================================== INPUTS ===================================\n")
        print(f"\t   Base Service Url: {base_service_url}")
        print(f"\t  Service End Point: {service_endpoint}")
        print(f"\t               FIPS: {input_fips}")
        print(f"\t                APN: {input_apn}")

       # Create Service Call
        # Set the License String in the Request
        rest_request = f"&id={urllib.parse.quote_plus(license)}"

        # Set the Input Parameters
        for k, v in inputs.items():
            rest_request += f"&{k}={urllib.parse.quote_plus(v)}"

        # Build the final REST String Query
        rest_request = service_endpoint + f"?{rest_request}"

        # Submit to the Web Service.
        success = False
        retry_counter = 0

        while not success and retry_counter < 5:
            try: #retry just in case of network failure
                get_contents(base_service_url, rest_request)
                print()
                success = True
            except Exception as ex:
                retry_counter += 1
                print(ex)
                return

        is_valid = False;

        # If both lookup fields came from the command line, treat this as a one-shot
        # run rather than looping for additional records.
        if (fips is not None) and (apn is not None):
            concat = fips + apn
        else:
            concat = None

        if concat is not None and concat != "":
            is_valid = True
            should_continue_running = False

        # Otherwise ask whether to test another record. Keep prompting until we get a
        # valid Y/N. "N" ends the program; "Y" falls through to another pass.
        while not is_valid:
            test_another_response = input("\nTest another record? (Y/N)")
            if test_another_response != '':
                test_another_response = test_another_response.lower()
                if test_another_response == 'y':
                    is_valid = True
                elif test_another_response == 'n':
                    is_valid = True
                    should_continue_running = False
                else:
                    print("Invalid Response, please respond 'Y' or 'N'")

    print("\n=================== THANK YOU FOR USING MELISSA CLOUD API ===================\n")

main()
