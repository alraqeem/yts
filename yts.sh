#!/bin/bash
set -x
 runtime(){
  case "$1" in
    start)
      start_time=$(date +%s%3N)
      echo "Start time recorded: $(date)"
      ;;
    end)
      end_time=$(date +%s%3N)
      echo "End time recorded: $(date)"
      ;;
    total)
      echo "Time taken: $((end_time - start_time)) milliseconds"
      ;;
    *)
      echo "Invalid argument. Please use either 'start', 'end', or 'total'."
      ;;
  esac
}


runtime start
unset_variables(){

unset base_url current_is_movie_downloaded current_time file_name formatted_movie_name imdb_id imdb_rating imdb_votes is_movie_downloaded is_torrent_downloaded movie_actor movie_data_exists movie_director movie_folder_name movie_genres movie_language movie_name movie_rating movie_release_date movie_torrent_or_folder movie_writer movie_year name output_movie_folder_formatted_name omdb_data movie_torrent_or_folder_name_without_path status_code torrent_download_link torrent_file output_movie_folder_formatted_name url year yts_movie_page_source_code yts_movie_url yts_torrent_download_url 
}

 initialize_variables(){
   
    IFS=$'\n'
    usr=$(hostname)
    default_input_path="/media/$usr/Data/torrents/test_input/"
    default_output_path="/media/$usr/Data/torrents/test_output/"
skip_existing="1" 
if [ "${default_input_path: -1}" == "/" ]; then
default_input_path="${default_input_path%/}"
fi

if [ "${default_output_path: -1}" == "/" ]; then
default_output_path="${default_output_path%/}"
fi

    input_path=${input_path:-$default_input_path}
    output_path=${output_path:-$default_output_path}
    default_imdb_lower_limit="3.0"
    default_imdb_upper_limit="9.9"
    nil_imdb_rating="0.0"
    imdb_lower_limit="$default_imdb_lower_limit"
    imdb_upper_limit="$default_imdb_upper_limit"
    unwanted_genres="Documentary, News, Musical, Music, Game-Show, Reality-Tv, Sports, Talk-Show, Adult"
    error_log_path="$input_path/error.log"
    csv_database_path="$input_path/csv_database.csv"
    movie_website="https://yts.mx/movies/"
    csv_database_temp_path="$input_path/temp_csv_database.csv"
    OMDB_API_KEYS=(3cb921e6 99e89513 f487ea39 4220a547) # List of OMDB API keys to use
    CURRENT_OMDB_API_KEY_INDEX=0 # Index of the current OMDB API key being used


    omdbapikey="apikey=7143309d"

    if [ ! -d "$input_path" ] && [ -n "$input_path" ]; then
        handle_error "Line:$LINENO Error: Input path directory does not exist: $input_path" >&2
        exit 1
    fi
    if [ ! -d "$output_path" ] && [ -n "$output_path" ]; then
        handle_error "Line:$LINENO Error: Output path directory does not exist: $output_path" >&2
        exit 1
    fi
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
}

get_yts_movie_page_source_code(){
  yts_movie_page_source_code=$(curl -s "${yts_movie_url}")
}

get_yts_movie_page_urls() {
page=$1
yts_url="https://yts.mx/browse-movies?page=$page"
yts_movie_page_urls=$(curl -s "$yts_url" | grep -oP '(?<=<a href=")[^"]+(?=" class="browse-movie-link">)')
}




sort_csv_file() {
  if [[ -f "$csv_database_path" ]]; then
    # Check if there are any existing copy files
    copy_count=1
    while [[ -f "${csv_database_path%.*} (copy $copy_count).csv" ]]; do
      # Merge the copy file with the main file
      sort -u -t, -k1 "${csv_database_path%.*} (copy $copy_count).csv" >> "$csv_database_path"
      rm "${csv_database_path%.*} (copy $copy_count).csv"
      ((copy_count++))
    done
  else
    touch "$csv_database_path"
  fi

  if [[ ! -w "$csv_database_path" ]]; then
    handle_error "Line:$LINENO Error: No permission to write to the file $csv_database_path"
    return 1
  fi

  if [[ -f "$csv_database_temp_path" ]]; then
    rm "$csv_database_temp_path"
  fi

  database_size=$(stat -c%s "$csv_database_path")
  if [[ "$database_size" -gt 100000000 ]]; then
    handle_error "Line:$LINENO Error: Database size exceeded limit of 100MB"
    return 1
  fi

  echo "Database Management Starts"
  sort -u -t, -k1 "$csv_database_path" > "$csv_database_temp_path"
  if [[ $? -ne 0 ]]; then
    handle_error "Line:$LINENO Error: Sort command failed"
    return 1
  fi
  mv "$csv_database_temp_path" "$csv_database_path"
  echo "Database Management Completed"
}

