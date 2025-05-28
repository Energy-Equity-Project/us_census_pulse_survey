import os
import requests
import pandas
from bs4 import BeautifulSoup

# Output directory
outdir = "../../Data/Pulse_Survey/Data_tables"

# US Census Pulse Survey base url + "{year}/{wk/cycle}{release_idx}/housing4_{week/cycle}{release_idx}.xlsx" 
PULSE_URL = "https://www2.census.gov/programs-surveys/demo/tables/hhp/"

# Pulse survey release info: type of release (week or cycle), start idx, end idx
pulse_survey_releases = {
   2021: ["wk", 34, 41],
   2022: ["wk", 42, 51],
   2023: ["wk", 52, 63],
   2024: ["cycle", 1, 9]
}

# Iterate through all Pulse Survey releases and download
for year, release_data in pulse_survey_releases.items():

   # Create a directory for a given year when necessary
   outdir_year = os.path.join(outdir, str(year))
   if not os.path.isdir(outdir_year):
      os.mkdir(outdir_year)

   # Release data type
   short_release_type = release_data[0]
   long_release_type = "week" if short_release_type == "wk" else short_release_type

   # Iterate for all releases for a given year
   for release_idx in range(release_data[1], release_data[2] + 1):
      
      # Get release index as a string with "0" padding when less than 10, ie "09"
      curr_idx = str(release_idx) if release_idx >= 10 else "0" + str(release_idx)
      
      # Building pulse survey url for current release
      curr_url = f"{PULSE_URL}{year}/{short_release_type}{curr_idx}/housing4_{long_release_type}{curr_idx}.xlsx"

      # Request Pulse survey file
      resp = requests.get(curr_url)
      if (resp.status_code == 200):
         # Create a filename
         out_filename = f"pulse_survey_{long_release_type}_{curr_idx}.xlsx"
         # Create file path
         out_fp = os.path.join(outdir_year, out_filename)
         
         # Write pulse survey release file
         with open(out_fp, "wb") as f:
            f.write(resp.content)
         
         print(f"Downloaded...{out_filename}")
      else:
         # There was an issue with downloading the pulse survey - review needed
         print(f"Request status code {resp.status_code} - please review: {curr_url}")

