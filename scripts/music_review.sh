#!/usr/bin/env nix
#!nix shell -I nixpkgs=github:NixOS/nixpkgs/nixos-unstable
#!nix nixpkgs#yt-dlp nixpkgs#curl nixpkgs#jq nixpkgs#coreutils --command bash

set -e

VIDEO_URL=$1

OPENAI_API_KEY="$(cat ~/.openai-api-key)"

VIDEO_JSON=$(yt-dlp -j "$VIDEO_URL")

MESSAGE="$(
  cat <<EOF
You will be given a thumbnail image and JSON data obtained from running yt-dlp -j on a video of a music performance. Your task is to analyze this data and determine the title of the piece, the composer, and the event setting (e.g., concert hall, festival, etc.).

Here is the JSON data:
<json_data>
$(echo "$VIDEO_JSON" | jq '{title,description}')
</json_data>

Follow these steps to complete the task:

1. Parse the JSON data carefully. Pay attention to fields such as "title", "description", "tags", and any other relevant fields that might contain the information we're looking for.

2. Extract the title of the piece:
   - Look for patterns like "[Piece Name]" or "Composer: [Piece Name]" in the title or description.
   - If not clearly stated, use your best judgment based on the available information.

3. Identify the composer:
   - Search for the composer's name in the title, description, or tags.
   - Look for patterns like "by [Composer Name]" or "Composer: [Name]".

4. Determine the event setting:
   - Look for mentions of concert halls, festivals, or other performance venues in the title, description, or tags.
   - If not explicitly stated, try to infer from other contextual information (e.g., "Live at...", "Recorded at...").

5. Present your findings in the following format:
   <analysis>
   Title: [Title of the piece]
   Composer: [Name of the composer]
   Event Setting: [Name or description of the event setting]
   </analysis>

6. If you cannot find clear information for any of the requested items, state "Unable to determine" for that item and explain why in your explanation.
EOF
)"

VIDEO_METADATA=$(
  curl https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
          "model": "gpt-4o",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "'"$MESSAGE"'"
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "'"$(echo "$VIDEO_JSON" | jq -r '.thumbnail')"'"
                  }
                }
              ]
            }
          ],
          "max_tokens": 1000
        }' | jq '.choices[0].message.content' | grep -o '<analysis>.*</analysis>' | sed 's/<analysis>//;s/<\/analysis>//'
)

MESSAGE="$(
  cat <<EOF
You are analyzing the following music performance:

$VIDEO_METADATA

The assignment requires you to:
1. Perform an objective analysis of the melody, explaining how performers use or embellish the main musical idea.
2. Analyze the texture (monophonic, polyphonic, homophonic).
3. Examine the dynamics, describing how performers use different volume levels to enhance the music.
4. Analyze the timbre, describing the color of instruments or voices (e.g., bright, dark, mellow, rich, scary, happy).
5. Discuss any improvisation, noting how and which performers use it to enhance the song.

Please provide detailed answers for each section based on the audio input.
EOF
)"

curl "https://api.openai.com/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  --data-binary '@-' <<EOF
{
  "model": "gpt-4o-audio-preview",
  "modalities": ["text"],
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": $MESSAGE
        },
        {
          "type": "input_audio",
          "input_audio": {
            "data": "$(yt-dlp -q -x --audio-format wav -o- "$VIDEO_URL" | base64 -w 0)",
            "format": "wav"
          }
        }
      ]
    }
  ]
}
EOF