is_movie_data_exists(){
movie_data_exists=$(grep -E "^$imdb_id" "$csv_database_path")
}



handle_movie_data() {
  if [ -z "$imdb_id" ]; then
    handle_error "Line:$LINENO Error: imdb_id is required for $movie_name."
    return 1
  fi


  if [ -z "$movie_name" ]; then
    handle_error "Line:$LINENO Error: movie title is required."
    return 1
  fi


  if [ -z "$movie_year" ]; then
    handle_error "Line:$LINENO Error: movie year is required."
    return 1
  fi


  if [ -z "$imdb_rating" ]; then
    handle_error "Line:$LINENO Error: imdb_rating is required."
    return 1
  fi


  if [ -z "$movie_genres" ]; then
    handle_error "Line:$LINENO Error: movie genre is required."
    return 1
  fi


  if [ -z "$imdb_votes" ]; then
    handle_error "Line:$LINENO Error: imdb votes data is required."
    return 1
  fi
    if [ -z "$movie_release_date" ]; then
    handle_error "Line:$LINENO Error: movie_release_date is required."
    return 1
  fi


  if [ -z "$movie_director" ]; then
    handle_error "Line:$LINENO Error: movie_director is required."
    return 1
  fi


  if [ -z "$movie_language" ]; then
    handle_error "Line:$LINENO Error: movie_language is required."
    return 1
  fi


  if [ -z "$movie_writer" ]; then
    handle_error "Line:$LINENO Error: movie_writer is required."
    return 1
  fi


  if [ -z "$movie_actor" ]; then
    handle_error "Line:$LINENO Error: movie_actor is required."
    return 1
  fi


  if [ -z "$is_torrent_downloaded" ]; then
    handle_error "Line:$LINENO Error: is_torrent_downloaded is required."
    return 1
  fi

  if [ -z "$is_movie_downloaded" ]; then
    handle_error "Line:$LINENO Error: is_movie_downloaded is required."
    return 1
  fi
  if [ -z "$csv_database_path" ]; then
    handle_error "Line:$LINENO Error: csv_database_path is required."
    return 1
  fi

#Validate the input values
if [[ ! "$imdb_id" =~ [0-9]{7} ]]; then
handle_error "Line:$LINENO Error: Invalid IMDB ID $imdb_id for $movie_name"
return
fi
if [[ ! "$movie_year" =~ ^[0-9]+$ ]]; then
handle_error "Line:$LINENO Error: Invalid movie year for $movie_name"
return
fi
if [[ ! "$imdb_rating" =~ ^[0-9]+(.[0-9]+)?$ ]]; then
handle_error "Line:$LINENO Error: Invalid IMDB rating for $movie_name"
return
fi


# Check if the movie data already exists in the CSV file
if [ -n "$(is_movie_data_exists)" ]; then
# Get the current value of is_movie_downloaded from the CSV file
current_is_movie_downloaded=$(echo "$movie_data_exists" | awk -F, '{print $NF}')
# Update the value of is_movie_downloaded only if it's not already present
if [[ -z "$current_is_movie_downloaded" ]]; then
sed -i "s/^$imdb_id,$movie_name,$movie_year.*/$imdb_id,$movie_name,$movie_year,$movie_rating,$movie_genres,$imdb_rating,$imdb_votes,$movie_release_date,$movie_director,$movie_language,$movie_writer,$movie_actor,$movie_poster,$is_torrent_downloaded,$is_movie_downloaded/g" "$csv_database_path"
fi
return
fi
#Add the movie data to the CSV file

echo "$imdb_id,$movie_name,$movie_year,$movie_rating,$movie_genres,$imdb_rating,$imdb_votes,$movie_release_date,$movie_director,$movie_language,$movie_writer,$movie_actor,$movie_poster,$is_torrent_downloaded,$is_movie_downloaded" >> "$csv_database_path"

}

# convert_imdb_votes(){
#  return 0
 
#   if [[ "$imdb_votes" == "N/A" ]]; then
#     return
#   fi

#   if [[ "$imdb_votes" == *k* || "$imdb_votes" == *m* ]]; then
#       echo "Skipping conversion, value is already in k or m format"
#   else
#       if [[ $imdb_votes -ge 1000000 ]]; then
#           imdb_votes=$(printf "%.2fm" "$(echo "scale=4;$imdb_votes/1000000" | bc)")
#       elif [[ $imdb_votes -ge 1000 ]]; then
#           imdb_votes=$(printf "%.2fk" "$(echo "scale=4;$imdb_votes/1000" | bc)")
#       fi
#   fi

# }


get_output_movie_folder_formatted_name(){

# imdb_votes_raw="$imdb_votes"

# # Extract numerical value from imdb_votes_raw
# if [[ $imdb_votes_raw =~ ([0-9,]+)k ]]; then
#     imdb_votes=$(echo "${BASH_REMATCH[1]//,}/1" | bc)
#     if [[ $imdb_votes -lt 99999 ]]; then
#         imdb_votes=$(echo "scale=4;($imdb_votes/100)*100+50" | bc | cut -d'.' -f1)
#     else
#         imdb_votes=$(echo "scale=4;$imdb_votes*1000" | bc)
#     fi
# elif [[ $imdb_votes_raw =~ ([0-9,]+)m ]]; then
#     imdb_votes=$(echo "${BASH_REMATCH[1]//,}/1" | bc)
#     imdb_votes=$(echo "scale=4;$imdb_votes*1000000" | bc)
# elif [[ $imdb_votes_raw =~ ^[0-9,]+$ ]]; then
#     imdb_votes=$(echo "${imdb_votes_raw//,}/1" | bc)
# fi

# # Convert imdb_votes to k or m format if necessary
# if [[ $imdb_votes_raw == "N/A" ]]; then
#     imdb_votes_formatted="N/A"
# elif [[ $imdb_votes -ge 1000000 ]]; then
#     imdb_votes_formatted=$(printf "%.2fm" "$(echo "scale=4;$imdb_votes/1000000" | bc)")
#     if [[ $imdb_votes -ge 1000000 ]]; then
#         output_movie_folder_formatted_name="001Recomended-$imdb_rating-$movie_year-$imdb_votes_formatted-$formatted_movie_name-tt$imdb_id"
#     fi
# elif [[ $imdb_votes -ge 500000 ]]; then
#     imdb_votes_formatted=$(printf "%.2fk" "$(echo "scale=4;$imdb_votes/1000" | bc)")
#     if [[ $imdb_votes -lt 1000000 && $imdb_votes -ge 500000 ]]; then
#         output_movie_folder_formatted_name="002Recomended-$imdb_rating-$movie_year-$imdb_votes_formatted-$formatted_movie_name-tt$imdb_id"
#     fi
# elif [[ $imdb_votes -ge 200000 ]]; then
#     imdb_votes_formatted=$(printf "%.2fk" "$(echo "scale=4;$imdb_votes/1000" | bc)")
#     if [[ $imdb_votes -lt 500000 && $imdb_votes -ge 200000 ]]; then
#         output_movie_folder_formatted_name="003Recomended-$imdb_rating-$movie_year-$imdb_votes_formatted-$formatted_movie_name-tt$imdb_id"
#     fi
# else
#     imdb_votes_formatted=$(printf "%.0f" "$imdb_votes")
#     if [[ $imdb_votes -lt 200000 ]]; then
#         output_movie_folder_formatted_name="$imdb_rating-$movie_year-$imdb_votes_formatted-$formatted_movie_name-tt$imdb_id"
#     fi
# fi

output_movie_folder_formatted_name="$imdb_votes-$imdb_rating-$movie_year-$formatted_movie_name-tt$imdb_id"


}




handle_error() {
error_message=$1
   if [ ! -f "$error_log_path" ]; then
        touch "$error_log_path"
    fi
    current_time=$(date +"%Y-%m-%d %T")
    echo "$current_time: $error_message" >> "$error_log_path"
    echo "$current_time: $error_message"
}


get_omdb_data() {
   unset movie_year  movie_rating  movie_genres imdb_votes  movie_release_date  movie_director movie_language  movie_writer  movie_actor
  if [[ -z "$imdb_id" ]]; then
    handle_error "Line:$LINENO Error: IMDB ID not provided for movie $movie_name-$movie_year"
    return 1
  fi

  while [[ "$CURRENT_OMDB_API_KEY_INDEX" -lt "${#OMDB_API_KEYS[@]}" ]]; do
    omdbapikey="apikey=${OMDB_API_KEYS[$CURRENT_OMDB_API_KEY_INDEX]}"

    for i in {1..3}; do # Retry the curl command for 3 times
      omdb_data=$(timeout 30s curl -s "http://www.omdbapi.com/?i=tt$imdb_id&$omdbapikey")
      if [[ "$?" -eq 0 ]]; then
        break
      fi
      echo "Retrying curl command..."
      sleep 5
    done

    if [[ "$?" -ne 0 ]]; then
      handle_error "Line:$LINENO Error: Failed to access OMDB"
      main
    fi

    if [[ "$omdb_data" == *"Movie not found!"* ]]; then
      handle_error "Line:$LINENO Error: Movie data of IMDb ID $imdb_id movie $movie_name is not found"
      return 1
    fi

    if [[ "$omdb_data" == *"Invalid API key!"* ]]; then
      ((CURRENT_OMDB_API_KEY_INDEX++))
      if [[ "$CURRENT_OMDB_API_KEY_INDEX" -eq "${#OMDB_API_KEYS[@]}" ]]; then
        handle_error "Line:$LINENO Error: API key is invalid for all OMDB keys. Failed to retrieve data for IMDb ID $imdb_id movie $movie_name."
        return 1
      fi
    elif [[ "$omdb_data" == *"Request limit reached!"* ]]; then
      ((CURRENT_OMDB_API_KEY_INDEX++))
    else
      CURRENT_OMDB_API_KEY_INDEX=0
      break
    fi
  done

# Extract movie details
mapfile -t movie_name < <(echo "$omdb_data" | grep -oP '"Title":"\K[^"]+')
mapfile -t movie_year < <(echo "$omdb_data" | grep -oP '"Year":"\K[^"]+')
mapfile -t movie_rating < <(echo "$omdb_data" | grep -oP '"Rated":"\K[^"]+')
mapfile -t movie_genres < <(echo "$omdb_data" | grep -oP '"Genre":"\K[^"]+' | tr ',' '\n')
imdb_rating=$(echo "$omdb_data" | grep -oP '"imdbRating":"\K[^"]+')
if [[ "$imdb_rating" == "N/A" ]]; then
  imdb_rating="$nil_imdb_rating"
fi
mapfile -t imdb_votes < <(echo "$omdb_data" | grep -oP '"imdbVotes":"\K[^"]+' | tr -d ',')
mapfile -t poster < <(echo "$omdb_data" | grep -oP '"Poster":"\K[^"]+' | tr -d ',')
mapfile -t movie_release_date < <(echo "$omdb_data" | grep -oP '"Released":"\K[^"]+')
mapfile -t movie_director < <(echo "$omdb_data" | grep -oP '"Director":"\K[^"]+')
mapfile -t movie_language < <(echo "$omdb_data" | grep -oP '"Language":"\K[^"]+')
mapfile -t movie_writer < <(echo "$omdb_data" | grep -oP '"Writer":"\K[^"]+')
mapfile -t movie_actor < <(echo "$omdb_data" | grep -oP '"Actors":"\K[^"]+')
movie_plot=$(echo "$omdb_data" | grep -oP '"Plot":"\K[^"]+' | sed 's/\\"/"/g')
movie_country=$(echo "$omdb_data" | grep -oP '"Country":"\K[^"]+')
movie_poster=$(echo "$omdb_data" | grep -oP '"Poster":"\K[^"]+')
movie_awards=$(echo "$omdb_data" | grep -oP '"Awards":"\K[^"]+')
dvd_release=$(echo "$omdb_data" | grep -oP '"DVD":"\K[^"]+')
box_office=$(echo "$omdb_data" | grep -oP '"BoxOffice":"\K[^"]+')
movie_production=$(echo "$omdb_data" | grep -oP '"Production":"\K[^"]+')
website=$(echo "$omdb_data" | grep -oP '"Website":"\K[^"]+')

unformatted_movie_name=$movie_name-$movie_year
echo $movie_name-$movie_year
}


format_unformatted_movie_name() {

if ! [[ $unformatted_movie_name =~ [0-9]{4} ]]; then
  # 4-digit year not detected
  return
else
  year=$(echo "$unformatted_movie_name" | grep -o -E '[0-9]{4}')
  if [[ $year == 1080 || $year == 2160 ]]; then
    # Detected year is either 1080 or 2160
    return
  fi
fi

    unformatted_movie_name=`echo "$unformatted_movie_name" | sed -e 's/\(extended\|director['"'"'s]\?\) cut//Ig'`
    # Remove everything after the last ")" including the ")"
    unformatted_movie_name="${unformatted_movie_name%%)*}"
    # Convert first "(" to "-"
    unformatted_movie_name=`echo "$unformatted_movie_name" | sed -e 's/(/-/'`
    # Convert name to lowercase
    unformatted_movie_name="${unformatted_movie_name,,}"
     # Remove single quotes
    unformatted_movie_name="${unformatted_movie_name//[\'\`\,\:]/}"
    # Replace spaces, dots with dashes
    unformatted_movie_name="${unformatted_movie_name//[ .]/-}"
        # Replace double -- with single -
    unformatted_movie_name=`echo "$unformatted_movie_name" | tr --squeeze-repeats '-'`  
     # Remove all special characters including dots and backticks
    unformatted_movie_name="$(echo "$unformatted_movie_name" | tr -dc '[:alnum:]-')"
    # Convert non-ASCII characters to ASCII
    formatted_movie_name="$(echo "$unformatted_movie_name" | iconv -f utf-8 -t ascii//TRANSLIT)" 
}

is_movie_suitable() {
  if [ -z "$imdb_rating" ] || [ -z "$imdb_lower_limit" ] || [ -z "$imdb_upper_limit" ] || [ -z "$nil_imdb_rating" ]; then
    handle_error "Error: $LINENO ${FUNCNAME[0]} IMDB rating or rating limits are not available for $movie_name"
    movie_suitability="2"
    return
  fi

  if [ "$imdb_rating" == "$nil_imdb_rating" ] || \
    ( ! [ -z "$imdb_rating" ] && (( $(echo "$imdb_rating >= $imdb_lower_limit" | bc -l) )) && (( $(echo "$imdb_rating <= $imdb_upper_limit" | bc -l) )) ); then
    if echo "${movie_genres[@]}" | grep -qw "${unwanted_genres[@]}"; then
      handle_error "Error:$LINENO ${FUNCNAME[0]} $movie_name has unwanted genres: ${unwanted_genres[@]}"
      movie_suitability="1"
    else
      movie_suitability="0"
    fi
  else
    handle_error "Error:$LINENO ${FUNCNAME[0]} $movie_name has IMDB rating out of range: $imdb_rating"
    movie_suitability="2"
  fi
}



get_yts_url(){
  # Create torrent download omdb_data URL
  yts_movie_url="$movie_website$formatted_movie_name"
  # Check if the URL returns a status code of 200, indicating a successful omdb_data load
  status_code=$(curl -s -o /dev/null -w "%{http_code}" "$yts_movie_url")
  if [ "$status_code" -eq "200" ]; then
  echo "------------URL Found $yts_movie_url"

  else
    # If not successful, call the handle_error function and pass in the error message
    handle_error "Line:$LINENO Error: Unable to find movie $imdb_id $movie_name on YTS"
  fi
}

get_imdb_id() {
  unset imdb_id

# Check internet connectivity and access to yts.mx
yts_base_url=$(echo "$yts_movie_url" | sed 's/^\(https:\/\/[^/]*\/\).*/\1/')
WAIT_TIME=60 # in seconds
while ! curl -s --head --fail "$yts_base_url" >/dev/null; do
if [ $SECONDS -ge $WAIT_TIME ]; then
handle_error "Error: $LINENO Unable to access internet or yts.mx after $WAIT_TIME seconds"
main # Call main function to exit the script
fi
sleep 5
done
# Get IMDb ID

imdb_id=$(curl -s "$yts_movie_url" | grep -o 'href="https://www.imdb.com/title/tt[0-9]\+/"' |grep -o '[0-9]\+' )
# Check if IMDb ID is found


if [ -z "$imdb_id" ]; then
imdb_id="$(echo "$yts_movie_url" | sed 's/[0-9]*$//' | sed 's/-*$//' |  sed 's:.*/::' | sed 's/-/ /g')"
fi
}

parse_torrent_file() {
#pasre torrent file and get downloadable movie url of movie from yts.mx

unformatted_movie_name=$( cat "$movie_torrent_or_folder" | grep -a announce | sed 's/name/\n/' | cut -d ':' -f2  | tr '[:upper:]' '[:lower:]' | cut -d ')' -f1  | sed 's/\./ /g' | sed 's/\!/ /g'  | sed 's/&/ /g' | sed 's/ /-/g' | sed 's/(//g' | sed 's/)//g' |  sed 's/,//g' |  sed "s/'//g"  |  sed 's/;//g'|  sed 's/--/-/g' | sed 's/-special//g'  | sed 's/-edition//g'  | sed 's/-extended//g'  | sed 's/-uncut//g' | sed 's/-cut//g' | sed 's/-hdrip//g' | sed 's/-remastered//g' | sed 's/-directors//g'  | sed 's/-xvid//g' | grep -v announce  | grep -v length | tr '[:upper:]' '[:lower:]' | sed "s/\.//g" | sed 's/--/-/g'  | sed 's/://g' | sed 's/\.$//' )
namectr=0
while [[ -z $unformatted_movie_name && $namectr -ne 100 ]]
do
    let namectr=namectr+1
    #echo "$namectr $( echo $torrentfile | cut -d '/' -f7) "
    unformatted_movie_name=$( cat "$unformatted_movie_name" |  grep -a name | sed "s/name$namectr/\n/g" | cut -d ':' -f2  | tr '[:upper:]' '[:lower:]' | cut -d ')' -f1  | sed 's/\./ /g' | sed 's/ /-/g' | sed 's/(//g' | sed 's/)//g' |  sed 's/,//g' |  sed "s/'//g" |  sed 's/;//g'|  sed 's/--/-/g' | sed 's/-special//g'  | sed 's/-edition//g'  | sed 's/-extended//g'  | sed 's/-uncut//g' | sed 's/-cut//g' | sed 's/-hdrip//g' | sed 's/-remastered//g' | sed 's/-directors//g'  | sed 's/-xvid//g' | grep -v announce | grep -v length | grep -v creation | tr '[:upper:]' '[:lower:]' | sed "s/\.//g" | sed 's/--/-/g'  | sed 's/://g' | sed 's/\.$//' )
    if [ -z $unformatted_movie_name ]; then
    unformatted_movie_name=$( cat "$unformatted_movie_name" |  grep -a announce | sed "s/name$namectr/\n/g" | cut -d ':' -f2  | tr '[:upper:]' '[:lower:]' | cut -d ')' -f1  | sed 's/\./ /g' | sed 's/ /-/g' | sed 's/(//g' | sed 's/)//g' |  sed 's/,//g' |  sed "s/'//g"  |  sed 's/;//g'|  sed 's/--/-/g' | sed 's/-special//g'  | sed 's/-edition//g'  | sed 's/-extended//g'  | sed 's/-uncut//g' | sed 's/-cut//g' | sed 's/-hdrip//g' | sed 's/-remastered//g' | sed 's/-directors//g'  | sed 's/-xvid//g' | grep -v announce | grep -v length | grep -v creation | tr '[:upper:]' '[:lower:]' | sed "s/\.//g" | sed 's/--/-/g'  | sed 's/://g' | sed 's/\.$//' )
fi
done
}

get_yts_torrent_download_url(){
#convert all to lowercase
yts_torrent_resolutions=("720P.BLURAY" "720P.WEB" "1080P.BLURAY" "1080P.WEB" "2160P.BLURAY" "480P.BLURAY" "2160P.WEB" "480P.WEB")

# Use grep to find all the URLs that start with "https://yts.mx/torrent/download/"
# and save them in an array called "urls"
urls=("$(echo "$yts_movie_page_source_code" | grep  -v "</span>Download</a>" | grep "</span>" | grep -o -i "https://yts.mx/torrent/download/*[^']*")")
# Loop over the "urls" array and print the ones that match a resolution in "$yts_torrent_resolutions"
for url in "${urls[@]}"; do
  # Extract the resolution from the URL and convert it to lowercase
  #get resolution. it is giving complete url
  resolution=$(echo "$url" | sed -E 's/.*\/([0-9]+p\.[A-Z]+).*/\1/' | tr '[:lower:]' '[:upper:]')

  # Check if the resolution matches any in "$yts_torrent_resolutions" (case-insensitive)
  for resolution in "${yts_torrent_resolutions[@]}"
do
    match=$(echo "$urls" | grep -i "$resolution")
    if [ -n "$match" ]
    then
        yts_torrent_download_url=$(echo "$match" | grep -o -i 'https://yts\.mx/torrent/download/[^"]*')
        break
    fi
done
done
}

download_torrent() {
  if [[ "$movie_torrent_or_folder" == *"/"* ]]; then
    movie_torrent_or_folder_name_without_path=${movie_torrent_or_folder##*/}
  else
    movie_torrent_or_folder_name_without_path=$movie_torrent_or_folder
  fi

  is_movie_suitable

if ! [[ "$movie_suitability" =~ ^[0-2]+$ ]]; then
  handle_error "Line:$LINENO Error: ${FUNCNAME[0]} returned an unexpected value for $movie_name:"
  return
fi

if [ "$movie_suitability" -eq 1 ]; then
  handle_error "Error:$LINENO ${FUNCNAME[0]} $movie_name is not suitable for download"
  return
elif [ "$movie_suitability" -eq 2 ]; then
  handle_error "Error:$LINENO ${FUNCNAME[0]} $movie_name cannot be downloaded"
  return
fi
# Download Section
format_unformatted_movie_name
get_output_movie_folder_formatted_name

if [[ -f "$input_path/$movie_torrent_or_folder_name_without_path" ]] || [[ -L "$input_path/$movie_torrent_or_folder_name_without_path" ]]; then
    rm -f "$input_path/$movie_torrent_or_folder_name_without_path"
elif [[ -d "$input_path/$movie_torrent_or_folder_name_without_path" ]]; then
    handle_error "directory: $input_path/$movie_torrent_or_folder_name_without_path"
fi


  is_torrent_downloaded=""
  if curl -sS -LJ -o "$output_path/$output_movie_folder_formatted_name.torrent" "$yts_torrent_download_url"; then
    is_torrent_downloaded="y"
    #set value of is_movie_downloaded=
    if [ -z "$imdb_id" ]; then
      handle_error "Line:$LINENO Error: imdb_id is required."
    return 1
    fi
    if [ -z "$csv_database_path" ]; then
      handle_error "Line:$LINENO Error: csv_database_path is required."
    return 1
    fi
      movie_data=$(grep "^$imdb_id," "$csv_database_path")
    if [ -n "$movie_data" ]; then
      is_movie_downloaded=$(echo "$movie_data" | awk -F',' '{print $NF}')
      if [ "$is_movie_downloaded" == "y" ]; then
        is_movie_downloaded="y"
      else
        is_movie_downloaded="n"
      fi
    else 
        is_movie_downloaded="n"
    fi


  else
    handle_error "Failed to download $output_movie_folder_formatted_name"
    is_torrent_downloaded="n"
    movie_data=$(grep "^$imdb_id," "$csv_database_path")
    if [ -n "$movie_data" ]; then
      is_movie_downloaded=$(echo "$movie_data" | awk -F',' '{print $NF}')
      if [ "$is_movie_downloaded" == "y" ]; then
        is_movie_downloaded="y"
      else
        is_movie_downloaded="n"
      fi
    else 
      is_movie_downloaded="n"
   
    fi
    exit 1
  fi

  if [ "$is_torrent_downloaded" == "y" ]; then
      echo "------------$output_movie_folder_formatted_name Downloaded"

  fi
}

rename_folder(){
if [ "$movie_torrent_or_folder" == "$output_path/$output_movie_folder_formatted_name" ]; then
    echo "Movie $output_movie_folder_formatted_name already updated"

      else
      mv "$movie_torrent_or_folder" "$output_path/$output_movie_folder_formatted_name"

      echo "Moving "$movie_torrent_or_folder" to "$output_path/$output_movie_folder_formatted_name""

fi
              # curl -sS -LJ -o "$movie_torrent_or_folder/folder.jpg" "$movie_poster"

if [ ! -f "$output_path/$output_movie_folder_formatted_name/folder.jpg" ]; then
curl -sS -LJ -o "$output_path/$output_movie_folder_formatted_name/folder.jpg" "$movie_poster"
fi


is_torrent_downloaded="y"
is_movie_downloaded="y"
}

update_directory_torrent_names(){
for movie_torrent_or_folder in "$input_path"/*; do
  management_output_files=$(basename "$movie_torrent_or_folder")
  if [[ "$management_output_files" == "csv_database.csv" || "$management_output_files" == "error.log" ]]; then
    continue
  fi
  if [[ ! $(ls $input_path | grep -E ".*.(torrent|error|added)") ]] && [[ ! $(ls -F $input_path | grep '/') ]]; then
      handle_error "Line:$LINENO Error: No torrent file exists at $input_path"
      main 
  fi

  if [ -f "$movie_torrent_or_folder" ]; then
            parse_torrent_file 
            format_unformatted_movie_name 
            get_yts_url
            get_imdb_id 
        
      if [ -n "$(omdb_data=$(is_movie_data_exists) && echo "$omdb_data")" ]; then
            IFS=',' read -r imdb_id movie_name movie_year movie_rating movie_genres imdb_rating imdb_votes movie_release_date movie_director movie_language movie_writer movie_actor is_torrent_downloaded is_movie_downloaded <<< "$omdb_data"

      else

            get_omdb_data
        
      fi
      get_yts_movie_page_source_code 
      get_yts_torrent_download_url
      # check if torrent file should be downloaded
      if [[ "$skip_existing" -eq 1 && -n "$imdb_id" && $(echo "$existing_imdb_ids" | grep -Fx "$imdb_id") ]]; then
        echo "Skipping $movie_name ($movie_year) - Torrent file already exists in database"
      else
        download_torrent
      fi



  elif [ -d "$movie_torrent_or_folder" ]; then
       # imdb_id=""
        movie_folder_name=${movie_torrent_or_folder##*/}
        imdb_id=$(echo "$movie_folder_name" | grep -o 'tt[0-9]\+' | awk -F'tt' '{print $2}')
        if [[ -n "$imdb_id" ]]; then
           if [ -n "$(omdb_data=$(is_movie_data_exists) && echo "$omdb_data")" ]; then
              IFS=',' read -r imdb_id movie_name movie_year movie_rating movie_genres imdb_rating imdb_votes movie_release_date movie_director movie_language movie_writer movie_actor is_torrent_downloaded is_movie_downloaded <<< "$omdb_data"
           
            format_unformatted_movie_name
              #convert_imdb_votes
              get_output_movie_folder_formatted_name
              if [ -e "$movie_torrent_or_folder" ]; then
                rename_folder
                else
                handle_error "Line:$LINENO Error: file "$movie_torrent_or_folder" does not exist "
                exit
              fi
            else
              get_omdb_data
              format_unformatted_movie_name
              #convert_imdb_votes
              get_output_movie_folder_formatted_name
              if [ -e "$movie_torrent_or_folder" ]; then
                  rename_folder
                  else
                  handle_error "Line:$LINENO Error: file "$movie_torrent_or_folder" does not exist "
                  exit
              fi
            fi
        else
            #parse file to get movie name
         
            format_unformatted_movie_name
            get_yts_url
            get_imdb_id
            get_omdb_data
             if [ -e "$movie_torrent_or_folder" ]; then
             #convert_imdb_votes
              get_output_movie_folder_formatted_name
              rename_folder
                else
                handle_error "Line:$LINENO Error: file "$movie_torrent_or_folder" does not exist "
                exit
             fi
        fi

        #echo "Renaming folder $movie_torrent_or_folder to $output_movie_folder_formatted_name"
 
    fi

handle_movie_data
done
}

download_torrent_by_directory_name(){
for movie_torrent_or_folder in "$input_path"/*; do
  
  management_output_files=$(basename "$movie_torrent_or_folder")
  if [[ "$management_output_files" == "csv_database.csv" || "$management_output_files" == "error.log" ]]; then
    continue
  fi


  if [[ ! $(ls -F $input_path | grep '/') ]]; then
    handle_error "Line:$LINENO Error: No movie folder exists at $input_path"
    main 
  fi
  
  movie_folder_name=${movie_torrent_or_folder##*/}
  imdb_id=$(echo "$movie_folder_name" | grep -o 'tt[0-9]\+' | awk -F'tt' '{print $2}')
  if [[ -n "$imdb_id" ]]; then
     if [ -n "$(omdb_data=$(is_movie_data_exists) && echo "$omdb_data")" ]; then
        IFS=',' read -r imdb_id movie_name movie_year movie_rating movie_genres imdb_rating imdb_votes movie_release_date movie_director movie_language movie_writer movie_actor is_torrent_downloaded is_movie_downloaded <<< "$omdb_data"
     else
        get_omdb_data
     fi
         unformatted_movie_name="$movie_folder_name"

    format_unformatted_movie_name
    get_yts_url
  else
    unformatted_movie_name="$movie_folder_name"
    format_unformatted_movie_name
    get_yts_url
    get_imdb_id
    get_omdb_data
  fi
get_yts_movie_page_source_code
get_yts_torrent_download_url
get_output_movie_folder_formatted_name
download_torrent
curl -sS -LJ -o "$movie_torrent_or_folder/folder.jpg" "$movie_poster"
handle_movie_data
done
}


download_torrent_by_browsing_yts() {
    base_url="https://yts.mx/browse-movies"
    yts_page_number=1
    yts_movie_urls=()

    while : ; do
        page_url="${base_url}?page=${yts_page_number}"
        page_html=$(curl -s "$page_url")
        links=$(echo "$page_html" | grep -oP '(?<=href=").+?(?=")')

        for link in $links; do
            if [[ "$link" =~ "/movies/" ]]; then
                if [[ ! " ${yts_movie_urls[@]} " =~ " ${link} " ]]; then
                    yts_movie_urls+=("$link")
                fi
            fi
        done

        next_page_link=$(echo "$page_html" | grep -oP '(?<=Next &raquo;</a></li><li><a href=").+?(?=")')
        if [ -z "$next_page_link" ]; then
            break
        fi

       yts_page_number=$((yts_page_number+1))
    done

    for yts_movie_url in "${yts_movie_urls[@]}"; do
        process_yts_url_in_parallel &

    done
wait
}

process_yts_url_in_parallel(){
  get_imdb_id
}


main(){
initialize_variables
sort_csv_file

echo -e "${YELLOW}1. Rename torrents or Directories with latest IMDB Data${NC}"
echo -e "${YELLOW}2. Read Directory Names and download torrents${NC}"
echo -e "${YELLOW}3. Search movie names in Database${NC}"
echo -e "${YELLOW}4. Browse YTS and download torrents from all pages${NC}"
echo -e "${YELLOW}5. Input new values for input_path output_path${NC}"
echo -e "${YELLOW}6. Switch Input and Output Paths${NC}"
echo -e "${YELLOW}7. Make output path same as input path${NC}"
echo -e "${YELLOW}8. Input new values for imdb_lower_limit imdb_upper_limit${NC}"
echo -e "${YELLOW}9. visit yts.mx to download movie data${NC}"
echo -e "${RED}x. Exit${NC}"
read -e -n1 -p "Enter your choice: " choice

case $choice in
1)
unset_variables
update_directory_torrent_names
runtime end
runtime total
;;
2)
unset_variables
download_torrent_by_directory_name
runtime end
runtime total
;;
3)
unset_variables
get_movie_data_from_yts_omdb_datas

;;
4)
unset_variables
get_path_and_limits
;;
5)
unset_variables
get_movie_data_from_yts_omdb_datas
;;
6)
unset_variables
get_path_and_limits

;;
7)
unset_variables
get_movie_data_from_yts_omdb_datas
;;
8)
unset_variables
get_path_and_limits
;;
9)
unset_variables
get_movie_data_from_yts_omdb_datas
;;
x)
sort_csv_file
exit 0
;;
*)
echo -e "${RED}Invalid choice${NC}"
main
;;
esac

}
main
